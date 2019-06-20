#!/bin/bash

# Ensure variables are always set before going forward.
# Will prevent this script to be runned unless called from run.sh (by design)
set -o nounset

set -o errexit

echo "Deploying on OpenStack"

source ${scripts_absolute_dir}/deployment-actions-common.sh
source ${scripts_absolute_dir}/pre-flight-checks.sh check_openstack_env_vars_set

function deploy_network(){
    echo "Starting the network deployment"
    run_ansible ${socok8s_absolute_dir}/playbooks/openstack-create_network.yml
    echo "network deployment successful"
}
function deploy_ses(){
    source ${scripts_absolute_dir}/pre-flight-checks.sh check_openstack_environment_is_ready_for_deploy
    echo "Starting a SES deploy"
    run_ansible ${socok8s_absolute_dir}/playbooks/openstack-deploy_ses.yml
    echo "ses-ansible deploy is successful"
}
function deploy_caasp(){
    source ${scripts_absolute_dir}/pre-flight-checks.sh check_openstack_environment_is_ready_for_deploy
    echo "Starting caasp deploy"
    run_ansible ${socok8s_absolute_dir}/playbooks/openstack-create_caasp.yml
    echo "CaaSP deployed successfully"
}
function deploy_ccp_deployer() {
    source ${scripts_absolute_dir}/pre-flight-checks.sh check_openstack_environment_is_ready_for_deploy
    echo "Creating CCP deploy node"
    run_ansible ${socok8s_absolute_dir}/playbooks/openstack-deploy_ccp_deployer.yml
}
function enroll_caasp_workers() {
    echo "Enrolling caasp worker nodes into the cluster"
    run_ansible ${socok8s_absolute_dir}/playbooks/generic-enroll_caasp_workers.yml
}
function clean_openstack(){
    echo "Deleting on OpenStack"
    run_ansible ${socok8s_absolute_dir}/playbooks/openstack-osh_instance.yml -e osh_node_delete=True
    echo "Delete Caasp nodes"
    run_ansible ${socok8s_absolute_dir}/playbooks/openstack-delete_caasp.yml
    echo "Delete SES node"
    run_ansible ${socok8s_absolute_dir}/playbooks/openstack-ses_aio_instance.yml -e ses_node_delete=True
    echo "Delete network stack"
    run_ansible ${socok8s_absolute_dir}/playbooks/openstack-delete_network.yml
}

function teardown(){
    if [[ ${SOCOK8S_GATHER_LOGS:-"NO"} == "YES" ]]
    then
        gather_logs
    fi
    clean_openstack
    clean_userfiles
}

