MKFILEDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile

include $(PARENT_MKFILE)

.PHONY: run
run: ## Run terraform-lib within a docker container
run:
	docker run -it --name $(shell echo swissknife.alpine.m1 | cut -d ":" -f 1)_$(shell echo $$RANDOM) \
		--env-file=.docker.env \
		-v $(MKFILEDIR):/home/swiss-user/k8s-lib -v $(HOME)/.aws:/home/swiss-user/.aws \
		carlosrodlop/swissknife.alpine.m1
