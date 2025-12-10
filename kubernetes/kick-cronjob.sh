#!/bin/bash

# Manually trigger the ICRN kernel indexer cronjob
# Usage: ./kick-cronjob.sh

NAMESPACE="kernels"
CRONJOB_NAME="icrn-kernel-indexer"
JOB_NAME="${CRONJOB_NAME}-manual-$(date +%s)"

echo "Deleting old jobs from cronjob '${CRONJOB_NAME}'..."

# Delete all old jobs (both from cronjob and manual runs)
kubectl get jobs -n "${NAMESPACE}" -o name | grep "${CRONJOB_NAME}" | xargs -r kubectl delete -n "${NAMESPACE}" --wait=true

echo "Triggering cronjob '${CRONJOB_NAME}' in namespace '${NAMESPACE}'..."

# Create a job from the cronjob template
kubectl create job "${JOB_NAME}" \
  --from=cronjob/"${CRONJOB_NAME}" \
  -n "${NAMESPACE}"

if [ $? -eq 0 ]; then
  echo "✓ Job '${JOB_NAME}' created successfully"
  echo ""
  echo "Monitor the job with:"
  echo "  kubectl logs -f job/${JOB_NAME} -n ${NAMESPACE}"
  echo ""
  echo "View job status:"
  echo "  kubectl get job ${JOB_NAME} -n ${NAMESPACE}"
else
  echo "✗ Failed to create job"
  exit 1
fi
