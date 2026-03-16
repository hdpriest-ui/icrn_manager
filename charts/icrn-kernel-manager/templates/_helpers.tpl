{{/*
Common labels applied to all resources.
*/}}
{{- define "icrn.labels" -}}
app.kubernetes.io/name: icrn-kernel-manager
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Fully-qualified image reference.
Usage: {{ include "icrn.image" (dict "root" . "image" .Values.image.webserver) }}
*/}}
{{- define "icrn.image" -}}
{{- $reg := .root.Values.image.registry -}}
{{- if $reg -}}
{{ $reg }}/{{ .image.repository }}:{{ .image.tag }}
{{- else -}}
{{ .image.repository }}:{{ .image.tag }}
{{- end }}
{{- end }}

{{/*
PVC name for the kernels volume — uses existingClaim if provided, otherwise chart-managed name.
*/}}
{{- define "icrn.kernelsPvcName" -}}
{{- if .Values.persistence.kernels.existingClaim -}}
{{ .Values.persistence.kernels.existingClaim }}
{{- else -}}
{{ .Release.Name }}-kernels-pvc
{{- end }}
{{- end }}

{{/*
PVC name for the index files volume — uses existingClaim if provided, otherwise chart-managed name.
*/}}
{{- define "icrn.indexFilesPvcName" -}}
{{- if .Values.persistence.indexFiles.existingClaim -}}
{{ .Values.persistence.indexFiles.existingClaim }}
{{- else -}}
{{ .Release.Name }}-indexfiles-pvc
{{- end }}
{{- end }}

{{/*
Indexer pod spec — shared between CronJob and post-deploy hook Job.
Usage: {{- include "icrn.indexerPodSpec" . | nindent N }}
where N matches the indentation level of the enclosing pod spec block.
*/}}
{{- define "icrn.indexerPodSpec" -}}
serviceAccountName: icrn-indexer
securityContext:
  seccompProfile:
    type: RuntimeDefault
  fsGroup: {{ .Values.indexer.fsGroup }}
  supplementalGroups:
    - {{ .Values.indexer.fsGroup }}
containers:
  - name: kernel-indexer
    image: {{ include "icrn.image" (dict "root" . "image" .Values.image.indexer) }}
    imagePullPolicy: Always
    securityContext:
      allowPrivilegeEscalation: false
      runAsNonRoot: true
      runAsUser: 1000
      capabilities:
        drop:
          - ALL
    env:
      - name: KERNEL_ROOT
        value: "/app/kernels"
      - name: KERNEL_ROOT_HOST
        value: {{ .Values.persistence.kernels.hostPath | quote }}
      - name: OUTPUT_DIR
        value: "/app/data"
    volumeMounts:
      - name: kernels-data
        mountPath: /app/kernels
      - name: index-files
        mountPath: /app/data
    resources:
      {{- toYaml .Values.indexer.resources | nindent 6 }}
    livenessProbe:
      exec:
        command:
          - /bin/sh
          - -c
          - test -f /tmp/indexer.running || exit 1
      initialDelaySeconds: 60
      periodSeconds: 300
volumes:
  - name: kernels-data
    persistentVolumeClaim:
      claimName: {{ include "icrn.kernelsPvcName" . }}
  - name: index-files
    persistentVolumeClaim:
      claimName: {{ include "icrn.indexFilesPvcName" . }}
restartPolicy: Never
{{- end }}
