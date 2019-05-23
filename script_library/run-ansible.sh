#!/bin/bash



function run_ansible(){
    set -x

    # NOTE(toabctl): ${SOCOK8S_WORKSPACE_BASEDIR} and ${SOCOK8S_ENVNAME} are always set
    local socok8s_workspace=${SOCOK8S_WORKSPACE_BASEDIR}/${SOCOK8S_ENVNAME}-workspace

    extravarsfile=${socok8s_workspace}/env/extravars
    inventorydir=${socok8s_workspace}/inventory/

    # This creates a structure that's similar to ansible-runner tool
    [[ ! -d ${socok8s_workspace}/env ]] && mkdir -p ${socok8s_workspace}/env
    if [[ ! -d ${socok8s_workspace}/inventory ]]; then
        mkdir -p ${socok8s_workspace}/inventory
        # Ensure default groupnames exist. It also DRY so that we automatically connect on hosts as root.
        # However don't force this by default if people already have an inventory.
        cp ${socok8s_absolute_dir}/examples/workdir/inventory/hosts.yml ${inventorydir}/default-inventory.yml
    fi

    if [[ -f ${extravarsfile} ]]; then
        echo "Extra variables file exists: $(realpath ${extravarsfile}). Loading its vars in ansible-playbook call."
        extra_vars="-e @${extravarsfile}"
    fi

    if [[ ${USE_ARA:-False} == "True" ]]; then
        echo "Loading ARA"
        source ${socok8s_workspace}/ara.rc
    fi

    pushd ${socok8s_absolute_dir}
        ansible-playbook ${extra_vars:-} -i ${inventorydir} $@ -v
    popd
    set +x
}
