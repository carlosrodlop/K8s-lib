MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DIR_HELM_VALUES := $(MKFILE)/../../../helm/values
DIR_MANIFEST := $(MKFILE)/../../../manifest

#https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable
.PHONY: check_kubeconfig
check_kubeconfig: ## Check for the required KUBECONFIG environment variable
check_kubeconfig:
ifndef KUBECONFIG
	@echo Warning: KUBECONFIG Environment variable isn\'t defined and it is required for helm\; Example: export KUBECONFIG=/path/to/kubeconfig.yaml
	@exit 1
endif

.PHONY: asdf_ubuntu
asdf_ubuntu: ## Install K8s Dashboard in EKS
asdf_ubuntu: check_kubeconfig

	kubectl apply -f $(DIR_MANIFEST)/asdf.ubuntu.pod.yaml

.PHONY: asdf_ubuntu
asdf_ubuntu: ## Remove K8s Dashboard in EKS
asdf_ubuntu: check_kubeconfig

	kubectl delete -f
