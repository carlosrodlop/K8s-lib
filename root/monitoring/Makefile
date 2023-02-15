MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile # docker
#PARENT_MKFILE   := $(MKFILE)/../../../carlosrodlop/Makefile # local

include $(PARENT_MKFILE)

#https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable
.PHONY: check_kubeconfig
check_kubeconfig: ## Check for the required KUBECONFIG environment variable
check_kubeconfig:
ifndef KUBECONFIG
	@echo Warning: KUBECONFIG Environment variable isn\'t defined and it is required for helm\; Example: export KUBECONFIG=/path/to/kubeconfig.yaml
	@exit 1
endif

#https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html#view-dashboard
.PHONY: k8s_db-eks_update
k8s_db-eks_update: ## Install K8s Dashboard in EKS
k8s_db-eks_update: check_kubeconfig

	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
	kubectl apply -f K8s-manifest/eks-admin
	kubectl -n kube-system describe secret $(shell kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

.PHONY: k8s_db-eks_delete
k8s_db-eks_delete: ## Remove K8s Dashboard in EKS
k8s_db-eks_delete: check_kubeconfig

	kubectl delete -f K8s-manifest/eks-admin
	kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml


.PHONY: komodor_update
komodor_update: ## Install Komodor Agent passing KOMODOR_API_KEY and CLUSTER_NAME (enabing Helm Dashboard)
komodor_update: check_kubeconfig
	helm repo add komodorio https://helm-charts.komodor.io && helm repo update
	source .env && \
		helm upgrade --install k8s-watcher komodorio/k8s-watcher --create-namespace --namespace "$$MONITORING_NS" \
			--set apiKey=$$KOMODOR_API_KEY \
			--set watcher.clusterName=$$CLUSTER_NAME \
			--set watcher.allowReadingPodLogs=true \
			--set watcher.enableAgentTaskExecution=true \
			--set watcher.enableAgentTaskExecutionV2=true \
			--set watcher.enableHelm=true \
			--set watcher.resources.secret=true \
			--set watcher.actions.basic=true \
			--set watcher.actions.advanced=true \
			--set watcher.actions.podExec=true \
			--reuse-values \
			--set helm.enableActions=true --wait --timeout=90s

.PHONY: komodor_delete
komodor_delete: ## Delete Komodor Agent
komodor_delete: check_kubeconfig
	source .env && \
		helm uninstall k8s-watcher --namespace "$$MONITORING_NS" || echo "Relese k8s-watcher does not exist" && \
		helm repo remove komodorio || echo "Repository ckomodorio does not exist"
