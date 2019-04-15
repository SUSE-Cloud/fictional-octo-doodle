#!/bin/bash

set -o errexit

if [[ "${SOCOK8S_DEVELOPER_MODE:-False}" == "True" ]]; then
    set -x
fi

scripts_absolute_dir="$( cd "$(dirname "$0")/script_library" ; pwd -P )"
socok8s_absolute_dir="$( cd "$(dirname "$0")" ; pwd -P )"

# USE an env var to setup where to deploy to
# by default, ccp will deploy on openstack for inception style fun (and CI).
# DEPLOYMENT_MECHANISM=${DEPLOYMENT_MECHANISM:-"openstack"}
# DEPLOYMENT_MECHANISM is set by argbash now always.

source ${scripts_absolute_dir}/bootstrap-ansible-if-necessary.sh
source ${scripts_absolute_dir}/pre-flight-checks.sh check_jq_present
source ${scripts_absolute_dir}/pre-flight-checks.sh check_ansible_requirements
source ${scripts_absolute_dir}/pre-flight-checks.sh check_git_submodules_are_present

# Bring an ansible runner that allows a userspace environment
source ${scripts_absolute_dir}/run-ansible.sh

pushd ${socok8s_absolute_dir}

# All the deployment actions (deploy steps) are defined in script_library/actions-openstack.sh for example.
# For simplificity, the following script contains each action for a deploy mechanism, and each action should
# contain a "master" playbook, which should be named playbooks/${DEPLOYMENT_MECHANISM}-${deployment_action}
source ${scripts_absolute_dir}/deployment-actions-${DEPLOYMENT_MECHANISM}.sh

# When automation is changed to introduce steps,
# replace this line with the following line:
# deployment_action=$1
# deployment_action=${1:-"setup_everything"}
# the default is set in the _parsing.m4 for command
deployment_action=$_arg_command


case "$deployment_action" in
    "deploy_ses")
        deploy_ses
        ;;
    "deploy_caasp")
        deploy_caasp
        ;;
    "deploy_ccp_deployer")
        # CCP deployer is a node that will be used to control k8s cluster,
        # as we shouldn't do it on caasp cluster (microOS and others)
        deploy_ccp_deployer
        ;;
    "enroll_caasp_workers")
        enroll_caasp_workers
        ;;
    "patch_upstream")
        patch_upstream
        ;;
    "build_images")
        build_images
        ;;
    "deploy_osh")
        deploy_osh
        ;;
    "add_compute")
        add_compute
        ;;
    "setup_caasp_workers_for_openstack")
        setup_caasp_workers_for_openstack
        ;;
    "setup_hosts")
        deploy_ses
        deploy_caasp
        deploy_ccp_deployer
        enroll_caasp_workers
        ;;
    "setup_openstack")
        setup_caasp_workers_for_openstack
        patch_upstream
        build_images
        deploy_osh
        ;;
    "setup_airship")
        setup_caasp_workers_for_openstack
        airship_prepare
        deploy_airship
        ;;
    "deploy_airship")
        deploy_airship
        ;;
    "update_airship_osh")
        deploy_airship update_airship_osh_site
        ;;
    "setup_everything")
        deploy_ses
        deploy_caasp
        deploy_ccp_deployer
        enroll_caasp_workers
        setup_caasp_workers_for_openstack
        patch_upstream
        build_images
        deploy_osh
        ;;
    "teardown")
        teardown
        ;;
    "clean_k8s")
        clean_k8s
        ;;
    "clean_airship_not_images")
        clean_airship clean_openstack_clean_ucp_clean_rest
        ;;
    "clean_airship")
        clean_airship
        ;;
    *)
        echo "Parameter unknown, read run.sh code."
        ;;
esac
