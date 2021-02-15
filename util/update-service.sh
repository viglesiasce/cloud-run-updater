#!/bin/bash -xe

# Convert service definition to JSON to uploaded via cURL
kubectl get services.serving.knative.dev cs-redirector -o yaml > service.yaml
# Skaffold set BOTH the tag and the sha (which is valid for k8s but not Cloud Run)
IMAGE=$(yq eval '.spec.template.spec.containers[0].image' service.yaml | cut -d':' -f1)
SHA=$(yq eval '.spec.template.spec.containers[0].image' service.yaml | cut -d':' -f3)
yq eval 'del(.metadata)' service.yaml | \
yq eval ".spec.template.spec.containers[0].image = \"$IMAGE@sha256:${SHA}\"" - | \
yq eval '.metadata.name = "cs-redirector"' - | \
yq eval -j - > service.json 

TOKEN=$(gcloud auth application-default print-access-token)
curl -H "Content-Type: application/json" -H "Authorization: Bearer ${TOKEN}" -X PUT \
    https://us-west1-run.googleapis.com/apis/serving.knative.dev/v1/namespaces/vicnastea/services/cs-redirector \
    -d @service.json
kubectl delete job update-service