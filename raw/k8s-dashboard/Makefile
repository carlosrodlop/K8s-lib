MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
#PARENT_MKFILE   := $(HOME)/.Makefile # docker
PARENT_MKFILE   := $(MKFILE)/../../../carlosrodlop/Makefile # local

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
.PHONY: k8s_db-kubectl_update
k8s_db-eks-kubectl_update: ## Install K8s Dashboard in EKS
k8s_db-eks-kubectl_update: check_kubeconfig check_service-account_file

	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
	kubectl apply -f raw/k8s-dashboard/eks-admin
	kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

.PHONY: k8s_db-kubectl_delete
k8s_db-eks-kubectl_delete: ## Remove K8s Dashboard in EKS
k8s_db-eks-kubectl_delete: check_kubeconfig check_service-account_file

	kubectl delete -f raw/k8s-dashboard/eks-admin
	kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
