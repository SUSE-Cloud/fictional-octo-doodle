#!/bin/bash
#set -o errexit

MAIN_FOLDER="$(readlink -f $(dirname ${0})/..)"
CURRENT_FOLDER="$(readlink -f $(dirname ${0}))"

source ${MAIN_FOLDER}/script_library/pre-flight-checks.sh check_openstack_env_vars_set

SERVER_NAME=${PREFIX}-${SERVER_NAME:-'ses'}
SERVER_IMAGE=${SERVER_IMAGE:-"SLES12-SP3"}
SERVER_FLAVOR=${SERVER_FLAVOR:-"m1.large"}
SECURITY_GROUP=${SECURITY_GROUP:-"all-incoming"}
EXTERNAL_NETWORK="floating"
INTERNAL_NETWORK=${INTERNAL_NETWORK:-"${PREFIX}-net"}

openstack server delete --wait ${SERVER_NAME}
openstack volume delete ${SERVER_NAME}-vol

pushd ${MAIN_FOLDER}
    if [ -f .ses_ip ]; then
        echo "Cleaning up known hosts"
        ssh-keygen -R $(cat .ses_ip)
        rm .ses_ip
    fi
    if [ -f inventory-ses.ini ]; then
        echo "Cleaning up inventory"
        rm inventory-ses.ini
    fi
popd
