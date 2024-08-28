{{/*
  Define the role reference for security policy
*/}}
{{- define "eric-lcm-package-repository-py.securityPolicy.reference" -}}
{{- $global := fromYaml ( include "eric-lcm-package-repository-py.global" . ) -}}
{{- index $global.security.policyReferenceMap "default-restricted-security-policy" | default "default-restricted-security-policy" | quote }}
{{- end -}}
