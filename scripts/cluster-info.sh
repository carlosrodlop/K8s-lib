#!/usr/bin/bash
set -euox pipefail

output_folder="/tmp/$(basename "$0")"
target_namespaces=(cbci cbci-agents)
oneshot=true
duration=10
frequency=5

validate() {
    #check if the directory can be written to by the user that is running the script
    touch "$output_folder/testFile.txt" 2>/dev/null
    if [ ! -f "$output_folder/testFile.txt" ]
    then
        echo "[ERROR]: This directory cannot be written to by the script" && exit 1
    fi
    rm -rf "$output_folder"
    mkdir -p "$output_folder"
    #vaidate that the target namespaces exist
    for n in "${target_namespaces[@]}"
    do
        existNamespace=$(kubectl get ns "$n" | grep -c "$n")
        if [ ! "$existNamespace" -eq 1 ]
        then
            echo "[ERROR]: Target namespace $n does not exist" && exit 1
        fi
    done
    #validate that the metrics server is installed
    if [ "$(kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes" 2>/dev/null | wc -l)" -eq 0 ]
    then
        echo "[ERROR]: Metrics server is not installed" && exit 1
    fi
}

execute() {
    kubectl describe nodes --show-events=true > "$output_folder/nodes.$(date +%Y%m%d_%H%M%S).yaml"
    kubectl top nodes > "$output_folder/top-nodes.$(date +%Y%m%d_%H%M%S).txt"
    for n in "${target_namespaces[@]}"
    do
        kubectl get all -n "$n" -o wide > "$output_folder/get-all-$n.$(date +%Y%m%d_%H%M%S).yaml"
        kubectl get events -n "$n" --sort-by='.lastTimestamp' > "$output_folder/get-events-$n.$(date +%Y%m%d_%H%M%S).txt"
        kubectl describe pod -n "$n" --show-events=true > "$output_folder/describe-pods-$n.$(date +%Y%m%d_%H%M%S).yaml"
        kubectl -n "$n" top pods > "$output_folder/top-pods-$n.$(date +%Y%m%d_%H%M%S).txt"
    done
}

validate

kubectl cluster-info dump > "$output_folder/cluster-info.$(date +%Y%m%d_%H%M%S).json"
while [ "$duration" -gt 0 ]
do
    execute
    if [ $oneshot ]; then break ; fi
    sleep $frequency
    #Update duration
    duration=$((duration - frequency))
done
