{{/* vim: set filetype=mustache: */}}
{{/*
Note: 
    We truncate at 63 chars where required,
    because some Kubernetes name fields are 
    limited to this length (by the DNS naming spec). 
*/}}

{{/* ............ Templates section ............ */}}

{{/* Define the name of this demo webserver */}}
{{- define "webserver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
    Create a default fully qualified app name.
    If release name contains chart name it will be used as a full name.
*/}}
{{- define "webserver.fullname" -}}
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
{{- define "webserver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "webserver.labels" -}}
helm.sh/chart: {{ include "webserver.chart" . }}
{{ include "webserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "webserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "webserver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}