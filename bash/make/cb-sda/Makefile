MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile
DIR_TF_ROOT		:= $(MKFILE)/../../../../../clouds/aws/root/tmp
DIR_CHARTS 		:= $(MKFILE)/../../../helm/charts
DIR_HELM_VALUES := $(MKFILE)/../../../helm/values/cloudbees

include $(PARENT_MKFILE)

CB_LB_CONFIG	:= $(shell echo $(call getEnvProperty,CB_LB_CONFIG))
PROTOCOL		:= $(shell echo $(call getEnvProperty,PROTOCOL))
HOSTNAME		:= $(shell echo $(call getEnvProperty,HOSTNAME))
SUBDOMAIN		:= $(shell echo $(call getEnvProperty,SUBDOMAIN))
ifeq ($(SUBDOMAIN),true)
OC_URL := $(PROTOCOL)://cjoc.$(HOSTNAME)
else
OC_URL := $(PROTOCOL)://$(HOSTNAME)/cjoc
endif

define JenkinsCLI
	@#revision=$(shell helm ls -n cbci | grep cbci-local | awk '{ print $3 }')
	@if [ \! -f /tmp/jenkins-cli.jar ]; then curl -o /tmp/jenkins-cli.jar "$(OC_URL)/jnlpJars/jenkins-cli.jar"; fi
	@echo "Jenkins CLI: $(1)"
	@source .env && \
		java -jar /tmp/jenkins-cli.jar -s $(OC_URL) -auth $$ADMIN_JENKINS_USER:$$SECRET_JENKINS_PASS -webSocket $(1)
endef

.PHONY: cbci-helm-update-simple
cbci-helm-update-simple: ## Simple Install and Update CloudBees Core Modern via Helm.
cbci-helm-update-simple: check_kubeconfig check_envfile guard-CB_LB_CONFIG
	$(call print_subtitle,Simple Update CloudBees values.yaml using $(CB_LB_CONFIG))
	sed "/OperationsCenter:/d" < $(DIR_HELM_VALUES)/cb-ci.common.simple.yaml > /tmp/values.tmp.cb-ci.yaml
	sed -i "/#Common_Configuration/e cat $(DIR_HELM_VALUES)/$(CB_LB_CONFIG)" /tmp/values.tmp.cb-ci.yaml
	@source .env && \
		sed "s/\$${hostname}/$$HOSTNAME/g; \
			s/\$${protocol}/$$PROTOCOL/g; \
			s/\$${subdomain}/$$SUBDOMAIN/g; \
			s/\$${LicFirstName}/$$LIC_FIRSTNAME/g; \
			s/\$${LicLastName}/$$LIC_LASTNAME/g; \
			s/\$${LicEmail}/$$LIC_MAIL/g; \
			s/\$${LicCompany}/$$LIC_COMPANY/g; \
			s|\$${cert_arn}|$$CERTIFICATE_ID|g ;" < /tmp/values.tmp.cb-ci.yaml > $(MKFILE)/values.cb-ci.yaml
	helm repo add cloudbees https://public-charts.artifacts.cloudbees.com/repository/public/ && helm repo update
	source .env && \
		helm upgrade --install cbci cloudbees/cloudbees-core --create-namespace --namespace "$$CBCI_NS" --version "$$CBCI_VERSION" -f "$(MKFILE)/values.cb-ci.yaml"
	kubectl rollout status sts cjoc --namespace cbci && wait

