#!/usr/bin/bash
# Ref: #https://stackoverflow.com/a/53661717
set -euox pipefail

NAMESPACE=$1
kubectl proxy & kubectl get namespace "$NAMESPACE" -o json | jq '.spec = {"finalizers":[]}' > /tmp/temp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @/tmp/temp.json "127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize"
