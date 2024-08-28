{{/*
  Define chart global default values.
*/}}
{{- define "eric-lcm-package-repository-py.globalDefaultValues" -}}
nodeSelector: {}
pullSecret:
registry:
  url:
  repoPath:
  imagePullPolicy:
timezone: UTC
internalIPFamily:
securityPolicy:
  rolekind: Role
adpBR:
  broServiceName: eric-ctrl-bro
  broGrpcServicePort: 3000
  brLabelKey: adpbrlabelkey
security:
  tls:
    # Enables/Disables tls intra-cluster communication. Requires SIP-TLS.
    enabled: true
    trustedInternalRootCa:
      secret: eric-sec-sip-tls-trusted-root-cert
  policyBinding:
    create:
  policyReferenceMap:
    default-restricted-security-policy:
metrics:
  # PM Server deployment name
  serviceReference: eric-pm-server

ingress:
  # Ingress Controller CR deployment name
  serviceReference: eric-tm-ingress-controller-cr
  ingressClass:
{{- end -}}


{{/*
  Merge all chart global values in a single object.

  It merges default values with global values
  from integration chart. Additional components
  can contribute with theirs own global default values.
*/}}
{{- define "eric-lcm-package-repository-py.global" -}}
  {{- $globalDefaults := fromYaml ( include "eric-lcm-package-repository-py.globalDefaultValues" . ) -}}

  {{- if .Values.global -}}
    {{- toYaml ( mergeOverwrite $globalDefaults .Values.global ) -}}
  {{- else -}}
    {{- toYaml ( $globalDefaults ) -}}
  {{- end -}}
{{- end -}}
