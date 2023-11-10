MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
CI_MAKEFOLDER   := $(MKFILE)/../cbci
CD_MAKEFOLDER   := $(MKFILE)/../cbcd
PARENT_MKFILE   := $(HOME)/.Makefile
DIR_HELMFILES 	:= $(MKFILE)/../../helmfile
HELM_LOG_PATH 	:= $(MKFILE)/helm.log

include $(PARENT_MKFILE)

.PHONY: helmfile-update
helmfile-update: ## Install/Update CloudBees Core Modern via Helmfile.
helmfile-update:
	@rm -f $(HELM_LOG_PATH)
	cd $(CD_MAKEFOLDER) && make cdCreateDBRemotely
	helmfile --debug --file $(DIR_HELMFILES)/sda.eks.alb.helmfile.yml --interactive apply | tee -a $(HELM_LOG_PATH)

.PHONY: helmfile-delete
helmfile-delete: ## Helmfile Delete
helmfile-delete: check_kubeconfig
	@rm -f $(HELM_LOG_PATH)
	cd $(CI_MAKEFOLDER) && make ciHelm-delete
	cd $(CD_MAKEFOLDER) && make cdDeleteAllDBRemote
	helmfile --debug --file $(DIR_HELMFILES)/sda.eks.alb.helmfile.yml destroy | tee -a $(HELM_LOG_PATH)
