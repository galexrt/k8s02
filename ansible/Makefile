HETZNER_CLOUD_KEY := $(TF_VAR_hcloud_token)
ANSIBLE_HOST_KEY_CHECKING ?= False

all: preflight

preflight: galaxy run-prepare ping

galaxy:
	@## `-n` ignores dependencies because galaxy is currently broken for all my modules
	@## thus forcing me to just add every role in the `requirements.yml`
	ansible-galaxy install --force -n -r requirements.yml

ping:
	ansible -i inventory all -m ping

run-prepare:
	ansible-playbook -i inventory playbooks/prepare.yml

help: ## Show this help menu.
	@grep -E '^[a-zA-Z_-%]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
.EXPORT_ALL_VARIABLES:
.PHONY: all galaxy preflight ping run-prepare help
