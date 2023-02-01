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

.PHONY: check_service-account_file
check_service-account_file: ## Check for the required KUBECONFIG environment variable
check_service-account_file:
ifneq ("$(wildcard eks-admin-service-account.yaml)","")
else
	@echo Error eks-admin-service-account file does not exist and it is required
	@exit 1
endif

.PHONY: k8s_db-kubectl_update
k8s_db-kubectl_update: ## Install and Update CloudBees Core via Helm.
k8s_db-kubectl_update: check_kubeconfig check_service-account_file

	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
	kubectl apply -f raw/k8s-dashboard/eks-admin
	kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

.PHONY: k8s_db-kubectl_delete
k8s_db-kubectl_delete: ## Delete CloudBees Core via Helm.
k8s_db-kubectl_delete: check_kubeconfig check_service-account_file

	kubectl delete -f raw/k8s-dashboard/eks-admin
	kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.0/aio/deploy/recommended.yaml