.PHONY: cbci-helm-update-advance
cbci-helm-update-advance: ## Advance Install and Update CloudBees Core Modern via Helm. Casc and Local Helm Chart
cbci-helm-update-advance: check_kubeconfig check_envfile guard-CB_LB_CONFIG
	$(call print_subtitle,Advance Update Casc values.yaml)
	@source .env && \
		sed "s/\$${hostname}/$$HOSTNAME/g; \
			s/\$${protocol}/$$PROTOCOL/g; \
			s|\$${c_casc_repo}|$$C_CASC_REPO|g ; \
			s/\$${ingressClass}/$$ING_CLASS/g; \
			s/\$${secretGHToken}/$$SECRET_GH_TOKEN/g; \
			s/\$${secretGHUser}/$$SECRET_GH_USER/g; \
			s/\$${secretJenkins}/$$SECRET_JENKINS_PASS/g; \
			s/\$${agentNamespace}/$$AGENT_NA/g; \
			s|\$${agentRegistryURL}|$$REGISTRY_URL|g; \
			s/\$${agentRegistryUserName}/$$REGISTRY_USER_NAME/g; \
			s/\$${agentRegistryUserPass}/$$REGISTRY_USER_PASS/g; \
			s/\$${agentRegistryUserMail}/$$REGISTRY_USER_MAIL/g; \
			s/\$${NLoadControllers}/$$N_LOAD_CONTROLLER/g;" < $(DIR_HELM_VALUES)/cb-ci-local.yaml > $(MKFILE)/values.cb-ci-local.yaml
	source .env && \
		helm upgrade --install cbci-local $(DIR_CHARTS)/cb-ci-local --create-namespace --namespace "$$CBCI_NS" \
		-f "$(MKFILE)/values.cb-ci-local.yaml"
	$(call print_subtitle,Update CloudBees values.yaml using $(CB_LB_CONFIG))
	sed "/OperationsCenter:/d" < $(DIR_HELM_VALUES)/cb-ci.common.yaml > /tmp/values.tmp.cb-ci.yaml
	sed -i "/#Common_Configuration/e cat $(DIR_HELM_VALUES)/$(CB_LB_CONFIG)" /tmp/values.tmp.cb-ci.yaml
	@source .env && \
		sed "s/\$${hostname}/$$HOSTNAME/g; \
			s/\$${protocol}/$$PROTOCOL/g; \
			s/\$${subdomain}/$$SUBDOMAIN/g; \
			s/\$${LicFirstName}/$$LIC_FIRSTNAME/g; \
			s/\$${LicLastName}/$$LIC_LASTNAME/g; \
			s/\$${LicEmail}/$$LIC_MAIL/g; \
			s/\$${LicCompany}/$$LIC_COMPANY/g; \
			s|\$${cert_arn}|$$CERTIFICATE_ID|g ; \
			s/\$${agentNamespace}/$$AGENT_NA/g;" < /tmp/values.tmp.cb-ci.yaml > $(MKFILE)/values.cb-ci.yaml
	helm repo add cloudbees https://public-charts.artifacts.cloudbees.com/repository/public/ && helm repo update
	source .env && \
		helm upgrade --install cbci cloudbees/cloudbees-core --create-namespace --namespace "$$CBCI_NS" --version "$$CBCI_VERSION" -f "$(MKFILE)/values.cb-ci.yaml"
	kubectl rollout status sts cjoc --namespace cbci && wait
	@#kubectl get secret oc-secrets -n cbci -o jsonpath='{.data.jenkinsPass}' | base64 --decode > $(MKFILE)/secret.jenkinsPass

.PHONY: check-availability
check-availability: ## Check availability of the OC Example: make check_availability OC_URL
check-availability: guard-OC_URL
	source .env && \
		until kubectl get ing -n $$CBCI_NS cjoc; do sleep 2 && echo "Waiting for Ingress to get ready"; done
	@echo "Ingress Ready"
	source .env && \
		until curl -u $$ADMIN_JENKINS_USER:$$SECRET_JENKINS_PASS -s $(OC_URL)  > /dev/null; do sleep 10 && echo "Waiting for Operation Center at $(OC_URL)"; done
	@echo "Operation Center Ready at $(OC_URL)"

.PHONY: update-casc-oc
update-casc-oc: ## Update Configuration as Code Operation Center
update-casc-oc: guard-OC_URL
	zip -r tmp/oc-bundle.zip $(DIR_CHARTS)/cb-ci-local/casc/oc/modern.oc.ldap
	$(call JenkinsCLI,casc-pre-validate-bundle) < /tmp/oc-bundle.zip
	$(call JenkinsCLI,restart)

.PHONY: update-casc
update-casc-cm: ## Update Configuration as Code Controllers
update-casc-cm: guard-OC_URL
	$(call JenkinsCLI,casc-check-out-bundles)
	$(call JenkinsCLI,casc-effective-bundle-validation-log)
	$(call JenkinsCLI,build admin/restart-all-controllers -s)

.PHONY: cbci-helm-delete
cbci-helm-delete: ## Delete CloudBees Core Modern via Helm. Ref: https://docs.cloudbees.com/docs/cloudbees-ci/latest/kubernetes-install-guide/kubernetes-uninstall
cbci-helm-delete: check_kubeconfig check_envfile
	$(call print_title,Uninstall CloudBees Core via Helm)
	source .env && \
		kubectl delete --all pods --grace-period=0 --force --namespace "$$CBCI_NS" && \
		kubectl delete --all pods --grace-period=0 --force --namespace "$$AGENT_NA" && \
		helm uninstall cbci --namespace "$$CBCI_NS" || echo "Relese cbci does not exist" && \
		helm repo remove cloudbees || echo "Repository cloudbees does not exist" && \
		kubectl delete --all pvc --grace-period=0 --force --namespace "$$CBCI_NS" && \
		kubectl delete ns "$$AGENT_NA" || echo "There is NOT existing namespace $$AGENT_NA" && \
		kubectl delete ns "$$CBCI_NS" || echo "There is not existing namespace $$CBCI_NS"
