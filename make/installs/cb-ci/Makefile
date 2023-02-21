MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile # docker
#PARENT_MKFILE   := $(MKFILE)/../../../carlosrodlop/Makefile # local
DIR_TF_ROOT		:= $(MKFILE)/../../../../clouds/aws/root/eks-bp-v4
DIR_CHARTS 		:= $(MKFILE)/../../../helm/charts
DIR_HELM_VALUES := $(MKFILE)/../../../helm/values
CI_OC_URL		:= https://ci.crl.core.pscbdemos.com/cjoc/


include $(PARENT_MKFILE)

#DEFAULTS
CLOUD_TPL		?= cb-ci.eks.nginx.nlp.yaml

#https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable
.PHONY: check_kubeconfig
check_kubeconfig: ## Check for the required KUBECONFIG environment variable
check_kubeconfig:
#TODO check if KUBECONFIG file exists
ifndef KUBECONFIG
	@echo Warning: KUBECONFIG Environment variable isn\'t defined and it is required for helm\; Example: export KUBECONFIG=/path/to/kubeconfig.yaml
	@exit 1
endif
ifneq ("$(wildcard $(KUBECONFIG))","")
else
	@echo Error $(KUBECONFIG) file does not exist and it is required
	@exit 1
endif

.PHONY: check_envfile
check_envfile: ## Check for the required .env file
check_envfile:
ifneq ("$(wildcard .env)","")
else
	@echo Error .env file does not exist and it is required
	@exit 1
endif

define getTFValue
	terraform -chdir=$(DIR_TF_ROOT) output --raw $(1)
endef

.PHONY: cbci-helm-update
cbci-helm-update: ## Install and Update CloudBees Core via Helm.
cbci-helm-update: check_kubeconfig check_envfile guard-CLOUD_TPL
	$(call print_subtitle,Update Casc values.yaml)
	source .env && \
		sed "s/\$${hostname}/$$HOSTNAME/g; \
			s/\$${protocol}/$$PROTOCOL/g; \
			s|\$${c_casc_repo}|$$C_CASC_REPO|g ; \
			s/\$${ingressClass}/$$ING_CLASS/g; \
			s/\$${secretGHToken}/$$SECRET_GH_TOKEN/g; \
			s/\$${secretGHUser}/$$SECRET_GH_USER/g; \
			s/\$${nLoadControllers}/$$N_LOAD_CONTROLLERS/g; \
			s/\$${agentNamespace}/$$AGENT_NA/g;" < $(DIR_HELM_VALUES)/cb-ci-casc.yaml > $(MKFILE)/values.cb-ci-casc.yaml && \
		helm upgrade --install cbci-casc $(DIR_CHARTS)/cb-ci-casc --create-namespace --namespace "$$CBCI_NS" -f "$(MKFILE)/values.cb-ci-casc.yaml"
	$(call print_subtitle,Update CloudBees values.yaml)
	sed "/#Common_Configuration/e cat $(DIR_HELM_VALUES)/$(CLOUD_TPL)" < $(DIR_HELM_VALUES)/cb-ci.common.yaml > /tmp/values.tmp.cb-ci.yaml
	source .env && \
		sed "s/\$${hostname}/$$HOSTNAME/g; \
			s/\$${protocol}/$$PROTOCOL/g; \
			s/\$${LicFirstName}/$$LIC_FIRSTNAME/g; \
			s/\$${LicLastName}/$$LIC_LASTNAME/g; \
			s/\$${LicEmail}/$$LIC_MAIL/g; \
			s/\$${LicCompany}/$$LIC_COMPANY/g; \
			s|\$${cert_arn}|$(call getTFValue,acm_certificate_arn)|g ; \
			s/\$${agentNamespace}/$$AGENT_NA/g;" < /tmp/values.tmp.cb-ci.yaml > $(MKFILE)/values.cb-ci.yaml && \
		helm repo add cloudbees https://public-charts.artifacts.cloudbees.com/repository/public/ && \
		helm repo update && \
		helm upgrade --install cbci cloudbees/cloudbees-core --create-namespace --namespace "$$CBCI_NS" --version "$$CBCI_VERSION" -f "$(MKFILE)/values.cb-ci.yaml"
	kubectl rollout status sts cjoc --namespace cbci && wait
	kubectl get secret oc-secrets -n cbci -o jsonpath='{.data.jenkinsPass}' | base64 --decode > $(MKFILE)/secret.jenkinsPass

.PHONY: check_availability
check_availability:
check_availability: ## Check availability of the OC
	source .env && \
		until kubectl get ing -n $$CBCI_NS cjoc; do sleep 2 && echo "Waiting for Ingress to get ready"; done
	echo "Ingress Ready"		
	until curl -u admin:$(shell cat $(MKFILE)/secret.jenkinsPass) -s $(CI_OC_URL)  > /dev/null; do sleep 10 && echo "Waiting for Operation Center"; done
	echo "Operation Center Ready"

.PHONY: cbci-helm-delete
cbci-helm-delete: ## Delete CloudBees Core via Helm. Ref: https://docs.cloudbees.com/docs/cloudbees-ci/latest/kubernetes-install-guide/kubernetes-uninstall
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