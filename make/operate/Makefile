DEBUG			:= true
DEBUG_FILE		:= terraform.logs
DIR_MAKE    	:= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DIR_ENV			:= $(DIR_MAKE)/env
DIR_ROOT		:= $(DIR_MAKE)/root

BACKUP_SQUED_NAME:=cbci-dr
BACKUP_FREQ:=15m
BACKUP_TTL:=1h
BACKUP_EXCLUDE:=pods,events,events.events.k8s.io,targetgroupbindings.elbv2.k8s.aws

CI_NAMESPACE:=cbci
CI_OC_URL:=https://ci.dw22.pscbdemos.com/cjoc/
CLUSTER_PREFIX:=dw22-dr-velero

export KUBECONFIG=kubeconfig_file

ifeq ($(DEBUG),true)
	export TF_LOG=DEBUG
	export TF_LOG_PATH=$(DEBUG_FILE)
endif

define deleteBackupSchedule
	velero schedule delete $(BACKUP_SQUED_NAME) --confirm || echo "There is not an existing schedule $(BACKUP_SQUED_NAME)"
endef

.PHONY: velero_create_schedule
velero_create_schedule:
velero_create_schedule: ## Remove Backup Schedule for velero
	$(deleteBackupSchedule)
	velero create schedule $(BACKUP_SQUED_NAME) --schedule='@every $(BACKUP_FREQ)' --ttl $(BACKUP_TTL) --include-namespaces $(CI_NAMESPACE) --exclude-resources $(BACKUP_EXCLUDE)

.PHONY: velero_remove_schedule
velero_remove_schedule: ## Remove exiting schedule for velero
velero_remove_schedule:

	$(deleteBackupSchedule)

.PHONY: velero_trigger_backup
velero_trigger_backup: ## Create a puntual Backup from Schedule
velero_trigger_backup:

	velero backup create --from-schedule $(BACKUP_SQUED_NAME) --wait

.PHONY: velero_restore_backup
velero_restore_backup: ## Restore Backup Schedule for velero
velero_restore_backup:

#Velero does not work to overwrite in place (https://github.com/vmware-tanzu/velero/issues/469). You have to delete everything first:
	kubectl delete --ignore-not-found --wait ns $(CI_NAMESPACE)
	velero restore create --from-schedule $(BACKUP_SQUED_NAME)
