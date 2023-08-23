#!/usr/bin/bash
set -euox pipefail

namespace_name="namespace-example"
pod_name="jenkins-example-0"
watch -n1 "echo 'NODES\n'; kubectl top nodes; echo '\n\n' ; \
    echo 'PODS\n'; kubectl -n ${namespace_name} top pods; echo '\n\n'; \
echo 'CONTAINERS\n'; kubectl -n ${namespace_name} top pod ${pod_name} --containers"
