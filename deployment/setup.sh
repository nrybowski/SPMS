#! /bin/sh -x

terraform apply --auto-approve -var "curdir=${PWD}" -var-file=infra.tfvars
