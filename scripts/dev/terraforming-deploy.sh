#!/bin/bash

set -e
set -x
env | grep -e OS_ -e SSH_ -e LIBVIRT_DEFAULT_URI -e TERRAFORM

if [[ `find -maxdepth 1 -type f -name '*.tf'` == "" ]]; then
    echo "Seeding up tf files for openstack"
    # No tf things. Take them from containers.
    # Please remove the *.tf files on upgrade.
    cp -r /usr/share/caasp/terraform/openstack/* ./
fi

if [[ ! -d .terraform ]]; then
    terraform init -input=false
fi

terraform validate .
if [[ ! -z "${TERRAFORM_APPLY_AUTOAPPROVE:-}" ]]; then
    terraform_args="-auto-approve"
fi
terraform apply ${terraform_args:-} ./
terraform output -json > ./terraform-output.json
echo "Cloud instances successfully deployed"

# Skuba init
CLUSTER_NAME="caasp4-cluster" # Please be consistent with destroy.
if [[ ! -d ./${CLUSTER_NAME} ]]; then
    #load_balancer=$(jq --raw-output '.ip_load_balancer.value' terraform-output.json)
    load_balancer=$(jq --raw-output '.ip_masters.value[0]' terraform-output.json)
    skuba cluster init ${CLUSTER_NAME} --control-plane ${load_balancer}
fi

cd ${CLUSTER_NAME}

if [[ -f admin.conf ]]; then
    echo "Checking cluster status"
    cluster_status=$(skuba cluster status)
    echo $cluster_status
fi

# Skuba master deploy
if [ "$cluster_status" == "" ] || [ ! `echo $cluster_status | grep master-0` ]; then
    master_ip=$(jq --raw-output '.ip_masters.value[0]' ../terraform-output.json)
    echo "Bootstrapping master through ${master_ip}"
    skuba node bootstrap master-0 -s -t ${master_ip} -u ${IMAGE_USERNAME} -v 2
fi

# Skuba workers deploy
let i=1
for worker in $(jq --raw-output '.ip_workers.value[]' ../terraform-output.json); do
    echo "Bootstrapping worker ${i} through ip ${worker}"
    skuba node join worker-${i} -r worker -s -t ${worker} -u ${IMAGE_USERNAME} -v 2
    let i++
done

cp /workdir/tf/${CLUSTER_NAME}/admin.conf /workdir/kubeconfig
