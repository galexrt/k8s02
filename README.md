# k8s02
Something something Kubernetes.

## Requirements
* Terraform
* Salt
* Golang
    * With `GOPATH` set.

For help to the targets, run `make help`:
```
$ make help
apply                          Apply infrastructure plan.
destroy                        Destroy infrastructure.
help                           Show this help menu.
init                           Init terraform for usage.
plan                           Plan infrastructure/terraform operations.
```

To use the environment variable for the Hetzner Cloud token use the `TF_VAR_hcloud_token` var.
