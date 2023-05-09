# this was seeded from https://github.com/umsi-mads/education-notebook/blob/master/Makefile
.PHONEY: help build ope root push publish lab nb python-versions distro-versions image-sha clean
.IGNORE: ope root

# -------- Configuration --------
SHELL := /bin/bash
CUST := $(shell git branch --show-current)

VERSION := latest

OPE_BOOK := $(shell basename "$$(pwd)")
OPE_UID := $(shell cat base/ope_uid)
OPE_GID := $(shell cat base/ope_gid)
OPE_GROUP := $(shell cat base/ope_group)

BASE_REG := $(shell cat base/base_registry)/
BASE_IMAGE := $(shell cat base/base_image)
BASE_TAG := $(shell cat base/base_tag)

DATE_TAG := $(shell date +"%m.%d.%y_%H.%M.%S")

OPE_REGISTRY_USER := $(shell echo $(REGISTRY_USER))
OPE_REGISTRY := $(shell echo $(REGISTRY))/
OPE_IMAGE := $(REGISTRY_USER)/$(OPE_BOOK)
OPE_TAG := :$(CUST)
OPE_BETA_TAG := :beta-$(CUST)

BASE_DISTRO_PACKAGES := $(shell cat base/distro_pkgs)


# use recursive assignment to defer execution until we have mamba versions made
PYTHON_PREREQ_VERSIONS_STABLE =  $(shell cat base/python_prereqs | base/mkversions)
PYTHON_INSTALL_PACKAGES_STABLE = $(shell cat base/python_pkgs | base/mkversions)
PIP_INSTALL_PACKAGES_STABLE = $(shell cat base/pip_pkgs)

PYTHON_PREREQ_VERSIONS := $(shell cat base/python_prereqs)
PYTHON_INSTALL_PACKAGES := $(shell cat base/python_pkgs)
PIP_INSTALL_PACKAGES := $(shell cat base/pip_pkgs)

JUPYTER_ENABLE_EXTENSIONS := $(shell cat base/jupyter_enable_exts)
JUPYTER_DISABLE_EXTENSIONS := $(shell if  [[ -a base/jupyter_disable_exts  ]]; then cat base/jupyter_disable_exts; fi) 

# build gdb from source to ensure we get the right version and build with tui support
GDB_BUILD_SRC := gdb-12.1

# expand installation so that the image feels more like a proper UNIX user environment with man pages, etc.
UNMIN := yes


# Common docker run configuration designed to mirror as closely as possible the openshift experience
# if port mapping for SSH access
SSH_PORT := 2222

# we mount here to match openshift
MOUNT_DIR := /opt/app-root/src
HOST_DIR := ${HOME}

ifeq ($(VERSION),stable)
 PYTHON_PREREQ_VERSIONS = $(PYTHON_PREREQ_VERSIONS_STABLE)
 PYTHON_INSTALL_PACKAGES = $(PYTHON_INSTALL_PACKAGES_STABLE)
 PIP_INSTALL_PACKAGES = $(PIP_INSTALL_PACKAGES_STABLE)
endif

# -------- Action Targets --------

build: DARGS ?= --build-arg FROM_REG=$(BASE_REG) \
                   --build-arg FROM_IMAGE=$(BASE_IMAGE) \
                   --build-arg FROM_TAG=$(BASE_TAG) \
                   --build-arg OPE_UID=$(OPE_UID) \
                   --build-arg OPE_GID=$(OPE_GID) \
                   --build-arg OPE_GROUP=$(OPE_GROUP) \
                   --build-arg ADDITIONAL_DISTRO_PACKAGES="$(BASE_DISTRO_PACKAGES)" \
                   --build-arg PYTHON_PREREQ_VERSIONS="$(PYTHON_PREREQ_VERSIONS)" \
                   --build-arg PYTHON_INSTALL_PACKAGES="$(PYTHON_INSTALL_PACKAGES)" \
                   --build-arg PIP_INSTALL_PACKAGES="$(PIP_INSTALL_PACKAGES)" \
                   --build-arg JUPYTER_ENABLE_EXTENSIONS="$(JUPYTER_ENABLE_EXTENSIONS)" \
                   --build-arg JUPYTER_DISABLE_EXTENSIONS="$(JUPYTER_DISABLE_EXTENSIONS)" \
                   --build-arg GDB_BUILD_SRC=$(GDB_BUILD_SRC) \
                   --build-arg UNMIN=$(UNMIN)
