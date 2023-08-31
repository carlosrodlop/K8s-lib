MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile
DIR_CHARTS 		:= $(MKFILE)/../../../helm/charts
DIR_HELM_VALUES := $(MKFILE)/../../../helm/values/cloudbees

include $(PARENT_MKFILE)

#Helm chart version for CloudBees CI: https://artifacthub.io/packages/helm/cloudbees/cloudbees-core
CBCI_VERSION     := 3.13430.0+1e383c33d1a3
#Application Version. Release Notes: https://docs.cloudbees.com/docs/release-notes/latest/cloudbees-ci/
CBCI_VERSION_APP := 2.401.3.3

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
	@if [ \! -f /tmp/jenkins-cli.jar ]; then curl -o /tmp/jenkins-cli.jar "$(OC_URL)/jnlpJars/jenkins-cli.jar"; fi
	@echo "Jenkins CLI: $(1)"
	@source .env && \
		java -jar /tmp/jenkins-cli.jar -s $(OC_URL) -auth $$ADMIN_JENKINS_USER:$$ADMIN_JENKINS_PASS -webSocket $(1)
endef

define restartOCIfExist
	if [ $$(kubectl get pod cjoc-0 --namespace cbci 2>/dev/null | grep -c cjoc-0) -eq 1 ]; then \
		echo "Deleting existing cjoc-0 pod to force reload..."; \
		kubectl scale statefulsets cjoc --namespace cbci --replicas=0; \
		kubectl scale statefulsets cjoc --namespace cbci --replicas=1; \
	fi
endef

define updateCBCI
	$(call print_subtitle,Configuring Cloud Specifications)
	source .env && \
		sed "s/\$${hostname}/$$HOSTNAME/g; \
			s/\$${protocol}/$$PROTOCOL/g; \
			s/\$${subdomain}/$$SUBDOMAIN/g; \
			s|\$${cert_arn}|$$CERTIFICATE_ID|g ;" < $(DIR_HELM_VALUES)/$(CB_LB_CONFIG).yaml > $(MKFILE)/values.$(CB_LB_CONFIG).yaml
	$(call print_subtitle,Configuring CloudBees CI Common)
	source .env && \
		sed "s/\$${LicFirstName}/$$LIC_FIRSTNAME/g; \
			s/\$${LicLastName}/$$LIC_LASTNAME/g; \
			s/\$${LicEmail}/$$LIC_MAIL/g; \
			s/\$${LicCompany}/$$LIC_COMPANY/g; \
			s/\$${agentNamespace}/$$AGENT_NA/g;" < $(DIR_HELM_VALUES)/cb-ci.common.yaml > $(MKFILE)/values.cb-ci.common.yaml
	helm repo add cloudbees https://public-charts.artifacts.cloudbees.com/repository/public/ && helm repo update
	source .env && \
		helm upgrade --install cbci cloudbees/cloudbees-core --create-namespace --namespace "$$CBCI_NS" --version "$(CBCI_VERSION)" \
			-f "$(MKFILE)/values.$(CB_LB_CONFIG).yaml" \
			-f "$(MKFILE)/values.cb-ci.common.yaml"
	$(call restartOCIfExist)
	kubectl rollout status sts cjoc --namespace cbci && wait
endef

.PHONY: update-simple
update-simple: ## Install/Update CloudBees Core Modern via Helm. Adding OC Simple Casc Bundle.
update-simple: check_kubeconfig check_envfile guard-CB_LB_CONFIG
	@echo -n "Are up to date .env file? [yes/No] " && read ans && [ $${ans:-No} = yes ]
	$(call print_title, Load Simple OC Casc Bundle)
	source .env && \
		kubectl create ns "$$CBCI_NS" || echo "$$CBCI_NS exist" && \
		kubectl create ns "$$AGENT_NA" || echo "$$AGENT_NA" && \
		kubectl create secret generic oc-secrets --namespace "$$CBCI_NS" --from-literal=githubToken=$$SECRET_GH_TOKEN --from-literal=githubUser=$$SECRET_GH_USER || echo "oc-secrets exist" && \
		kubectl create configmap oc-casc-bundle --namespace "$$CBCI_NS" --from-file=$(DIR_CHARTS)/cb-ci-local/casc/oc/modern.oc.simple || echo "oc-casc-bundle exist"
	$(call print_title,Updating Remote CloudBees Helm Chart)
	$(call updateCBCI)

