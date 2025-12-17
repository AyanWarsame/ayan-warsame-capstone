{{/*
Expand the name of the chart.
*/}}
{{- define "ayan-warsame-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "ayan-warsame-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ayan-warsame-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ayan-warsame-app.labels" -}}
helm.sh/chart: {{ include "ayan-warsame-app.chart" . }}
{{ include "ayan-warsame-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ayan-warsame-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ayan-warsame-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "ayan-warsame-app.frontend.selectorLabels" -}}
app: frontend
component: frontend
{{ include "ayan-warsame-app.selectorLabels" . }}
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "ayan-warsame-app.backend.selectorLabels" -}}
app: backend
component: backend
{{ include "ayan-warsame-app.selectorLabels" . }}
{{- end }}

