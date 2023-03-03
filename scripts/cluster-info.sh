#!/usr/bin/bash
set -euox pipefail

output_folder="/tmp/$(basename "$0")"
target_namespaces=(cbci cbci-agentsx)
mkdir "$output_folder" || echo "$output_folder already exists"
kubectl describe nodes --show-events=true > "$output_folder/nodes.txt"
kubectl top nodes > "$output_folder/top-nodes.txt"
kubectl cluster-info dump > "$output_folder/cluster.json"
for n in "${target_namespaces[@]}"
do
    existNamespace=$(kubectl get ns "$n" | grep -c "$n")
    if [ "$existNamespace" -eq 1 ]
    then
        kubectl get all -n "$n" -o wide > "$output_folder/get-all-$n.yaml"
        kubectl get events -n "$n" --sort-by='.lastTimestamp' > "$output_folder/get-events-$n.yaml"
        kubectl describe pod -n "$n" --show-events=true > "$output_folder/describe-pods-$n.yaml"
        kubectl -n "$n" top pods > "$output_folder/top-pods-$n.txt"
    else
        echo "Namespace $n does not exist" && exit 1
    fi
done