build: ## Make the image customized appropriately
	docker build $(DARGS) $(DCACHING) -t $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG) base

pull: ## pull most recent public version
	docker pull $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_TAG)

pull-beta: ## pull most recent beta version
	docker pull $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG)

push-beta: ## push beta build
# make dated version
	docker tag $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG) $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG)_$(DATE_TAG)
# push beta image with dated
	docker push $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG)_$(DATE_TAG)
# push beta image without dated
	docker push $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG)

publish: pull-beta 
publish: 
# re tag beta as stable
	docker tag $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG) $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_TAG)_$(DATE_TAG)
	docker tag $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG) $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_TAG)
# push to private image repo
	docker push $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_TAG)_$(DATE_TAG)
	docker push $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_TAG)


checksum: ARGS ?= find / -not \( -path /proc -prune \) -not \( -path /sys -prune \) -type f -exec stat -c '%n %a' {} + | LC_ALL=C sort | sha256sum
checksum: DARGS ?= -u 0
checksum: ## start private version  with root shell to do admin and poke around
	@-docker run -i --rm $(DARGS) $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG) $(ARGS)



# -------- Utility and Development Targets --------
help:
# http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
	@grep -E '^[a-zA-Z0-9_%/-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

base/mamba_versions: pull
base/mamba_versions: DARGS ?=
base/mamba_versions:
	docker run -it --rm $(DARGS) $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_TAG) /bin/bash -c "mamba list | cat" | tr -d '\r' > $@

base/distro_versions: pull
base/distro_versions: DARGS ?=
base/distro_versions:
	docker run -it --rm $(DARGS) $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_TAG)  /bin/bash -c "apt list | cat"  | tr -d '\r' > $@

versions: base/mamba_versions base/distro_versions


root: ARGS ?= /bin/bash
root: DARGS ?= -u 0
root: ## start private version  with root shell to do admin and poke around
	-docker run -it --rm $(DARGS) $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG) $(ARGS)

user: ARGS ?= /bin/bash
user: DARGS ?=
user: ## start private version with usershell to poke around
	-docker run -it --rm $(DARGS) $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG) $(ARGS)

run: ARGS ?=
run: DARGS ?= -u $(OPE_UID):$(OPE_GID) -v "${HOST_DIR}":"${MOUNT_DIR}" -v "${SSH_AUTH_SOCK}":"${SSH_AUTH_SOCK}" -v "${SSH_AUTH_SOCK}":"${SSH_AUTH_SOCK}" -e SSH_AUTH_SOCK=${SSH_AUTH_SOCK} -p ${SSH_PORT}:22
run: PORT ?= 8888
run: ## start published version with jupyter lab interface
	docker run -it --rm -p $(PORT):$(PORT) $(DARGS) $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_TAG) $(ARGS) 


run-beta: ARGS ?=
run-beta: DARGS ?= -u $(OPE_UID):$(OPE_GID) -v "${HOST_DIR}":"${MOUNT_DIR}" -v "${SSH_AUTH_SOCK}":"${SSH_AUTH_SOCK}" -v "${SSH_AUTH_SOCK}":"${SSH_AUTH_SOCK}" -e SSH_AUTH_SOCK=${SSH_AUTH_SOCK} -p ${SSH_PORT}:22
run-beta: PORT ?= 8888
run-beta: ## start published version with jupyter lab interface
	docker run --rm -p $(PORT):$(PORT) $(DARGS) $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG) $(ARGS)

show-run-beta: ARGS ?=
show-run-beta: DARGS ?= -u $(OPE_UID):$(OPE_GID) -v "${HOST_DIR}":"${MOUNT_DIR}" -v "${SSH_AUTH_SOCK}":"${SSH_AUTH_SOCK}" -v "${SSH_AUTH_SOCK}":"${SSH_AUTH_SOCK}" -e SSH_AUTH_SOCK=${SSH_AUTH_SOCK} -p ${SSH_PORT}:22
show-run-beta: PORT ?= 8888
show-run-beta: ## start published version with jupyter lab interface
	@-echo "docker run -it --rm -p $(PORT):$(PORT) $(DARGS) $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_TAG) $(ARGS)""

show-tag: ## show current tag
	@-echo $(OPE_REGISTRY)$(OPE_IMAGE)$(OPE_BETA_TAG)

