#! /bin/sh -x

terraform destroy --auto-approve -var "curdir=${PWD}" -var-file=infra.tfvars
rm -rf gitolite-admin
#rm -rf /tmp/spms
