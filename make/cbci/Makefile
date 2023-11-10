MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile
DIR_CHARTS 		:= $(MKFILE)/../../helm/charts
DIR_HELM_VALUES := $(MKFILE)/../../helm/values/cloudbees
DIR_HELMFILES 	:= $(MKFILE)/../../helmfile
HELM_LOG_PATH 	:= $(MKFILE)/helm.log

include $(PARENT_MKFILE)

#Helm chart version for CloudBees CI: https://artifacthub.io/packages/helm/cloudbees/cloudbees-core
CBCI_VERSION     := 3.14783.0+d0af0bc462a0
#Application Version. Release Notes: https://docs.cloudbees.com/docs/release-notes/latest/cloudbees-ci/
CBCI_VERSION_APP := 2.414.3.8

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

define postHelmDelete
	helm repo remove cloudbees || echo "Repository cloudbees does not exist"
	kubectl delete --all pvc --grace-period=0 --force --namespace "cbci"
	kubectl delete ns "cbci-agents" || echo "There is NOT existing namespace cbci-agents"
	kubectl delete ns "cbci" || echo "There is not existing namespace cbci"
endef

define updateCBCI
	$(call print_subtitle,Configuring Cloud Specifications)
	source .env && \
		sed "s/\$${hostname}/$$HOSTNAME/g; \
			s/\$${protocol}/$$PROTOCOL/g; \
			s/\$${subdomain}/$$SUBDOMAIN/g; \
			s|\$${cert_arn}|$$CERTIFICATE_ID|g ;" \
				< $(DIR_HELM_VALUES)/$(CB_LB_CONFIG).yaml > $(MKFILE)/values.$(CB_LB_CONFIG).yaml
	$(call print_subtitle,Configuring CloudBees CI Common)
	source .env && \
		sed "s/\$${LicFirstName}/$$LIC_FIRSTNAME/g; \
			s/\$${LicLastName}/$$LIC_LASTNAME/g; \
			s/\$${LicEmail}/$$LIC_MAIL/g; \
			s/\$${LicCompany}/$$LIC_COMPANY/g;" \
				< $(DIR_HELM_VALUES)/cb-ci.common.yaml > $(MKFILE)/values.cb-ci.common.yaml
	helm repo add cloudbees https://public-charts.artifacts.cloudbees.com/repository/public/ && helm repo update
	@echo "Values to apply for $(CBCI_VERSION) - Application Version: $(CBCI_VERSION_APP)"
	@cat $(MKFILE)/values.$(CB_LB_CONFIG).yaml
	@cat $(MKFILE)/values.cb-ci.common.yaml
	@echo -n "Are OK with this helm values to be applied [yes/No] " && read ans && [ $${ans:-No} = yes ]
	source .env && \
		helm upgrade --install cbci cloudbees/cloudbees-core --create-namespace --namespace "cbci" --version "$(CBCI_VERSION)" \
			-f "$(MKFILE)/values.$(CB_LB_CONFIG).yaml" \
			-f "$(MKFILE)/values.cb-ci.common.yaml"
	$(call restartOCIfExist)
	kubectl rollout status sts cjoc --namespace cbci && wait
endef

.PHONY: ciHelm-update-simple
ciHelm-update-simple: ## Install/Update CloudBees Core Modern via Helm. Adding OC Simple Casc Bundle.
ciHelm-update-simple: check_kubeconfig check_envfile guard-CB_LB_CONFIG
	$(call print_title, Load Simple OC Casc Bundle)
	source .env && \
		kubectl create ns "cbci" || echo "cbci exist" && \
		kubectl create ns "cbci-agents" || echo "cbci-agents" && \
		kubectl create secret generic oc-secrets --namespace "cbci" --from-literal=githubToken=$$SECRET_GH_TOKEN --from-literal=githubUser=$$SECRET_GH_USER || echo "oc-secrets exist" && \
		kubectl create configmap oc-casc-bundle --namespace "cbci" --from-file=$(DIR_CHARTS)/cb-ci-local/casc/oc/modern.oc.simple || echo "oc-casc-bundle exist"
	$(call print_title,Updating Remote CloudBees Helm Chart)
	$(call updateCBCI)

.PHONY: ciHelm-update-advanced
ciHelm-update-advanced: ## Install/Update CloudBees Core Modern via Helm. Adding OC Advanced Casc Bundle and Local Helm Chart.
ciHelm-update-advanced: check_kubeconfig check_envfile guard-CB_LB_CONFIG
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
			s|\$${agentRegistryURL}|$$REGISTRY_URL|g; \
			s/\$${agentRegistryUserName}/$$REGISTRY_USER_NAME/g; \
			s/\$${agentRegistryUserPass}/$$REGISTRY_USER_PASS/g; \
			s/\$${agentRegistryUserMail}/$$REGISTRY_USER_MAIL/g; \
			s/\$${NLoadControllers}/$$N_LOAD_CONTROLLER_HA/g;" \
				< $(DIR_HELM_VALUES)/cb-ci-local.yaml > $(MKFILE)/values.cb-ci-local.yaml
	source .env && \
		helm --debug upgrade --install cbci-local $(DIR_CHARTS)/cb-ci-local --create-namespace --namespace "cbci" \
		-f "$(MKFILE)/values.cb-ci-local.yaml"
	$(call print_title,Updating Remote CloudBees Helm Chart)
	$(call updateCBCI)

