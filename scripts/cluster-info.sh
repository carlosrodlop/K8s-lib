#!/usr/bin/bash
set -euox pipefail

output_folder="/tmp/$(basename "$0"))"
target_namespaces=(cbci cbci-agents)
mkdir "$output_folder" || echo "$output_folder already exists"
kubectl describe nodes --show-events=true > "$output_folder/nodes.txt"
kubectl cluster-info dump > "$output_folder/cluster.json"
for n in "${target_namespaces[@]}"
do
    kubectl get ns "$n" || (echo "Namespace $n does not exist" && exit 1)
    kubectl get all -n "$n" -o wide > "$output_folder/get-all-$n.yaml"
    kubectl describe pod -n "$n" --show-events=true > "$output_folder/describe-pods-$n.yaml"
done
