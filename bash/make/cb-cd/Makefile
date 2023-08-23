MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile
DIR_TF_ROOT		:= $(MKFILE)/../../../../../clouds/aws/root/tmp
DIR_CHARTS 		:= $(MKFILE)/../../../helm/charts
DIR_HELM_VALUES := $(MKFILE)/../../../helm/values

include $(PARENT_MKFILE)
#Release Notes: https://docs.cloudbees.com/docs/cloudbees-cd-release-notes/latest/
#Helm chart CloudBees CD Server: https://artifacthub.io/packages/helm/cloudbees/cloudbees-flow
MYSQL_DB_VERSION     := 9.12.0
#Helm chart CloudBees CD Server: https://artifacthub.io/packages/helm/cloudbees/cloudbees-flow
CBCD_SERVER_VERSION     := 2.26.0
#Helm chart CloudBees CD Agent: https://artifacthub.io/packages/helm/cloudbees/cloudbees-flow-agent
CBCD_AGENT_VERSION      := $(CBCD_SERVER_VERSION)

CB_LB_CONFIG	:= $(shell echo $(call getEnvProperty,CB_LB_CONFIG))
HOSTNAME		:= $(shell echo $(call getEnvProperty,HOSTNAME))

.PHONY: updateDb
updateDb: ## Update Database
updateDb: check_kubeconfig check_envfile
	source .env && \
		helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update && \
		helm upgrade --install mysql bitnami/mysql --version $(MYSQL_DB_VERSION)  \
			-f $(DIR_HELM_VALUES)/mysql/cb-cd.bitnami.yaml \
			--namespace $$DB_NS --create-namespace && \
		kubectl rollout status sts mysql --namespace $$DB_NS && wait

.PHONY: updateCdServer
updateCdServer: ## Update CD Server
updateCdServer: check_kubeconfig check_envfile guard-CB_LB_CONFIG
	source .env && \
		helm repo add cloudbees https://public-charts.artifacts.cloudbees.com/repository/public/ && helm repo update && \
		helm upgrade --install cbcd-server cloudbees/cloudbees-flow \
			-f $(DIR_HELM_VALUES)/cloudbees/$(CB_LB_CONFIG).yaml \
			-f $(DIR_HELM_VALUES)/cloudbees/cb-cd.server.yaml \
			--namespace $$CBCD_NS --create-namespace \
			--timeout 10000s

.PHONY: updateCdAgent
updateCdAgent: ## Update CD Server
updateCdAgent: check_kubeconfig check_envfile guard-CB_LB_CONFIG
	source .env && \
		kubectl create $$CBCD_NS_AGENT
		kubectl create secret generic flow-agent-secret \
			--from-literal=CBF_SERVER_USER=admin \
			--from-literal=CBF_SERVER_PASSWORD=admin \
			--namespace $$CBCD_NS_AGENT || echo "Secret already exists" && \
		helm install cb-cd-agent cloudbees/cloudbees-flow-agent \
			-f values.demo.agent.yaml \
			--namespace $$CBCD_NS_AGENT \
			--timeout 10000s

.PHONY: getValues
getValues: ## Install/Update CloudBees CD via Helm.
getValues:
	helm repo add cloudbees https://public-charts.artifacts.cloudbees.com/repository/public/ && helm repo update
	helm inspect values --version $(CBCD_SERVER_VERSION) cloudbees/cloudbees-flow > $(MKFILE)/values.all.$(CBCD_SERVER_VERSION).cb-cd-server.yaml

.PHONY: deleteDb
deleteDb: ## Delete Database. Ref: https://docs.cloudbees.com/docs/cloudbees-ci/latest/kubernetes-install-guide/kubernetes-uninstall
deleteDb: check_kubeconfig check_envfile
	$(call print_title,Uninstall CloudBees Core via Helm)
	source .env && \
		kubectl delete --all pods --grace-period=0 --force --namespace $$DB_NS && \
		helm uninstall mysql --namespace $$DB_NS || echo "Relese mysql does not exist" && \
		helm repo remove bitnami || echo "Repository cloudbees does not exist" && \
		kubectl delete --all pvc --grace-period=0 --force --namespace $$DB_NS && \
		kubectl delete ns $$DB_NS || echo "There is NOT existing namespace $$DB_NS"

.PHONY: deleteCd
deleteCd: ## Delete CloudBees CD. Ref: https://docs.cloudbees.com/docs/cloudbees-ci/latest/kubernetes-install-guide/kubernetes-uninstall
deleteCd: check_kubeconfig check_envfile
	$(call print_title,Uninstall CloudBees Core via Helm)
	source .env && \
		kubectl delete --all pods --grace-period=0 --force --namespace $$CBCD_NS && \
		helm uninstall cbcd-server --namespace $$CBCD_NS || echo "Relese cbcd-server does not exist" && \
		helm repo remove cloudbees || echo "Repository cloudbees does not exist" && \
		kubectl delete --all pvc --grace-period=0 --force --namespace $$CBCD_NS && \
		kubectl delete ns $$CBCD_NS || echo "There is NOT existing namespace $$CBCD_NS"
