MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile
DIR_HELM_VALUES := $(MKFILE)/../../../helm/values
DIR_MANIFEST 	:= $(MKFILE)/../../../manifest
DIR_TF_ROOT		:= $(MKFILE)/../../../../../clouds/aws/root/eks-bp-v4
DIR_CHARTS 		:= $(MKFILE)/../../../helm/charts

include $(PARENT_MKFILE)

.PHONY: chaos_enable
chaos_enable: ## Install Chaos in namespace passed in the values.yaml
chaos_enable: check_kubeconfig
	helm upgrade --install chaos-local $(DIR_CHARTS)/chaos-local --namespace chaos --create-namespace \
		--set kubeStresscheck.replicas=3

.PHONY: chaos_disable
chaos_disable: ## Remove Chaos
chaos_disable: check_kubeconfig
	helm uninstall chaos-local --namespace chaos || echo "Relese chaos does not exist"
