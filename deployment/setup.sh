#! /bin/sh -x

terraform init
terraform apply --auto-approve -var "curdir=${PWD}" -var-file=infra.tfvars
