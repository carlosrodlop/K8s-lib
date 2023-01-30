MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
#PARENT_MKFILE   := $(HOME)/.Makefile # docker
PARENT_MKFILE   := $(MKFILE)/../../../carlosrodlop/Makefile # local
DIR_TF_ROOT		:= $(MKFILE)/../../../terraform-labs/aws/root/aws
DIR_CHARTS 		:= $(MKFILE)/../../charts

include $(PARENT_MKFILE)

#DEFAULTS
CLOUD_TPL		?= eks.alb.yaml.tpl
HELM_DB_PORT	?= 8989

#https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable
.PHONY: check_kubeconfig
check_kubeconfig: ## Check for the required KUBECONFIG environment variable
check_kubeconfig:
#TODO check if KUBECONFIG file exists
ifndef KUBECONFIG
	@echo Warning: KUBECONFIG Environment variable isn\'t defined and it is required for helm\; Example: export KUBECONFIG=/path/to/kubeconfig.yaml
	@exit 1
endif

.PHONY: check_envfile
check_envfile: ## Check for the required KUBECONFIG environment variable
check_envfile:
ifneq ("$(wildcard .env)","")
else
	@echo Error .env file does not exist and it is required
	@exit 1
endif

.PHONY: helm-dashboard
helm-dashboard: ## Open Helm Dashboard
helm-dashboard:
	nohup helm dashboard --no-browser --port=$(HELM_DB_PORT) &

.PHONY: cbci-helm-update
cbci-helm-update: ## Install and Update CloudBees Core via Helm. It requires the file .env and KUBECTL environment variable
cbci-helm-update: check_kubeconfig check_envfile guard-CLOUD_TPL
	$(call print_subtitle,Update Casc values.yaml)
	source .env && \
		sed "s/<HOSTNAME>/$$HOSTNAME/g; \
			s/<PROTOCOL>/$$PROTOCOL/g; \
			s|<C_CASC_REPO>|$$C_CASC_REPO|g ; \
			s/<OC_BUNDLE>/$$OC_BUNDLE/g; \
			s/<SECRET_GH_TOKEN>/$$SECRET_GH_TOKEN/g; \
			s/<SECRET_GH_USER>/$$SECRET_GH_USER/g; \
			s/<SECRET_JENKINS_PASS>/$$SECRET_JENKINS_PASS/g;" < helm/values.cb-ci-casc.yaml.tpl > helm/values.cb-ci-casc.yaml && \
		helm upgrade --install cbci-casc $(DIR_CHARTS)/cb-ci-casc --create-namespace --namespace "$$CBCI_NS" -f "helm/values.cb-ci-casc.yaml"
	$(call print_subtitle,Update CloudBees values.yaml)
	source .env && \
		sed "s/<HOSTNAME>/$$HOSTNAME/g; \
			s/<PROTOCOL>/$$PROTOCOL/g; \
			s|<CERTIFICATE>|$(shell terraform -chdir=$(DIR_TF_ROOT) output --raw acm_certificate_arn)|g ; \
			s/<AGENT_NAMESPACE>/$$AGENT_NA/g;" < helm/cloud/$(CLOUD_TPL) > helm/values.cb-ci.yaml && \
		helm repo add cloudbees https://public-charts.artifacts.cloudbees.com/repository/public/ && \
		helm repo update && \
		helm upgrade --install cbci cloudbees/cloudbees-core --create-namespace --namespace "$$CBCI_NS" --version "$$CBCI_VERSION" -f "helm/values.cb-ci.yaml"


.PHONY: cbci-helm-delete
cbci-helm-delete: ## Delete CloudBees Core via Helm. It requires the file .env and KUBECTL environment variable
cbci-helm-delete: check_kubeconfig check_envfile
	$(call print_title,Uninstall CloudBees Core via Helm)
	source .env && \
		kubectl delete --all pods --grace-period=0 --force --namespace "$$CBCI_NS" && \
		kubectl delete --all pods --grace-period=0 --force --namespace "$$AGENT_NA" && \
		helm uninstall cbci-casc --namespace "$$CBCI_NS" || echo "Relese cbci-casc does not exist" && \
		helm uninstall cbci --namespace "$$CBCI_NS" || echo "Relese cbci does not exist" && \
		helm repo remove cloudbees || echo "Repository cloudbees does not exist" && \
		kubectl delete pvc --all --namespace "$$CBCI_NS" && \
		kubectl delete ns "$$AGENT_NA" || echo "There is NOT existing namespace $$AGENT_NA" && \
		kubectl delete ns "$$CBCI_NS" || echo "There is not existing namespace $$CBCI_NS"
