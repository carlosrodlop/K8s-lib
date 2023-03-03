MKFILE := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
#PARENT_MKFILE   := $(HOME)/.Makefile # It requires to be run docker
PARENT_MKFILE   := $(MKFILE)/../../../carlosrodlop/Makefile # local

include $(PARENT_MKFILE)
