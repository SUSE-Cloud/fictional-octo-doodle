#!/bin/bash



function run_ansible(){
    set -x
    # ansible-runner default locations
    if [[ -z ${ANSIBLE_RUNNER_DIR+x} ]]; then
        echo "ANSIBLE_RUNNER_DIR env var is not set, defaulting to '~/suse-socok8s-deploy'"
        export ANSIBLE_RUNNER_DIR="${HOME}/suse-socok8s-deploy"
    fi

    extravarsfile=${ANSIBLE_RUNNER_DIR}/env/extravars
    inventorydir=${ANSIBLE_RUNNER_DIR}/inventory/

    # This creates a structure that's similar to ansible-runner tool
    if [[ ! -d ${ANSIBLE_RUNNER_DIR} ]]; then
        mkdir -p ${ANSIBLE_RUNNER_DIR}/{env,inventory} || true
        echo "Adding an empty inventory by default"
        cp ${socok8s_absolute_dir}/examples/workdir/inventory/hosts.yml ${inventorydir}/skeleton-inventory.yml
    else
	if [[ ! -f ${inventorydir}/skeleton-inventory.yml ]]; then
            echo "No skeleton inventory found, adding one"
            cp ${socok8s_absolute_dir}/examples/workdir/inventory/hosts.yml ${inventorydir}/skeleton-inventory.yml
	fi
    fi

    if [[ -f ${extravarsfile} ]]; then
        echo "Extra variables file exists: $(realpath ${extravarsfile}). Loading its vars in ansible-playbook call."
        extra_vars="-e @${extravarsfile}"
    fi

    if [[ -f ${inventorydir} ]]; then
        echo "Inventory directory (${inventorydir}) exists, adding it to the ansible-playbook call."
        inventory="-i ${inventorydir}"
    fi
    if [[ ${USE_ARA:-False} == "True" ]]; then
        echo "Loading ARA"
        source ${ANSIBLE_RUNNER_DIR}/.ansiblevenv/ara.rc
    fi

    pushd ${socok8s_absolute_dir}
        ansible-playbook ${extra_vars:-} -i ${inventorydir} $@ -v
    popd
    set +x
}
