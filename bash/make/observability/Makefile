MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile # docker
DIR_HELM_VALUES := $(MKFILE)/../../../helm/values
DIR_MANIFEST 	:= $(MKFILE)/../../../manifest
DIR_TF_ROOT		:= $(MKFILE)/../../../../../clouds/aws/root/eks-bp-v4
DIR_CHARTS 		:= $(MKFILE)/../../../helm/charts

include $(PARENT_MKFILE)

#https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html#view-dashboard
.PHONY: k8s_db-eks_update
k8s_db-eks_update: ## Install K8s Dashboard in EKS
k8s_db-eks_update: check_kubeconfig check_envfile
	source .env && kubectl apply -f $$K8_DASHBOAR_MANIFEST
	kubectl apply -f $(DIR_MANIFEST)/k8s-dh-eks-admin
	kubectl -n kube-system describe secret $(shell kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

.PHONY: k8s_db-eks_delete check_envfile
k8s_db-eks_delete: ## Remove K8s Dashboard in EKS
k8s_db-eks_delete: check_kubeconfig check_envfile
	kubectl delete -f $(DIR_MANIFEST)/k8s-dh-eks-admin
	source .env && kubectl delete -f $$K8_DASHBOAR_MANIFEST

.PHONY: komodor_update
komodor_update: ## Install Komodor Agent and Helm Dashboard
komodor_update: check_kubeconfig check_envfile
	helm repo add komodorio https://helm-charts.komodor.io && helm repo update
	source .env && \
		sed "s/\$${apiKey}/$$KOMODOR_API_KEY/g; \
			s/\$${clusterName}/$$CLUSTER_NAME/g;" < $(DIR_HELM_VALUES)/komodor/komodor-watcher.yaml > $(MKFILE)/values.komodor-watcher.yaml && \
		sed "s/\$${storageClass}/$$STORAGE_CLASS/g; " < $(DIR_HELM_VALUES)/komodor/komodor-helm-dashboard.yaml > $(MKFILE)/values.komodor-helm-dashboard.yaml && \
		helm upgrade --install k8s-watcher komodorio/k8s-watcher --namespace komodor --create-namespace --version "$$KOMODOR_WATCHER_VERSION" -f "$(MKFILE)/values.komodor-watcher.yaml" && \
		helm upgrade --install helm-dashboard komodorio/helm-dashboard --namespace komodor --version "$$KOMODOR_HELM_VERSION" -f "$(MKFILE)/values.komodor-helm-dashboard.yaml"

.PHONY: komodor_delete
komodor_delete: ## Delete Komodor Agent and Helm Dashboard
komodor_delete: check_kubeconfig
	helm uninstall helm-dashboard --namespace komodor || echo "Relese helm-dashboard does not exist"
	helm uninstall k8s-watcher --namespace komodor || echo "Relese k8s-watcher does not exist"
	helm repo remove komodorio || echo "Repository komodorio does not exist"
	kubectl delete pvc --all --namespace komodor
	kubectl delete ns komodor || echo "There is NOT existing namespace komodor"

.PHONY: robusta_update
robusta_update: ## Install Robusta and Kube Prometheus Stack
robusta_update: check_kubeconfig check_envfile
	helm repo add robusta https://robusta-charts.storage.googleapis.com && helm repo update
	source .env && \
		sed "s/\$${clusterName}/$$CLUSTER_NAME/g;" < $(DIR_HELM_VALUES)/robusta-kube-prom-stack/robusta.secret.yaml > $(MKFILE)/values.robusta.secret.yaml && \
		sed "s/\$${hostname}/$$GRAFANA_HOSTNAME/g; \
			s|\$${cert_arn}|$(call getTFValue,$(DIR_TF_ROOT),acm_certificate_arn)|g" < $(DIR_HELM_VALUES)/robusta-kube-prom-stack/robusta-prometheus-grafana-alb.yaml > $(MKFILE)/values.robusta-prometheus-grafana-alb.yaml && \
		helm upgrade --install robusta robusta/robusta --namespace robusta --create-namespace --version "$$ROBUSTA_VERSION" \
		--values "$(MKFILE)/values.robusta.secret.yaml" \
		--values "$(DIR_HELM_VALUES)/robusta-kube-prom-stack/robusta-prometheus-main.yaml" \
		--values "$(DIR_HELM_VALUES)/robusta-kube-prom-stack/robusta-prometheus-alerts.yaml" \
		--values "$(DIR_HELM_VALUES)/robusta-kube-prom-stack/robusta-prometheus-grafana.yaml" \
		--values "$(MKFILE)/values.robusta-prometheus-grafana-alb.yaml" \
		--values "$(DIR_HELM_VALUES)/robusta-kube-prom-stack/robusta.custom-playbooks.yaml" \
		--set kube-prometheus-stack.grafana.adminPassword=$$GRAFANA_PASS
	@kubectl get secret robusta-grafana -o jsonpath="{.data.admin-password}" -n robusta | base64 --decode ; echo > $(MKFILE)/secret.robusta-grafana
	helm upgrade --install kube-prometheus-stack-local $(DIR_CHARTS)/kube-prometheus-stack-local --create-namespace --namespace robusta

.PHONY: robusta_delete
robusta_delete: ## Remove Robusta and Kube Prometheus Stack
robusta_delete: check_kubeconfig
	helm uninstall robusta --namespace robusta || echo "Relese robusta does not exist"
	helm repo remove robusta || echo "Repository robusta does not exist"
	kubectl delete pvc --all --namespace robusta
	kubectl delete ns robusta || echo "There is NOT existing namespace robusta"

.PHONY: chaos_enable
chaos_enable: ## Install Chaos in namespace passed in the values.yaml
chaos_enable: check_kubeconfig
	helm upgrade --install chaos-local $(DIR_CHARTS)/chaos-local --namespace chaos --create-namespace \
		--set kubeStresscheck.replicas=10
		--set kubeStresscheck.namespace={cbci,cbci-agents}

.PHONY: chaos_disable
chaos_disable: ## Remove Chaos
chaos_disable: check_kubeconfig
	helm uninstall chaos-local --namespace chaos || echo "Relese chaos does not exist"