.PHONY: ciHelmfile-update
ciHelmfile-update: ## Install/Update CloudBees Core Modern via Helmfile.
ciHelmfile-update: check_kubeconfig
	@rm -f $(HELM_LOG_PATH)
	PLATFORM=ci helmfile --debug --file $(DIR_HELMFILES)/sda.eks.alb.helmfile.yml --interactive apply | tee -a $(HELM_LOG_PATH)
	@#$(call restartOCIfExist)
	@#kubectl rollout status sts cjoc --namespace cbci && wait

.PHONY: ciCheck-availability
ciCheck-availability: ## Check availability of the OC.
ciCheck-availability: guard-OC_URL
	source .env && \
		until kubectl get pod -n cbci cjoc-0; do sleep 2 && echo "Waiting for Pod to get ready"; done
	@echo "OC Pod is Ready"
	source .env && \
		until kubectl get ing -n cbci cjoc; do sleep 2 && echo "Waiting for Ingress to get ready"; done
	@echo "Ingress Ready"
	source .env && \
		until curl -u $$ADMIN_JENKINS_USER:$$ADMIN_JENKINS_PASS -s $(OC_URL)  > /dev/null; do sleep 10 && echo "Waiting for Operation Center at $(OC_URL)"; done
	@echo "Operation Center Ready at $(OC_URL)"

.PHONY: ciValidate-casc-bundle
ciValidate-casc-bundle: ## Validate 1 bundle.
ciValidate-casc-bundle: guard-OC_URL
	source .env && \
		cd $(DIR_CHARTS)/$$PATH_BUNDLE_VAL && zip -r /tmp/bundle-to-validate.zip $$BUNDLE_VAL
	$(call JenkinsCLI,casc-pre-validate-bundle) < /tmp/bundle-to-validate.zip | yq -o=json

.PHONY: ciUpdate-casc-cm
ciUpdate-casc-cm: ## Update Configuration as Code Controllers in Operation Center, Validate and Apply (if it requires)
ciUpdate-casc-cm: guard-OC_URL
	$(call JenkinsCLI,casc-check-out-bundles) | yq -o=json
	$(call JenkinsCLI,casc-raw-bundle-validation-log) | yq -o=json
	@echo -n "Do you want to Restart Controller to apply? [yes/No] " && read ans && [ $${ans:-No} = yes ]
	$(call JenkinsCLI,build admin/restart-all-controllers -s)

.PHONY: ciPlugin-calculator
ciPlugin-calculator: ## Provide plugin.yaml and plugin-catalog.yaml for a bundle. IMPORTANT: Require to be run from Bash5 (eg. docker-libs > bash5.alpine)
ciPlugin-calculator:
	source .env && \
		current_full_bundle_path=$$(echo $$CBCI_CASC_BUNDLE_PATH/$$CBCI_CASC_BUNDLE_NAME) && \
		actual_plugins_folder=$$(echo $(DIR_CHARTS)/cb-ci-local/casc/tmp-plugin-calculations) && \
		rm -rf $$actual_plugins_folder/*.* && \
		echo "$$CBCI_CASC_BUNDLE_NAME: $$CBCI_CASC_BUNDLE_TYPE-$(CBCI_VERSION_APP)" > $$actual_plugins_folder/summary.txt && \
		mkdir -p $$actual_plugins_folder/plugins && mkdir -p $$actual_plugins_folder/catalog && \
		$$RUN_CMD \
			-v $(CBCI_VERSION_APP) \
			-t $$CBCI_CASC_BUNDLE_TYPE \
			-f "$$current_full_bundle_path/$$CBCI_CASC_BUNDLE_PLUGINS" \
			-F "$$actual_plugins_folder/plugins/$(CBCI_VERSION_APP).yaml" \
			-g "$$actual_plugins_folder/plugins/$(CBCI_VERSION_APP).minimal-for-generation-only.yaml" \
			-G "$$actual_plugins_folder/plugins/$(CBCI_VERSION_APP).minimal.yaml" \
			-c "$$actual_plugins_folder/catalog/$(CBCI_VERSION_APP).yaml" \
			-C "$$actual_plugins_folder/catalog/$(CBCI_VERSION_APP).offline.yaml" \
			-s

.PHONY: ciPurge_pods
ciPurge_pods:
ciPurge_pods: #Purge Pods in cbci and cbci-agents namespaces
	kubectl delete --all pods --grace-period=0 --force --namespace "cbci"
	kubectl delete --all pods --grace-period=0 --force --namespace "cbci-agents"

.PHONY: ciHelm-delete
ciHelm-delete: ## Helm Delete all things into CloudBees Core Modern Namespaces and Storage. Ref: https://docs.cloudbees.com/docs/cloudbees-ci/latest/kubernetes-install-guide/kubernetes-uninstall
ciHelm-delete: check_kubeconfig check_envfile ciPurge_pods
	$(call print_title,Uninstall CloudBees Core via Helm)
	helm --debug uninstall cbci --namespace "cbci" || echo "Relese cbci does not exist"
	$(call postHelmDelete)

.PHONY: ciHelmfile-delete
ciHelmfile-delete: ## Helmfile Delete
ciHelmfile-delete: check_kubeconfig ciPurge_pods
	@rm -f $(HELM_LOG_PATH)
	helmfile --debug --file $(DIR_HELMFILES)/sda.eks.alb.helmfile.yml destroy | tee -a $(HELM_LOG_PATH)
	$(call postHelmDelete)
