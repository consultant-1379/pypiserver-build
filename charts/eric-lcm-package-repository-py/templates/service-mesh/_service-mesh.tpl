{{/* vim: set filetype=mustache: */}}

{{/*
SM Design Rule DR-D470217-007-AD 
Sidecar proxy should be injected and service mesh related configuration should be created only if
serviceMesh is enabled globally and at service level
*/}}
{{- define "eric-lcm-package-repository-py.serviceMesh.enabled" -}}
{{- $lcmPackageRepositorySM := false -}}
{{- if .Values.global -}}
    {{- if .Values.global.serviceMesh -}}
        {{- if .Values.global.serviceMesh.enabled -}}
            {{- if .Values.serviceMesh -}}
                {{- if .Values.serviceMesh.enabled -}}
                    {{- $lcmPackageRepositorySM = true -}}
                {{- end -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- $lcmPackageRepositorySM -}}
{{- end -}}


{{- define "eric-lcm-package-repository-py.sidecar-volumes" -}}
{{- $type:= index . "Type" -}}
{{ $annotations:= dict -}}
    {{- if (.Values).serviceMesh }}
        {{- if hasKey (.Values).serviceMesh $type }}
            {{- range $k, $v := index .Values "serviceMesh" $type -}}
                {{- if kindIs "map" $v -}}
                    {{- if (hasKey $v "genSecretName") -}}
                        {{- $enabled := $v.enabled -}}
                        {{- $secretName := printf "%s-%s-secret" $type $k -}}
                        {{- $genSecretName := $v.genSecretName -}}
                        {{- $optional := $v.optional -}}

                        {{$secretDict:= dict}}
                        {{- if eq $k "ca" -}}
                            {{- $secretDict := merge $secretDict (dict "secretName" $genSecretName) -}}
                        {{- else if $enabled -}}
                            {{- $secretDict := merge $secretDict (dict "secretName" $genSecretName) -}}
                            {{- if $optional -}}
                            {{- $secretDict := merge $secretDict (dict "optional" ($optional | toString )) -}}
                            {{- end -}}
                        {{- end -}}
                        {{- $annotations := merge $annotations (dict $secretName (dict "secret" $secretDict)) -}}
                    {{- end -}}
                {{- end -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- $annotations | toJson -}}
{{- end -}}

