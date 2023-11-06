MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile
DIR_HELMFILES 	:= $(MKFILE)/../../helmfile
HELM_LOG_PATH 	:= $(MKFILE)/helm.log

include $(PARENT_MKFILE)

define postHelmDelete
	helm repo remove cloudbees || echo "Repository cloudbees does not exist"
	kubectl delete --all pvc --grace-period=0 --force --namespace "cbci"
	kubectl delete --all pvc --grace-period=0 --force --namespace "cbcd"
	kubectl delete ns "cbci-agents" || echo "There is NOT existing namespace cbci-agents"
	kubectl delete ns "cbci" || echo "There is not existing namespace cbci"
	kubectl delete ns "cbcd" || echo "There is not existing namespace cbcd"
endef

.PHONY: helmfile-update
helmfile-update: ## Install/Update CloudBees Core Modern via Helmfile.
helmfile-update: check_kubeconfig
	@rm -f $(HELM_LOG_PATH)
	helmfile --debug --file $(DIR_HELMFILES)/sda.eks.alb.helmfile.yml --interactive apply | tee -a $(HELM_LOG_PATH)

.PHONY: purge_pods
purge_pods:
purge_pods: #Purge Pods in cbci and cbci-agents namespaces
	kubectl delete --all pods --grace-period=0 --force --namespace "cbcd"
	kubectl delete --all pods --grace-period=0 --force --namespace "cbci"
	kubectl delete --all pods --grace-period=0 --force --namespace "cbci-agents"

.PHONY: helmfile-delete
helmfile-delete: ## Helmfile Delete
helmfile-delete: check_kubeconfig purge_pods
	@rm -f $(HELM_LOG_PATH)
	helmfile --debug --file $(DIR_HELMFILES)/sda.eks.alb.helmfile.yml destroy | tee -a $(HELM_LOG_PATH)
	$(call postHelmDelete)
