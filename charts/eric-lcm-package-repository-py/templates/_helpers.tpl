{{/*
  Expand the name of the chart.
*/}}
{{- define "eric-lcm-package-repository-py.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
  Create a default fully qualified app name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  If release name contains chart name it will be used as a full name.
*/}}
{{- define "eric-lcm-package-repository-py.fullname" -}}
{{- if .Values.fullnameOverride -}}
  {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- $name := default .Chart.Name .Values.nameOverride -}}
  {{- printf "%s" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{/*
  Create chart name and version as used by the chart label.
*/}}
{{- define "eric-lcm-package-repository-py.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
  Standard labels
*/}}
{{- define "eric-lcm-package-repository-py.standardLabels" -}}
app.kubernetes.io/name: {{ include "eric-lcm-package-repository-py.name" . }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
helm.sh/chart: {{ include "eric-lcm-package-repository-py.chart" . }}
{{- end -}}

{{- define "eric-lcm-package-repository-py.bragent.access" -}}
  {{ $global := fromYaml (include "eric-lcm-package-repository-py.global" .) }}
  {{- if eq .Values.brAgent.enabled true }}
        {{ $global.adpBR.broServiceName }}-access: "true"
  {{- end }}
{{- end -}}

{{- define "eric-lcm-package-repository-py.bragent.brLabelKey" -}}
  {{ $global := fromYaml (include "eric-lcm-package-repository-py.global" .) }}
  {{- if $global.adpBR.brLabelKey }}
    {{ $global.adpBR.brLabelKey }}: {{ .Values.brAgent.brLabelValue | default .Chart.Name | quote }}
  {{- end }}
{{- end -}}

{{/*
  Create a user defined label
*/}}
{{ define "eric-lcm-package-repository-py.configLabels" }}
  {{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
  {{- $globalLabels:= $global.labels -}}
  {{- $service := .Values.labels -}}
  {{- $brAccess := include "eric-lcm-package-repository-py.bragent.access" . | fromYaml -}}
  {{- $brLabelKey := include "eric-lcm-package-repository-py.bragent.brLabelKey" . | fromYaml -}}
  {{- include "eric-lcm-package-repository-py.mergeLabels" (dict "location" .Template.Name "sources" (list $globalLabels $service $brAccess $brLabelKey)) }}
{{- end }}


{{/*
  Merged labels for Default, which includes Standard and Config
*/}}
{{- define "eric-lcm-package-repository-py.labels" -}}
  {{- $standard := include "eric-lcm-package-repository-py.standardLabels" . | fromYaml -}}
  {{- $config := include "eric-lcm-package-repository-py.configLabels" . | fromYaml -}}
  {{- include "eric-lcm-package-repository-py.mergeLabels" (dict "location" .Template.Name "sources" (list $standard $config)) | trim }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "eric-lcm-package-repository-py.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eric-lcm-package-repository-py.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}


{{/*
  Create the name of the service account to use
*/}}
{{- define "eric-lcm-package-repository-py.serviceAccountName" -}}
    {{ include "eric-lcm-package-repository-py.name" . }}
{{- end -}}


{{/*
  Ingress Labels for Network Policy
*/}}
{{- define "eric-lcm-package-repository-py.ingress-network-labels" -}}
{{- if .Values.networkPolicy.services -}}
{{- range .Values.networkPolicy.services }}
- podSelector:
    matchLabels:
      {{ toYaml .labels }}
{{- end }}
{{- else -}}
app.kubernetes.io/name: {{ .Values.serviceMesh.ingress.gwName }}
{{- end -}}
{{- end -}}

{{/*
  Create a user defined annotation
*/}}
{{ define "eric-lcm-package-repository-py.configAnnotations" }}
  {{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
  {{- $globalAnnotations:= $global.annotations -}}
  {{- $service := .Values.annotations -}}
  {{- include "eric-lcm-package-repository-py.mergeAnnotations" (dict "location" .Template.Name "sources" (list $globalAnnotations $service)) }}
{{- end }}


{{/*
  Merged annotations for Default, which includes productInfo and config
*/}}
{{- define "eric-lcm-package-repository-py.annotations" -}}
  {{- $productInfo := include "eric-lcm-package-repository-py.product-info" . | fromYaml -}}
  {{- $config := include "eric-lcm-package-repository-py.configAnnotations" . | fromYaml -}}
  {{- include "eric-lcm-package-repository-py.mergeAnnotations" (dict "location" .Template.Name "sources" (list $productInfo $config)) | trim }}
{{- end -}}


{{/*
  Define the complete image url
*/}}
{{- define "eric-lcm-package-repository-py.ericLcmPackageRepositoryPyImagePath" -}}
  {{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
  {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}

  {{- $registryUrl := $productInfo.images.ericLcmPackageRepositoryPy.registry -}}
  {{- $repoPath := $productInfo.images.ericLcmPackageRepositoryPy.repoPath -}}
  {{- $name := $productInfo.images.ericLcmPackageRepositoryPy.name -}}
  {{- $tag := $productInfo.images.ericLcmPackageRepositoryPy.tag -}}

  {{- if ($global.registry).url -}}
    {{- $registryUrl = $global.registry.url -}}
  {{- end -}}
  {{- if not (kindIs "invalid" ($global.registry).repoPath) -}}
    {{- $repoPath = $global.registry.repoPath -}}
  {{- end -}}

  {{- if not (kindIs "invalid" (.Values.imageCredentials).repoPath) -}}
    {{- $repoPath = .Values.imageCredentials.repoPath -}}
  {{- end -}}
  {{- if (((.Values.imageCredentials).ericLcmPackageRepositoryPy).registry).url -}}
    {{- $registryUrl = .Values.imageCredentials.ericLcmPackageRepositoryPy.registry.url -}}
  {{- end -}}
  {{- if not (kindIs "invalid" ((.Values.imageCredentials).ericLcmPackageRepositoryPy).repoPath) -}}
    {{- $repoPath = .Values.imageCredentials.ericLcmPackageRepositoryPy.repoPath -}}
  {{- end -}}

  {{- if $repoPath -}}
    {{- $repoPath = printf "%s/" $repoPath -}}
  {{- end -}}
  {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}


{{/*
  PyPi init container to copy all pip packages into pypiserver main container
*/}}
{{- define "eric-lcm-package-repository-py.ericLcmPackageRepositoryPyInitContainer" -}}
  
    {{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}

    {{- $registryUrl := $productInfo.images.ericLcmPackageRepositoryPy.registry -}}
    {{- $repoPath := $productInfo.images.ericLcmPackageRepositoryPy.repoPath -}}
    {{- $name := default $productInfo.images.ericLcmPackageRepositoryPy.name .Values.imageCredentials.pypiinit.image.name -}}
    {{- $tag := default $productInfo.images.ericLcmPackageRepositoryPy.tag .Values.imageCredentials.pypiinit.image.tag -}}
    
    {{- if ($global.registry).url -}}
      {{- $registryUrl = $global.registry.url -}}
    {{- end -}}
    {{- if not (kindIs "invalid" ($global.registry).repoPath) -}}
      {{- $repoPath = $global.registry.repoPath -}}
    {{- end -}}

    {{- if not (kindIs "invalid" (.Values.imageCredentials).repoPath) -}}
      {{- $repoPath = .Values.imageCredentials.repoPath -}}
    {{- end -}}
    {{- if (((.Values.imageCredentials).pypiinit).registry).url -}}
      {{- $registryUrl = .Values.imageCredentials.pypiinit.registry.url -}}
    {{- end -}}
    {{- if not (kindIs "invalid" (((.Values.imageCredentials).pypiinit).registry).repoPath) -}}
      {{- $repoPath = .Values.imageCredentials.pypiinit.registry.repoPath -}}
    {{- end -}}

    {{- if $repoPath -}}
      {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}

    {{ printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag | quote }}

{{- end -}}

{{/*
  Prints a value with quotes if its kind is "string". If its kind is anything else, tries to
  to convert its string representation to integer and prints it.
*/}}
{{- define "eric-lcm-package-repository-py.printStringOrIntegerValue" -}}
  {{- if kindIs "string" . -}}
    {{- print . | quote -}}
  {{- else -}}
    {{- print . | atoi -}}
  {{- end -}}
{{- end -}}


{{/*
Update strategy for the StatefulSet
*/}}
{{- define "eric-lcm-package-repository-py.update-strategy" -}}
updateStrategy:
  type: {{ .Values.updateStrategy.type | quote }}
{{- end -}}

{{/*
  Defines security context.
  Kubernetes SecurityContext Item for PodSpec/[]Container
  Required Scope: default chart context
*/}}
{{- define "eric-lcm-package-repository-py.container-security-context" -}}
securityContext:
  {{ include "eric-lcm-package-repository-py.seccomp-profile" (dict "Values" .Values "Scope" .ContainerName) | nindent 2}}
  capabilities:
    drop:
      - all
  privileged: false
  runAsNonRoot: true
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
{{- end -}}

{{- define "eric-lcm-package-repository-py.fsGroup.coordinated" -}}
{{- if .Values.global -}}
  {{- if .Values.global.fsGroup -}}
    {{- if .Values.global.fsGroup.manual -}}
      {{ .Values.global.fsGroup.manual }}
    {{- else -}}
      {{- if .Values.global.fsGroup.namespace -}}
        {{- if eq .Values.global.fsGroup.namespace true -}}
          {{/* The 'default' defined in the Security Policy will be used. */}}
        {{- else -}}
          10000
        {{- end -}}
      {{- else -}}
        10000
      {{- end -}}
    {{- end -}}
  {{- else -}}
    10000
  {{- end -}}
{{- else -}}
  10000
{{- end -}}
{{- end -}}

{{/*
  Defines container spec imagePullPolicy.
  Kubernetes imagePullPolicy item for PodSpec/[]Container
  Required Scope: (list $ . (dict "imageKey" "<image name>" ))
*/}}
{{- define "eric-lcm-package-repository-py.imagePullPolicy" -}}
{{- $ := index . 0 -}}{{- $context := index . 1 -}}{{- $dictParam := index . 2 -}}
{{- $imageKey := get $dictParam "imageKey" -}}
{{- $imagePullPolicy := "IfNotPresent" -}}
{{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" $ ) -}}
  {{- with $context -}}
    {{- if $global.registry.imagePullPolicy -}}
        {{- $imagePullPolicy = $global.registry.imagePullPolicy -}}
    {{- end -}}
    {{- if ((index .Values.imageCredentials $imageKey).registry).imagePullPolicy -}}
        {{- $imagePullPolicy = (index .Values.imageCredentials $imageKey).registry.imagePullPolicy -}}
    {{- end -}}
imagePullPolicy: {{ $imagePullPolicy | quote }}
  {{- end -}}
{{- end -}}


{{/*
  Defines container health probes.
  Kubernetes Lifecycle probes Items for PodSpec/[]Container
  Required Scope: default chart context
*/}}
{{- define "eric-lcm-package-repository-py.containerProbesConfig" -}}
{{- $ := index . 0 -}}{{- $context := index . 1 -}}{{- $dictParam := index . 2 -}}
{{- $probes := (list "livenessProbe" "readinessProbe" "startupProbe" ) -}}
{{- $probesKey := get $dictParam "probesKey" -}}
{{- $probeMap := (index $context.Values.probes $probesKey ) }}
  {{- range $probe := $probes }}
    {{- with $context }}
      {{- if hasKey $probeMap $probe }}
{{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) }}
{{ $probe }}:
  httpGet:
    path: /
    port: http
    scheme: HTTP
  {{- toYaml (index $probeMap $probe ) | nindent 2 }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
  Defines container resources.
  Kubernetes resources Item for PodSpec
  Required Scope: default chart context
*/}}
{{- define "eric-lcm-package-repository-py.containerResources" -}}
{{- $ := index . 0 -}}{{- $ctx := index . 1 -}}{{- $containerName := index . 2 -}}
{{- $resourcesType := (list "limits" "requests" ) -}}
{{- range $resourcesKey := $resourcesType }}
  {{- with $ctx }}
{{ $resourcesKey }}:
    {{- if (index .Values "resources" $containerName $resourcesKey "cpu") }}
  cpu: {{ (index .Values "resources" $containerName $resourcesKey "cpu" | quote ) }}
    {{- end }}
    {{- if (index .Values "resources" $containerName $resourcesKey "memory") }}
  memory: {{ (index .Values "resources" $containerName $resourcesKey "memory" | quote ) }}
    {{- end }}
    {{- if (index .Values "resources" $containerName $resourcesKey "ephemeral-storage") }}
  ephemeral-storage: {{  (index .Values "resources" $containerName $resourcesKey "ephemeral-storage" | quote ) }}
    {{- end }}
  {{- end -}}
{{- end -}}
{{- end -}}


{{/*
  Create a merged set of nodeSelectors from global and service level.
*/}}
{{- define "eric-lcm-package-repository-py.pypiserver.nodeSelector" -}}
{{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
{{- $nodeSelector := dict -}}
  {{- if $global.nodeSelector -}}
    {{- $nodeSelector = $global.nodeSelector -}}
  {{- end -}}
  {{- if .Values.nodeSelector.pypiserver -}}
    {{- range $serviceLevelKey, $serviceLevelValue := .Values.nodeSelector.pypiserver  -}}
      {{- if and (hasKey $nodeSelector $serviceLevelKey) (ne (get $nodeSelector $serviceLevelKey) $serviceLevelValue ) -}}
        {{- fail ( printf "nodeSelector key \"%s\" is specified in both global.nodeSelector and nodeSelector with different values." $serviceLevelKey ) -}}
      {{- end -}}
    {{- end -}}
    {{- $nodeSelector = merge $nodeSelector .Values.nodeSelector.pypiserver -}}
  {{- end -}}
  {{- if not ( empty $nodeSelector ) -}}
{{- toYaml $nodeSelector | trim -}}
  {{- end -}}
{{- end -}}

{{- define "eric-lcm-package-repository-py.affinityPodAntiAffinity" -}}
{{- if eq .Values.affinity.podAntiAffinity "hard" }}
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: "app.kubernetes.io/name"
          operator: In
          values:
          - {{ include "eric-lcm-package-repository-py.name" . }}
      topologyKey: "kubernetes.io/hostname"
{{- else if eq .Values.affinity.podAntiAffinity "soft" }}
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: "app.kubernetes.io/name"
            operator: In
            values:
            - {{ include "eric-lcm-package-repository-py.name" . }}
        topologyKey: "kubernetes.io/hostname"
{{- end }}
{{- end -}}

{{/*
Define topologySpreadConstraints
*/}}
{{- define "eric-lcm-package-repository-py.topologySpreadConstraints" -}}
{{- range $index, $hub := .Values.topologySpreadConstraints.pypiserver }}
- maxSkew: {{ $hub.maxSkew }}
  topologyKey: {{ $hub.topologyKey }}
  whenUnsatisfiable: {{ $hub.whenUnsatisfiable }}
  labelSelector:
    matchExpressions:
        - key: "app.kubernetes.io/name"
          operator: In
          values:
          - {{ include "eric-lcm-package-repository-py.name" . }}
{{- end -}}
{{- end -}}

{{/*
  Defines container spec pull secret.
  Kubernetes imagePullSecrets item for PodSpec/[]Container
  Required Scope: default chart context
*/}}
{{- define "eric-lcm-package-repository-py.pullSecret" -}}
{{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
{{- if .Values.imageCredentials.pullSecret }}
imagePullSecrets:
  - name: {{ .Values.imageCredentials.pullSecret | quote }}
{{- else if $global.pullSecret }}
imagePullSecrets:
  - name: {{ $global.pullSecret | quote }}
{{- end }}
{{- end -}}

{{- define "eric-lcm-package-repository-py.podPriorityClass" -}}
{{- if (((.Values).podPriority).ericLcmPackageRepositoryPy).priorityClassName }}
priorityClassName: {{ .Values.podPriority.ericLcmPackageRepositoryPy.priorityClassName | quote }}
{{- end }}
{{- end -}}


{{/*
Seccomp profile section (DR-1123-128)
*/}}
{/*
DR-D1123-128 seccomp profile
Scope
*/}}
{{- define "eric-lcm-package-repository-py.seccomp-profile" -}}
{{- if .Values.seccompProfile -}}
{{- if eq .Scope "Pod" -}}
{{- if .Values.seccompProfile.type -}}
seccompProfile:
  type: {{ .Values.seccompProfile.type }}
  {{- if eq .Values.seccompProfile.type "Localhost" }}
  {{- if not .Values.seccompProfile.localhostProfile }}
  {{- fail "localhostProfile for seccompProfile must be spcified" }}
  {{- end }}
  localhostProfile: {{ .Values.seccompProfile.localhostProfile }}
  {{- end -}}
{{- end -}}
{{- else if (hasKey .Values.seccompProfile .Scope) -}}
{{- $container_setting := (get .Values.seccompProfile .Scope) -}}
{{- if $container_setting.type -}}
seccompProfile:
  type: {{ $container_setting.type }}
  {{- if eq $container_setting.type "Localhost" }}
  {{- if not $container_setting.localhostProfile }}
  {{- fail "localhostProfile for seccompProfile must be spcified" }}
  {{- end }}
  localhostProfile: {{ $container_setting.localhostProfile }}
  {{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Traffic shaping bandwidth limit annotation (DR-D1125-040-AD)
*/}}
{{- define "eric-lcm-package-repository-py.pypiserver-egressRate.annotation" -}}
{{- $maxEgressRate := "" -}}
{{- if .Values.bandwidth -}}
  {{- if .Values.bandwidth.pypiserver -}}
       {{- if .Values.bandwidth.pypiserver.maxEgressRate -}}
          {{- $maxEgressRate = .Values.bandwidth.pypiserver.maxEgressRate -}}
            {{- if $maxEgressRate -}}
              {{- print "kubernetes.io/egress-bandwidth: " .Values.bandwidth.pypiserver.maxEgressRate -}}
            {{- end -}}
      {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Configuration of supplementalGroups IDs DR-D1123-135
*/}}
{{- define "eric-lcm-package-repository-py.supplementalGroups" -}}
     {{- $globalGroups := (list) -}}
    {{- if ( (((.Values).global).podSecurityContext).supplementalGroups) }}
      {{- $globalGroups = .Values.global.podSecurityContext.supplementalGroups -}}
    {{- end -}}
    {{- $localGroups := (list) -}}
    {{- if ( ((.Values).podSecurityContext).supplementalGroups) -}}
      {{- $localGroups = .Values.podSecurityContext.supplementalGroups -}}
    {{- end -}}
    {{- $mergedGroups := (list) -}}
    {{- if $globalGroups -}}
        {{- $mergedGroups = $globalGroups -}}
    {{- end -}}
    {{- if $localGroups -}}
        {{- $mergedGroups = concat $globalGroups $localGroups | uniq -}}
    {{- end -}}
    {{- if $mergedGroups -}}
        {{- toYaml $mergedGroups | nindent 8 -}}
    {{- end -}}
    {{- /* Do nothing if both global and local groups are not set */ -}}
{{- end -}}

{{/*
check global.security.tls.enabled
*/}}
{{- define "eric-lcm-package-repository-py.global-security-tls-enabled" -}}
{{- if  .Values.global -}}
  {{- if  .Values.global.security -}}
    {{- if  .Values.global.security.tls -}}
      {{- .Values.global.security.tls.enabled | toString -}}
    {{- else -}}
      {{- "false" -}}
    {{- end -}}
  {{- else -}}
    {{- "false" -}}
  {{- end -}}
{{- else -}}
  {{- "false" -}}
{{- end -}}
{{- end -}}



{{/*
BR Agent 
*/}}

{{- define "eric-lcm-package-repository-py.brAgent.braBackupDir" -}}
  /backupdata
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.braRestoreDir" -}}
  /restoredata
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.backupRestoreFileName" -}}
  data.tar
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.filesystemRootDirectory" -}}
  /data/packages
{{- end -}}

{{/*
Semi-colon separated list of backup types
*/}}
{{- define "eric-lcm-package-repository-py.backupTypes" }}
{{- range $i, $e := .Values.brAgent.backupTypeList -}}
{{- if eq $i 0 -}}{{- printf " " -}}{{- else -}}{{- printf ";" -}}{{- end -}}{{- . -}}
{{- end -}}
{{- end -}}


{{- define "eric-lcm-package-repository-py.brAgent.rootCAMountPath" -}}
  {{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
  /run/secrets/{{ template "eric-lcm-package-repository-py.brAgent.rootCASecret" . }}
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.rootCASecret" -}}
  {{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
  {{ ((($global.security).tls).trustedInternalRootCa).secret }}
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.rootCA" -}}
  {{ template "eric-lcm-package-repository-py.brAgent.rootCAMountPath" . }}/ca.crt
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.broCliCertSecretName" -}}
  {{ template "eric-lcm-package-repository-py.name" . }}-bro-client-cert
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.broCliCertMountPath" -}}
  /run/secrets/{{ template "eric-lcm-package-repository-py.brAgent.broCliCertSecretName" . }}
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.broCliPrivKey" -}}
  {{ template "eric-lcm-package-repository-py.brAgent.broCliCertMountPath" . }}/cliprivkey.pem
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.broCliCert" -}}
  {{ template "eric-lcm-package-repository-py.brAgent.broCliCertMountPath" . }}/clicert.pem
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.jvmHeapSettings" -}}
-XX:InitialRAMPercentage={{ .Values.resources.brAgent.jvm.initialMemoryAllocationPercentage | toString | replace "%" "" }}
-XX:MinRAMPercentage={{ .Values.resources.brAgent.jvm.smallMemoryAllocationMaxPercentage | toString | replace "%" "" }}
-XX:MaxRAMPercentage={{ .Values.resources.brAgent.jvm.largeMemoryAllocationMaxPercentage | toString | replace "%" "" }}
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.startupProbe" -}}
startupProbe:
  initialDelaySeconds: {{ .Values.probes.brAgent.startupProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.probes.brAgent.startupProbe.periodSeconds }}
  timeoutSeconds: {{ .Values.probes.brAgent.startupProbe.timeoutSeconds }}
  successThreshold: {{ .Values.probes.brAgent.startupProbe.successThreshold }}
  failureThreshold: {{ .Values.probes.brAgent.startupProbe.failureThreshold }}
  tcpSocket:
    port: {{ .Values.brAgent.restPort }}
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.livenessProbe" -}}
livenessProbe:
  initialDelaySeconds: {{ .Values.probes.brAgent.livenessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.probes.brAgent.livenessProbe.periodSeconds }}
  timeoutSeconds: {{ .Values.probes.brAgent.livenessProbe.timeoutSeconds }}
  successThreshold: {{ .Values.probes.brAgent.livenessProbe.successThreshold }}
  failureThreshold: {{ .Values.probes.brAgent.livenessProbe.failureThreshold }}
  tcpSocket:
    port: {{ .Values.brAgent.restPort }}
{{- end -}}

{{- define "eric-lcm-package-repository-py.brAgent.readinessProbe" -}}
readinessProbe:
  initialDelaySeconds: {{ .Values.probes.brAgent.readinessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.probes.brAgent.readinessProbe.periodSeconds }}
  timeoutSeconds: {{ .Values.probes.brAgent.readinessProbe.timeoutSeconds }}
  successThreshold: {{ .Values.probes.brAgent.readinessProbe.successThreshold }}
  failureThreshold: {{ .Values.probes.brAgent.readinessProbe.failureThreshold }}
  httpGet:
    path: /api/health
    port: {{ .Values.brAgent.restPort }}
{{- end -}}

{{/*
  Create a merged set of nodeSelectors from global and service level.
*/}}
{{- define "eric-lcm-package-repository-py.brAgent.nodeSelector" -}}
{{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
{{- $nodeSelector := dict -}}
  {{- if $global.nodeSelector -}}
    {{- $nodeSelector = $global.nodeSelector -}}
  {{- end -}}
  {{- if .Values.nodeSelector.brAgent -}}
    {{- range $serviceLevelKey, $serviceLevelValue := .Values.nodeSelector.brAgent  -}}
      {{- if and (hasKey $nodeSelector $serviceLevelKey) (ne (get $nodeSelector $serviceLevelKey) $serviceLevelValue ) -}}
        {{- fail ( printf "nodeSelector key \"%s\" is specified in both global.nodeSelector and nodeSelector with different values." $serviceLevelKey ) -}}
      {{- end -}}
    {{- end -}}
    {{- $nodeSelector = merge $nodeSelector .Values.nodeSelector.brAgent -}}
  {{- end -}}
  {{- if not ( empty $nodeSelector ) -}}
{{- toYaml $nodeSelector | trim -}}
  {{- end -}}
{{- end -}}

{{/*
Define the role kind for new security DR-D1123-134
*/}}
{{- define "eric-lcm-package-repository-py.securityPolicy.rolekind" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.securityPolicy -}}
      {{- if .Values.global.securityPolicy.rolekind -}}
        {{ .Values.global.securityPolicy.rolekind }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Define tolerations to comply to DR-D1120-060
*/}}
{{- define "eric-lcm-package-repository-py.pypiserver.tolerations" -}}
{{- if .Values.tolerations.pypiserver -}}
  {{- toYaml .Values.tolerations.pypiserver -}}
{{- end -}}
{{- end -}}

{{/*
  Define the complete image url BR Agent
*/}}


{{/*
The Image path (DR-D1121-067)
Params:
  Values
  Files
  ContainerName
*/}}
{{- define "eric-lcm-package-repository-py.ImagePath" }}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $containerName := index . "ContainerName" -}}
    {{- $registryUrl := index $productInfo "images" $containerName "registry" -}}
    {{- $repoPath := index $productInfo "images" $containerName "repoPath" -}}
    {{- $name := index $productInfo "images" $containerName "name" -}}
    {{- $tag := index $productInfo "images" $containerName "tag" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
            {{- if .Values.global.registry.repoPath -}}
                {{- $repoPath = .Values.global.registry.repoPath -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if (hasKey .Values.imageCredentials $containerName) -}}
            {{- if (hasKey (index .Values "imageCredentials" $containerName) "registry") -}}
                {{- if and (hasKey (index .Values "imageCredentials" $containerName "registry") "url")
                    (not ( kindIs "invalid" (index .Values "imageCredentials" $containerName "registry" "url"))) -}}
                    {{- $registryUrl = (index .Values "imageCredentials" $containerName "registry" "url") -}}
                {{- end -}}
            {{- end -}}
            {{- if and (hasKey (index .Values "imageCredentials" $containerName) "repoPath")
                       (not ( kindIs "invalid" (index .Values "imageCredentials" $containerName "repoPath"))) -}}
                {{- $repoPath = (index .Values "imageCredentials" $containerName "repoPath") -}}
            {{- end -}}
            {{- if and (hasKey (index .Values "imageCredentials" $containerName) "tag")
                       (not ( kindIs "invalid" (index .Values "imageCredentials" $containerName "tag"))) -}}
                {{- $tag = (index .Values "imageCredentials" $containerName "tag") -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
Timezone variable
*/}}
{{- define "eric-lcm-package-repository-py.timezone" -}}
  {{- $timezone := "UTC" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.timezone -}}
      {{- $timezone = .Values.global.timezone -}}
    {{- end -}}
  {{- end -}}
  {{- print $timezone | quote -}}
{{- end -}}

{{- define "eric-lcm-package-repository-py.adpBR.broGrpcServicePort" -}}
  {{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
  {{ ($global.adpBR).broGrpcServicePort }}
{{- end -}}


{{/*
    Define global Image Pull Policy
*/}}
{{- define "eric-lcm-package-repository-py.registryImagePullPolicy" -}}
    {{- $globalRegistryPullPolicy := "IfNotPresent" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.imagePullPolicy -}}
                {{- $globalRegistryPullPolicy = .Values.global.registry.imagePullPolicy -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- print $globalRegistryPullPolicy -}}
{{- end -}}

{{/*
    Define service level Image Pull Policy
*/}}
{{- define "eric-lcm-package-repository-py.serviceImagePullPolicy" -}}
{{- $registryPullPolicy := (include "eric-lcm-package-repository-py.registryImagePullPolicy" . ) -}}
    {{- if .Values.imageCredentials -}}
        {{- if not (kindIs "invalid" (index .Values "imageCredentials" "registry" "imagePullPolicy")) -}}
            {{- $registryPullPolicy = (index .Values "imageCredentials" "registry" "imagePullPolicy") -}}
        {{- end -}}
    {{- end -}}
    {{- print $registryPullPolicy -}}
{{- end -}}




{{/*
Merge global tolerations with service tolerations (DR-D1120-061-AD).
*/}}
{{- define "eric-lcm-package-repository-py.merge-tolerations" -}}
  {{- if (.root.Values.global).tolerations }}
      {{- $globalTolerations := .root.Values.global.tolerations -}}
      {{- $serviceTolerations := list -}}
      {{- if .root.Values.tolerations -}}
        {{- if eq (typeOf .root.Values.tolerations) ("[]interface {}") -}}
          {{- $serviceTolerations = .root.Values.tolerations -}}
        {{- else if eq (typeOf .root.Values.tolerations) ("map[string]interface {}") -}}
          {{- $serviceTolerations = index .root.Values.tolerations .podbasename -}}
        {{- end -}}
      {{- end -}}
      {{- $result := list -}}
      {{- $nonMatchingItems := list -}}
      {{- $matchingItems := list -}}
      {{- range $globalItem := $globalTolerations -}}
        {{- $globalItemId := include "eric-lcm-package-repository-py.merge-tolerations.get-identifier" $globalItem -}}
        {{- range $serviceItem := $serviceTolerations -}}
          {{- $serviceItemId := include "eric-lcm-package-repository-py.merge-tolerations.get-identifier" $serviceItem -}}
          {{- if eq $serviceItemId $globalItemId -}}
            {{- $matchingItems = append $matchingItems $serviceItem -}}
          {{- end -}}
        {{- end -}}
      {{- end -}}
      {{- range $globalItem := $globalTolerations -}}
        {{- $globalItemId := include "eric-lcm-package-repository-py.merge-tolerations.get-identifier" $globalItem -}}
        {{- $matchCount := 0 -}}
        {{- range $matchItem := $matchingItems -}}
          {{- $matchItemId := include "eric-lcm-package-repository-py.merge-tolerations.get-identifier" $matchItem -}}
          {{- if eq $matchItemId $globalItemId -}}
            {{- $matchCount = add1 $matchCount -}}
          {{- end -}}
        {{- end -}}
        {{- if eq $matchCount 0 -}}
          {{- $nonMatchingItems = append $nonMatchingItems $globalItem -}}
        {{- end -}}
      {{- end -}}
      {{- range $serviceItem := $serviceTolerations -}}
        {{- $serviceItemId := include "eric-lcm-package-repository-py.merge-tolerations.get-identifier" $serviceItem -}}
        {{- $matchCount := 0 -}}
        {{- range $matchItem := $matchingItems -}}
          {{- $matchItemId := include "eric-lcm-package-repository-py.merge-tolerations.get-identifier" $matchItem -}}
          {{- if eq $matchItemId $serviceItemId -}}
            {{- $matchCount = add1 $matchCount -}}
          {{- end -}}
        {{- end -}}
        {{- if eq $matchCount 0 -}}
          {{- $nonMatchingItems = append $nonMatchingItems $serviceItem -}}
        {{- end -}}
      {{- end -}}
      {{- toYaml (concat $result $matchingItems $nonMatchingItems) -}}
  {{- else -}}
      {{- if .root.Values.tolerations -}}
        {{- if eq (typeOf .root.Values.tolerations) ("[]interface {}") -}}
          {{- toYaml .root.Values.tolerations -}}
        {{- else if eq (typeOf .root.Values.tolerations) ("map[string]interface {}") -}}
          {{- toYaml (index .root.Values.tolerations .podbasename) -}}
        {{- end -}}
      {{- end -}}
  {{- end -}}
{{- end -}}
{{/*
Helper function to get the identifier of a tolerations array element.
Assumes all keys except tolerationSeconds are used to uniquely identify
a tolerations array element.
*/}}
{{ define "eric-lcm-package-repository-py.merge-tolerations.get-identifier" }}
  {{- $keyValues := list -}}
  {{- range $key := (keys . | sortAlpha) -}}
    {{- if eq $key "effect" -}}
      {{- $keyValues = append $keyValues (printf "%s=%s" $key (index $ $key)) -}}
    {{- else if eq $key "key" -}}
      {{- $keyValues = append $keyValues (printf "%s=%s" $key (index $ $key)) -}}
    {{- else if eq $key "operator" -}}
      {{- $keyValues = append $keyValues (printf "%s=%s" $key (index $ $key)) -}}
    {{- else if eq $key "value" -}}
      {{- $keyValues = append $keyValues (printf "%s=%s" $key (index $ $key)) -}}
    {{- end -}}
  {{- end -}}
  {{- printf "%s" (join "," $keyValues) -}}
{{ end }}

{{/* 
Dir where secrets will be available
*/}}
{{- define "eric-lcm-package-repository-py.runsecret.dir" -}}
  /run/secrets/
{{- end -}}