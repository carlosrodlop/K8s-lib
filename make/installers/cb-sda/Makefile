MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile # docker
DIR_TF_ROOT		:= $(MKFILE)/../../../../../clouds/aws/root/eks-bp-v4
DIR_CHARTS 		:= $(MKFILE)/../../../helm/charts
DIR_HELM_VALUES := $(MKFILE)/../../../helm/values/cloudbees

include $(PARENT_MKFILE)

# Default Ingress Configuration to ALB in EKS AWS
CB_LB_CONFIG	?= cb-ci.eks.alb.yaml
# Default OC URL using subdomains
#OC_URL 	        ?= source .env && echo "$(PROTOCOL)://cjoc.$(HOSTNAME)"
OC_URL 	        ?= https://cjoc.crl.core.pscbdemos.com

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

define JenkinsCLI
	@if [ \! -f /tmp/jenkins-cli.jar ]; then curl -o /tmp/jenkins-cli.jar "$(OC_URL)/jnlpJars/jenkins-cli.jar"; fi
	@echo "Jenkins CLI: $(1)"
	@java -jar /tmp/jenkins-cli.jar -s $(OC_URL) -auth admin:$(shell cat $(MKFILE)/secret.jenkinsPass) -webSocket $(1)
endef

define getTFValue
	$(shell terraform -chdir=$(DIR_TF_ROOT) output --raw $(1))
endef

.PHONY: check_envfile
check_envfile: ## Check for the required .env file
check_envfile:
ifneq ("$(wildcard .env)","")
else
	@echo Error .env file does not exist and it is required
	@exit 1
endif

.PHONY: cbci-helm-update
cbci-helm-update: ## Install and Update CloudBees Core Modern via Helm.
cbci-helm-update: check_kubeconfig check_envfile guard-CB_LB_CONFIG
	$(call print_subtitle,Update Casc values.yaml)
	@source .env && \
		sed "s/\$${hostname}/$$HOSTNAME/g; \
			s/\$${protocol}/$$PROTOCOL/g; \
			s|\$${c_casc_repo}|$$C_CASC_REPO|g ; \
			s/\$${ingressClass}/$$ING_CLASS/g; \
			s/\$${secretGHToken}/$$SECRET_GH_TOKEN/g; \
			s/\$${secretGHUser}/$$SECRET_GH_USER/g; \
			s/\$${agentNamespace}/$$AGENT_NA/g;" < $(DIR_HELM_VALUES)/cb-ci-local.yaml > $(MKFILE)/values.cb-ci-local.yaml
	source .env && \
		helm upgrade --install cbci-local $(DIR_CHARTS)/cb-ci-local --create-namespace --namespace "$$CBCI_NS" -f "$(MKFILE)/values.cb-ci-local.yaml"
	$(call print_subtitle,Update CloudBees values.yaml using $(CB_LB_CONFIG))
	sed "/#Common_Configuration/e cat $(DIR_HELM_VALUES)/$(CB_LB_CONFIG)" < $(DIR_HELM_VALUES)/cb-ci.common.yaml > /tmp/values.tmp.cb-ci.yaml
	@source .env && \
		sed "s/\$${hostname}/$$HOSTNAME/g; \
			s/\$${protocol}/$$PROTOCOL/g; \
			s/\$${LicFirstName}/$$LIC_FIRSTNAME/g; \
			s/\$${LicLastName}/$$LIC_LASTNAME/g; \
			s/\$${LicEmail}/$$LIC_MAIL/g; \
			s/\$${LicCompany}/$$LIC_COMPANY/g; \
			s|\$${cert_arn}|$(call getTFValue,acm_certificate_arn)|g ; \
			s/\$${agentNamespace}/$$AGENT_NA/g;" < /tmp/values.tmp.cb-ci.yaml > $(MKFILE)/values.cb-ci.yaml
	helm repo add cloudbees https://public-charts.artifacts.cloudbees.com/repository/public/ && helm repo update
	source .env && \
		helm upgrade --install cbci cloudbees/cloudbees-core --create-namespace --namespace "$$CBCI_NS" --version "$$CBCI_VERSION" -f "$(MKFILE)/values.cb-ci.yaml"
	kubectl rollout status sts cjoc --namespace cbci && wait
	@kubectl get secret oc-secrets -n cbci -o jsonpath='{.data.jenkinsPass}' | base64 --decode > $(MKFILE)/secret.jenkinsPass

.PHONY: check_availability
check_availability: ## Check availability of the OC Example: make check_availability OC_URL=https://cjoc.ci.crl.core.pscbdemos.com/
check_availability: guard-OC_URL
	source .env && \
		until kubectl get ing -n $$CBCI_NS cjoc; do sleep 2 && echo "Waiting for Ingress to get ready"; done
	@echo "Ingress Ready"
	@until curl -u admin:$(shell cat $(MKFILE)/secret.jenkinsPass) -s $(OC_URL)  > /dev/null; do sleep 10 && echo "Waiting for Operation Center at $(OC_URL)"; done
	@echo "Operation Center Ready at $(OC_URL)"

.PHONY: update_casc
update_casc: ## Update Configuration as Code
update_casc: guard-OC_URL cbci-helm-update
	$(call JenkinsCLI,casc-check-out-bundles)
	$(call JenkinsCLI,build admin/restart-all-controllers)
	$(call JenkinsCLI,restart)

.PHONY: cbci-helm-delete
cbci-helm-delete: ## Delete CloudBees Core Modern via Helm. Ref: https://docs.cloudbees.com/docs/cloudbees-ci/latest/kubernetes-install-guide/kubernetes-uninstall
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
