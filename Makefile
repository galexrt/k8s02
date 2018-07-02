GO := go

all: preflight terraform ansible

preflight: hcloud-ansible-inv

hcloud-ansible-inv:
	$(GO) get -u github.com/thannaske/hcloud-ansible-inv
	$(GO) install github.com/thannaske/hcloud-ansible-inv/cmd/hcloud-ansible-inv

terraform:
	make -C terraform/ all

ansible:
	make -C ansible/ all

help: ## Show this help menu.
	@grep -E '^[a-zA-Z_-%]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: all terraform ansible help
