{{/*
  Predefined ICCR Service Annotations.
*/}}
{{- define "eric-lcm-package-repository-py.iccrPredefinedServiceAnnotations" -}}
{{- if .Values.service.maxConnections }}
projectcontour.io/max-connections: {{ .Values.service.maxConnections | quote }}
{{- end -}}
{{- if .Values.service.maxPendingRequests }}
projectcontour.io/max-pending-requests: {{ .Values.service.maxPendingRequests | quote }}
{{- end -}}
{{- if .Values.service.maxRequests }}
projectcontour.io/max-requests: {{ .Values.service.maxRequests | quote }}
{{- end }}
{{- end -}}


{{/*
  Predefined ICCR HTTPProxy Annotations.
*/}}
{{- define "eric-lcm-package-repository-py.iccrPredefinedHttpProxyAnnotations" -}}
{{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
{{- if .Values.ingress.ingressClass }}
    kubernetes.io/ingress.class: {{ .Values.ingress.ingressClass | quote }}
{{- else if $global.ingress.ingressClass }}
    kubernetes.io/ingress.class: {{ $global.ingress.ingressClass | quote }}
{{- end }}
{{- end -}}


{{/*
  Effective ICCR HTTPProxy annotations.
*/}}
{{- define "eric-lcm-package-repository-py.iccrHttpProxyAnnotations" -}}
  {{- $httpProxyValues := include "eric-lcm-package-repository-py.iccrPredefinedHttpProxyAnnotations" . | fromYaml -}}
  {{- $annotationsFromValues := .Values.ingress.annotations -}}
  {{- $config := include "eric-lcm-package-repository-py.annotations" . | fromYaml -}}
  {{- include "eric-lcm-package-repository-py.mergeAnnotations" (dict "location" .Template.Name "sources" (list $httpProxyValues $annotationsFromValues $config)) | trim }}
{{- end -}}


{{/*
  Defines Ingress CA certificate secret contributor for webserver.
  Item of the Certificate Context truststore.items to be included in the webserver truststore.
  Required Scope: default chart context
*/}}
{{- define "eric-lcm-package-repository-py.iccrWebWebServerTrustCACertContributor" -}}
{{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
  {{- if .Values.ingress.enabled -}}
ingress:
  secretName: {{ .Values.ingress.serviceReference }}-client-ca
  {{- else if $global.ingress.ingressClass -}}
ingress:
  secretName: {{ $global.ingress.serviceReference }}-client-ca
  {{- end -}}
{{- end -}}