{{- define "eric-lcm-package-repository-py.sidecar-volumeMounts" -}}
{{- $type:= index . "Type" -}}
{{ $annotations:= dict -}}
    {{- if (.Values).serviceMesh }}
        {{- if hasKey (.Values).serviceMesh $type }}
            {{- range $k, $v := index .Values "serviceMesh" $type -}}
                {{- if kindIs "map" $v -}}
                        {{- if (hasKey $v "genSecretName") -}}
                            {{- $enabled := $v.enabled -}}
                            {{- $secretName := printf "%s-%s-secret" $type $k -}}
                            {{- $readOnly := $v.readOnly -}}
                            {{$secretDict:= dict}}
                            {{- if eq $k "ca" -}}
                                {{- if ( kindIs "invalid" $v.caCertsPath ) }}
                                    {{ fail (printf "caCertsPath is required for mounting %s secret %s" $type $k) }}
                                {{- end -}}
                                {{- $secretDict := merge $secretDict (dict "mountPath" $v.caCertsPath) -}}
                            {{- else if $enabled -}}
                                {{- if ( kindIs "invalid" $v.certsPath ) }}
                                    {{ fail (printf "certsPath is required for mounting %s secret %s" $type $k) }}
                                {{- end -}}
                                {{- $secretDict := merge $secretDict (dict "mountPath" $v.certsPath) -}}
                                {{- if $readOnly -}}
                                {{- $secretDict := merge $secretDict (dict "readOnly" ($readOnly | toString )) -}}
                                {{- end -}}
                            {{- end -}}
                            {{- if ne (len $secretDict) 0 -}}
                            {{- $annotations := merge $annotations (dict $secretName $secretDict) -}}
                            {{- end -}}
                        {{- end -}}
                {{- end -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
{{- $annotations | toJson -}}
{{- end -}}


{{/* 
SM DR-D470217-001 SM DR-D470217-011 Control sidecar injection
*/}}
{{- define "eric-lcm-package-repository-py.istio-sidecar-annotations" -}}
{{ $lcmPackageRepositorySM := include "eric-lcm-package-repository-py.serviceMesh.enabled" . }}
proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'
sidecar.istio.io/rewriteAppHTTPProbers: {{ $lcmPackageRepositorySM | quote }}
{{ $egressVolumes := include "eric-lcm-package-repository-py.sidecar-volumes" (dict "Values" .Values "Type" "egress" ) | fromJson -}}
{{- $ingressVolumes := include "eric-lcm-package-repository-py.sidecar-volumes" (dict "Values" .Values "Type" "ingress" ) | fromJson -}}
{{- $volumes := merge $egressVolumes $ingressVolumes -}}
{{- if hasKey ((.Values).serviceMesh) "sidecarAnnotations" -}}
    {{- if hasKey ((.Values).serviceMesh).sidecarAnnotations "userVolumes" -}}
        {{- if (((.Values).serviceMesh).sidecarAnnotations).userVolumes -}}
            {{- $sanitizedExtraVolumes := (((.Values).serviceMesh).sidecarAnnotations).userVolumes | trimAll "'" | fromJson }}
            {{- $volumes = mergeOverwrite $volumes $sanitizedExtraVolumes -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- if $volumes -}}
sidecar.istio.io/userVolume: {{$volumes | toJson | squote}}
{{- end -}}
{{ $egressVolumeMounts := include "eric-lcm-package-repository-py.sidecar-volumeMounts" (dict "Values" .Values "Type" "egress" ) | fromJson }}
{{ $ingressVolumeMounts := include "eric-lcm-package-repository-py.sidecar-volumeMounts" (dict "Values" .Values "Type" "ingress" ) | fromJson }}
{{- $volumeMounts := merge $egressVolumeMounts $ingressVolumeMounts -}}
{{- if hasKey ((.Values).serviceMesh) "sidecarAnnotations" -}}
    {{- if hasKey ((.Values).serviceMesh).sidecarAnnotations "userVolumeMounts" -}}
        {{- if (((.Values).serviceMesh).sidecarAnnotations).userVolumeMounts -}}
            {{- $sanitizedExtraVolumeMounts := (((.Values).serviceMesh).sidecarAnnotations).userVolumeMounts | trimAll "'" | fromJson }}
            {{- $volumeMounts = mergeOverwrite $volumeMounts $sanitizedExtraVolumeMounts -}}
        {{- end -}}
    {{- end -}}
{{- end -}}
{{- if $volumeMounts -}}
sidecar.istio.io/userVolumeMount: {{$volumeMounts | toJson | squote}}
{{- end -}}
{{- with (((.Values).global).serviceMesh).annotations }}
{{  toYaml . }}
{{- end }}
{{- end -}}

{{/* 
SM DR-D470217-011 Control sidecar injection
*/}}
{{- define "eric-lcm-package-repository-py.istio-sidecar-labels" -}}
{{ $lcmPackageRepositorySM := include "eric-lcm-package-repository-py.serviceMesh.enabled" . }}
sidecar.istio.io/inject: {{ $lcmPackageRepositorySM | quote }}
{{- end -}}

{{/*
 Service Mesh Version Annotations
 GL-D470217-070-AD
*/}}
{{- define "eric-lcm-package-repository-py.service-mesh-version" }}
{{- if eq (include "eric-lcm-package-repository-py.serviceMesh.enabled" .) "true" }}
  {{- if .Values.global -}}
    {{- if .Values.global.serviceMesh -}}
      {{- if .Values.global.serviceMesh.annotations -}}
        {{ .Values.global.serviceMesh.annotations | toYaml }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}