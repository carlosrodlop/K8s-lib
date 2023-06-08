MKFILE   		:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile
DIR_MANIFEST 	:= $(MKFILE)/../../../manifest

include $(PARENT_MKFILE)

.PHONY: openldap_update
openldap_update: ## Install OpenLDAP
openldap_update: check_kubeconfig check_envfile
	source .env && \
		kubectl apply -f $(DIR_MANIFEST)/osixia-openldap -n $$SSO_NAMESPACE

.PHONY: openldap_delete
openldap_delete: ## Remove OpenLDAP
openldap_delete: check_kubeconfig check_envfile
	source .env && \
		kubectl delete -f $(DIR_MANIFEST)/osixia-openldap -n $$SSO_NAMESPACE