.PHONY: update-advance
update-advance: ## Install/Update CloudBees Core Modern via Helm. Adding OC Advanced Casc Bundle and Local Helm Chart.
update-advance: check_kubeconfig check_envfile guard-CB_LB_CONFIG
	@echo -n "Are up to date .env file and $(DIR_CHARTS)/cb-ci-local/casc/oc/modern.oc.advance/variables.yaml? [yes/No] " && read ans && [ $${ans:-No} = yes ]
	$(call print_title,Updating Local CloudBees Helm Chart)
	source .env && \
		sed "s/\$${hostname}/$$HOSTNAME/g; \
			s/\$${protocol}/$$PROTOCOL/g; \
			s|\$${c_casc_repo}|$$C_CASC_REPO|g ; \
			s/\$${ingressClass}/$$ING_CLASS/g; \
			s/\$${secretGHToken}/$$SECRET_GH_TOKEN/g; \
			s/\$${secretGHUser}/$$SECRET_GH_USER/g; \
			s/\$${secretAdvisorMail}/$$SECRET_ADVISOR_MAIL/g; \
			s/\$${agentNamespace}/$$AGENT_NA/g; \
			s|\$${agentRegistryURL}|$$REGISTRY_URL|g; \
			s/\$${agentRegistryUserName}/$$REGISTRY_USER_NAME/g; \
			s/\$${agentRegistryUserPass}/$$REGISTRY_USER_PASS/g; \
			s/\$${agentRegistryUserMail}/$$REGISTRY_USER_MAIL/g; \
			s/\$${NLoadControllers}/$$N_LOAD_CONTROLLER/g;" < $(DIR_HELM_VALUES)/cb-ci-local.yaml > $(MKFILE)/values.cb-ci-local.yaml
	source .env && \
		helm upgrade --install cbci-local $(DIR_CHARTS)/cb-ci-local --create-namespace --namespace "$$CBCI_NS" \
		-f "$(MKFILE)/values.cb-ci-local.yaml"
	$(call print_title,Updating Remote CloudBees Helm Chart)
	$(call updateCBCI)

.PHONY: check-availability
check-availability: ## Check availability of the OC.
check-availability: guard-OC_URL
	source .env && \
		until kubectl get pod -n $$CBCI_NS cjoc-0; do sleep 2 && echo "Waiting for Pod to get ready"; done
	@echo "OC Pod is Ready"
	source .env && \
		until kubectl get ing -n $$CBCI_NS cjoc; do sleep 2 && echo "Waiting for Ingress to get ready"; done
	@echo "Ingress Ready"
	source .env && \
		until curl -u $$ADMIN_JENKINS_USER:$$ADMIN_JENKINS_PASS -s $(OC_URL)  > /dev/null; do sleep 10 && echo "Waiting for Operation Center at $(OC_URL)"; done
	@echo "Operation Center Ready at $(OC_URL)"

.PHONY: validate-casc-bundle
validate-casc-bundle: ## Validate 1 bundle.
validate-casc-bundle: guard-OC_URL
	source .env && \
		cd $(DIR_CHARTS)/$$PATH_BUNDLE_VAL && zip -r /tmp/bundle-to-validate.zip $$BUNDLE_VAL
	$(call JenkinsCLI,casc-pre-validate-bundle) < /tmp/bundle-to-validate.zip | yq -o=json

.PHONY: update-casc-cm
update-casc-cm: ## Update Configuration as Code Controllers in Operation Center, Validate and Apply (if it requires)
update-casc-cm: guard-OC_URL
	$(call JenkinsCLI,casc-check-out-bundles) | yq -o=json
	$(call JenkinsCLI,casc-raw-bundle-validation-log) | yq -o=json
	@echo -n "Do you want to Restart Controller to apply? [yes/No] " && read ans && [ $${ans:-No} = yes ]
	$(call JenkinsCLI,build admin/restart-all-controllers -s)

.PHONY: plugin-calc-bundle
plugin-calculator: ## Update Configuration as Code Controllers in Operation Center, Validate and Apply (if it requires)
plugin-calculator:
	source .env && \
		current_full_bundle_path=$$(echo $$CBCI_CASC_BUNDLE_PATH/$$CBCI_CASC_BUNDLE_NAME) && \
		actual_plugins_folder=$$(echo $(DIR_CHARTS)/cb-ci-local/casc/tmp-plugin-calculations) && \
		rm -rf $$actual_plugins_folder/plugin*.* && \
		echo "$$CBCI_CASC_BUNDLE_NAME: $$CBCI_APP_TYPE-$(CBCI_VERSION_APP)" > $$actual_plugins_folder/plugins-$$CBCI_APP_TYPE-$(CBCI_VERSION_APP) && \
		$$RUN_CMD \
			-v $(CBCI_VERSION_APP) \
			-t $$CBCI_APP_TYPE \
			-f "$$current_full_bundle_path/plugins.yaml" \
			-F "$$actual_plugins_folder/plugins.yaml" \
			-c "$$actual_plugins_folder/plugin-catalog.yaml" \
			-C "$$actual_plugins_folder/plugin-catalog-offline.yaml" \
			-s \
			-g "$$actual_plugins_folder/plugins-minimal-for-generation-only.yaml" \
			-G "$$actual_plugins_folder/plugins-minimal.yaml"

.PHONY: delete
delete: ## Delete all CloudBees Core Modern . Ref: https://docs.cloudbees.com/docs/cloudbees-ci/latest/kubernetes-install-guide/kubernetes-uninstall
delete: check_kubeconfig check_envfile
	$(call print_title,Uninstall CloudBees Core via Helm)
	source .env && \
		kubectl delete --all pods --grace-period=0 --force --namespace "$$CBCI_NS" && \
		kubectl delete --all pods --grace-period=0 --force --namespace "$$AGENT_NA" && \
		helm uninstall cbci --namespace "$$CBCI_NS" || echo "Relese cbci does not exist" && \
		helm repo remove cloudbees || echo "Repository cloudbees does not exist" && \
		kubectl delete --all pvc --grace-period=0 --force --namespace "$$CBCI_NS" && \
		kubectl delete ns "$$AGENT_NA" || echo "There is NOT existing namespace $$AGENT_NA" && \
		kubectl delete ns "$$CBCI_NS" || echo "There is not existing namespace $$CBCI_NS"
