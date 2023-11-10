MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile
DIR_TF_ROOT		:= $(MKFILE)/../../../../clouds/aws/root/tmp
DIR_CHARTS 		:= $(MKFILE)/../../helm/charts
DIR_HELM_VALUES := $(MKFILE)/../../helm/values

include $(PARENT_MKFILE)
#Release Notes: https://docs.cloudbees.com/docs/cloudbees-cd-release-notes/latest/
#Helm chart CloudBees CD Server: https://artifacthub.io/packages/helm/cloudbees/cloudbees-flow
MYSQL_DB_VERSION        := 9.12.0
#Helm chart CloudBees CD Server: https://artifacthub.io/packages/helm/cloudbees/cloudbees-flow
CBCD_SERVER_VERSION     := 2.27.0
#Helm chart CloudBees CD Agent: https://artifacthub.io/packages/helm/cloudbees/cloudbees-flow-agent
CBCD_AGENT_VERSION      := $(CBCD_SERVER_VERSION)

CB_LB_CONFIG	:= $(shell echo $(call getEnvProperty,CB_LB_CONFIG))
HOSTNAME		:= $(shell echo $(call getEnvProperty,HOSTNAME))

.PHONY: cdUpdateDb
cdUpdateDb: ## Create and Update Database Service inside Kubernetes Cluster. It requires to create Database for Flow
cdUpdateDb: check_kubeconfig check_envfile
	source .env && \
		helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update && \
		helm --debug upgrade --install mysql bitnami/mysql --version $(MYSQL_DB_VERSION)  \
			-f $(DIR_HELM_VALUES)/mysql/cb-cd.bitnami.yaml \
			--namespace db --create-namespace && \
		kubectl rollout status sts mysql --namespace db && wait

.PHONY: cdConnectDBRemotely
cdConnectDBRemotely: ## Open a connection to Database remotely for CloudBees CD
cdConnectDBRemotely: check_envfile
	source .env && \
		mysql -h $$EXTERNAL_ENDPOINT_DB -u admin --password --verbose

.PHONY: cdCreateDBRemotely
cdCreateDBRemotely: ## Update Database remotely for CloudBees CD
cdCreateDBRemotely: check_envfile
	source .env && \
		mysql -h $$EXTERNAL_ENDPOINT_DB -u admin --password --verbose < $(MKFILE)/create.db.sql

.PHONY: cdDropDBRemotely
cdDropDBRemotely: ## Delete Database remotely for CloudBees CD. Note: Database cannot be used between different deployment.
cdDropDBRemotely: check_envfile
	source .env && \
		mysql -h $$EXTERNAL_ENDPOINT_DB -u admin --password --verbose < $(MKFILE)/drop.db.sql

.PHONY: cdUpdateServer
cdUpdateServer: ## Update CD Server
cdUpdateServer: check_kubeconfig check_envfile guard-CB_LB_CONFIG
	source .env && \
		sed "s/\$${hostname}/$$HOSTNAME/g; \
			s|\$${cert_arn}|$$CERTIFICATE_ID|g ;" < $(DIR_HELM_VALUES)/cloudbees/$(CB_LB_CONFIG).yaml > $(MKFILE)/values.$(CB_LB_CONFIG).yaml && \
		sed "s/\$${externalEndpoint}/$$EXTERNAL_ENDPOINT_DB/g; \
			s/\$${hostname}/$$HOSTNAME/g;" < $(DIR_HELM_VALUES)/cloudbees/cb-cd.server.yaml > $(MKFILE)/values.cb-cd.server.yaml
	helm repo add cloudbees https://public-charts.artifacts.cloudbees.com/repository/public/ && helm repo update
	@echo "Values to apply for $(CBCD_SERVER_VERSION)"
	@cat $(MKFILE)/values.$(CB_LB_CONFIG).yaml
	@cat $(MKFILE)/values.cb-cd.server.yaml
	@echo -n "Are OK with this helm values to be applied [yes/No] " && read ans && [ $${ans:-No} = yes ]
	helm --debug upgrade --install cbcd-server cloudbees/cloudbees-flow \
		-f $(MKFILE)/values.$(CB_LB_CONFIG).yaml \
		-f $(MKFILE)/values.cb-cd.server.yaml \
		--namespace cbcd --create-namespace \
		--timeout 10000s

.PHONY: cdUpdateAll
cdUpdateAll: ## Update Database Service + CD Server. It requires to create Database for Flow.
cdUpdateAll: cdUpdateDb cdUpdateServer

.PHONY: cdUpdateAllDBRemote
cdUpdateAllDBRemote: ## Create Database for Flow + CD Server.
cdUpdateAllDBRemote: cdCreateDBRemotely cdUpdateServer

.PHONY: cdUpdateAgent
cdUpdateAgent: ## Update CD Agent
cdUpdateAgent: check_kubeconfig check_envfile guard-CB_LB_CONFIG
	source .env && \
		kubectl create cbcd-agent
		kubectl create secret generic flow-agent-secret \
			--from-literal=CBF_SERVER_USER=admin \
			--from-literal=CBF_SERVER_PASSWORD=admin \
			--namespace cbcd-agent || echo "Secret already exists" && \
		helm --debug install cb-cd-agent cloudbees/cloudbees-flow-agent \
			-f values.demo.agent.yaml \
			--namespace cbcd_AGENT \
			--timeout 10000s

.PHONY: cdGetValues
cdGetValues: ## Get Helm Chart value for an specific version.
cdGetValues:
	helm repo add cloudbees https://public-charts.artifacts.cloudbees.com/repository/public/ && helm repo update
	helm inspect values --version $(CBCD_SERVER_VERSION) cloudbees/cloudbees-flow > $(MKFILE)/values.all.$(CBCD_SERVER_VERSION).cb-cd-server.yaml

.PHONY: cdDeleteDb
cdDeleteDb: ## Delete Database.
cdDeleteDb: check_kubeconfig check_envfile
	$(call print_title,Uninstall CloudBees Core via Helm)
	source .env && \
		kubectl delete --all pods --grace-period=0 --force --namespace db && \
		helm --debug uninstall mysql --namespace db || echo "Relese mysql does not exist" && \
		helm repo remove bitnami || echo "Repository cloudbees does not exist" && \
		kubectl delete --all pvc --grace-period=0 --force --namespace db && \
		kubectl delete ns db || echo "There is NOT existing namespace db"

.PHONY: cdDeleteServer
cdDeleteServer: ## Delete CloudBees CD Server.
cdDeleteServer: check_kubeconfig check_envfile
	$(call print_title,Uninstall CloudBees Core via Helm)
	source .env && \
		kubectl delete --all pods --grace-period=0 --force --namespace cbcd && \
		helm --debug uninstall cbcd-server --namespace cbcd || echo "Relese cbcd-server does not exist" && \
		helm repo remove cloudbees || echo "Repository cloudbees does not exist" && \
		kubectl delete --all pvc --grace-period=0 --force --namespace cbcd && \
		kubectl delete ns cbcd || echo "There is NOT existing namespace cbcd"

.PHONY: cdDeleteAll
cdDeleteAll: ## Delete CloudBees CD Release + Database Service.
cdDeleteAll: cdDeleteServer cdDeleteDb

.PHONY: cdDeleteAllDBRemote
cdDeleteAllDBRemote: ## Delete CloudBees CD Release + Drop Database for CloudBees CD.
cdDeleteAllDBRemote: cdDeleteServer cdDropDBRemotely
