{{/* vim: set filetype=mustache: */}}

{{/*
Get log shipper streaming method
*/}}

{{- define "eric-lcm-package-repository-py.log-streamingMethod" -}}
  {{- $streamingMethod := "indirect" -}}
  {{- if ((.Values.log).streamingMethod) -}}
    {{- $streamingMethod = .Values.log.streamingMethod -}}
  {{- else if (((.Values.global).log).streamingMethod) -}}
    {{- $streamingMethod = .Values.global.log.streamingMethod -}}
  {{- else if ((.Values.log).outputs) -}}
    {{- if and (has "stdout" .Values.log.outputs) (has "stream" .Values.log.outputs) -}}
    {{- $streamingMethod = "dual" -}}
    {{- else if has "stream" .Values.log.outputs -}}
    {{- $streamingMethod = "direct" -}}
    {{- else if has "stdout" .Values.log.outputs -}}
    {{- $streamingMethod = "indirect" -}}
    {{- end -}}
  {{- else if (((.Values.global).log).outputs) -}}
    {{- if and (has "stdout" .Values.global.log.outputs) (has "stream" .Values.global.log.outputs) -}}
    {{- $streamingMethod = "dual" -}}
    {{- else if has "stream" .Values.global.log.outputs -}}
    {{- $streamingMethod = "direct" -}}
    {{- else if has "stdout" .Values.global.log.outputs -}}
    {{- $streamingMethod = "indirect" -}}
    {{- end -}}
  {{- end -}}
  {{- printf "%s" $streamingMethod -}}
{{- end -}}

{{/*
Logshipper redirect mode
*/}}
{{- define "eric-lcm-package-repository-py.log-redirect" -}}
{{- $streamingMethod := (include "eric-lcm-package-repository-py.log-streamingMethod" .) -}}
{{- if eq $streamingMethod "dual" -}}
  {{- "all" -}}
{{- else if eq $streamingMethod "direct" -}}
  {{- "file" -}}
{{- else -}}
  {{- "stdout" -}}
{{- end -}}
{{- end -}}

{{/*
Check if log shipper stream output is enabled
*/}}
{{- define "eric-lcm-package-repository-py.log-streaming-activated" }}
  {{- $streamingMethod := (include "eric-lcm-package-repository-py.log-streamingMethod" .) -}}
  {{- if or (eq $streamingMethod "dual") (eq $streamingMethod "direct") -}}
    {{- printf "%t" true -}}
  {{- else -}}
    {{- printf "%t" false -}}
  {{- end -}}
{{- end -}}
