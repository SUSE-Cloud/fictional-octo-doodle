.. _operationsdocumentation:

===================================
Administration and Operations Guide
===================================

In this section, you will find information on the adminsitration and
operations of SUSE Containerized Openstack.


Scaling in/out
==============

Adding or removing compute nodes
--------------------------------
To add a compute node, the node must be running SUSE CaaS Platform v3.0 and have been accepted into the cluster and bootstrapped using the Velum dashboard. Once the node is bootstrapped, add its host details to the "airship-openstack-compute-workers" group in your inventory in ${WORKSPACE}/inventory/hosts.yaml, then run the following command from the root of the socok8s directory:

.. code-block:: console

   ./run.sh add_compute

.. note::

   Multiple new compute nodes can be added to the inventory at the same time.

To remove a compute node, run the following command from the root of the socok8s directory:

.. code-block:: console

   ./run.sh remove_compute ${NODE_HOSTNAME}

.. note::

   Although multiple compute nodes can be added at the same time, they must be removed individually. Once the node has been successfully removed, the host details must be removed from "airship-openstack-compute-workers" group in the inventory.

Change control plane scale profile
----------------------------------
SUSE Containerized OpenStack provides two built-in scale profiles: "minimal," which deploys a single pod for each service, and "ha," which is the default profile and deploys a minimum of 2 pods for each service, or 3 or more pods for services that will be heavily utilized or require a quorum. Changing scale profiles can be accomplished by adding a "scale_profile" key to ${WORKSPACE}/env/extravars and specifying a profile value:

.. code-block:: yaml

   scale_profile: minimal

The built-in profiles are defined in playbooks/roles/airship-deploy-ucp/files/profiles and can be modified to suit custom use cases. Additional profiles can also be created and added to this directory following the same file naming convention.

Once the appropriate profile has been selected, it can be applied by running the following command from the root of the socok8s directory:

.. code-block:: console

   ./run.sh deploy_airship

Updates
=======

SUSE Containerized OpenStack is delivered as an rpm package, so performing updates is generally accomplished by simply updating the rpm package to the latest version and redeploying the cloud using the steps outlined in the installation procedures. This is the typical update path and will incorporate all recent changes, as well as automatically updating component chart and image versions. However, it is also possible to update services and components directly using the procedures outlined below.

Updating OpenStack Version
--------------------------

To make a global change to the OpenStack version used by all component images, create a key in ${WORKSPACE}/env/extravars called "suse_openstack_image_version" and set it to the desired value. For example, to use the "stein" version, add the following line to the extravars file:

.. code-block:: yaml

   suse_openstack_image_version: "stein"

It is also possible to update an individual image or subset of images to a different version, rather than making a global change. To do this, it will be necessary to manually edit the versions.yaml file located in socok8s/site/soc/software/config/. Locate the images that need to be changed in the "images" section of the file and modify the line to include the desired version. For example, to use the "stein" version for the heat_api image, change the following line in versions.yaml from

.. code-block:: yaml

   heat_api: "{{ suse_osh_registry_location }}/openstackhelm/heat:{{ suse_openstack_image_version }}"

to

.. code-block:: yaml

   heat_api: "{{ suse_osh_registry_location }}/openstackhelm/heat:stein"

Updating Individual Images and Helm Charts
------------------------------------------

The versions.yaml file can also be used for more advanced update configurations such as using a specific image or Helm chart source version. 

.. note::
   
   Changing the image registry location from its default value or using a custom or non-default image will lose any product support by SUSE.

To specify the use of an updated or customized image, locate the appropriate image name in socok8s/site/soc/software/config/versions.yaml and modify the line to include the desired image location and tag. For example, to use a new heat_api image, modify its entry with the new image location:

.. code-block:: yaml

   heat_api: "registry_location/image_directory/image_name:tag"

Similarly, the versions.yaml file can be used to retrieve a specific version of any Helm chart being deployed. To do so, it will be necessary to provide a repository location, type, and a reference. The reference can be a branch, commit ID, or a reference in the repository and will default to "master" if not specified. As an example, to use a specific version of the Helm chart for Heat, add the following information to the "osh" section under "charts":

.. code-block:: yaml

     heat:
       location: https://git.openstack.org/openstack/openstack-helm
       reference: ${REFERENCE}
       subpath: heat
       type: git

.. note::

   When specifying a particular version of a Helm chart, it may be necessary to first create the appropriate subsection under "charts". Airship components such as Deckhand and Shipyard belong under "ucp", OpenStack services belong under "osh", and infrastructure components belong under "osh_infra".

Update Certificates
-------------------

Troubleshooting
===============

Viewing Shipyard Logs
---------------------

Since the deployment of OpenStack components in SUSE Containerized OpenStack is directed by Shipyard, the Airship platform's DAG controller, it is often one of the best places to begin troubleshooting deployment problems. The Shipyard CLI client authenticates with Keystone, so it is necessary to set the following environment variables before running any commands:

.. code-block:: console

   export OS_USERNAME=shipyard
   export OS_PASSWORD=$(kubectl get secret -n ucp shipyard-keystone-user -o json | jq -r '.data.OS_PASSWORD' | base64 -d)

.. note::

   Alternatively, the shipyard user's password can be obtained from the contents of ${WORKSPACE}/secrets/ucp_shipyard_keystone_password

The following commands are all run from the /opt/airship/shipyard/tools directory. If no Shipyard image is found when the first command is executed, it will be downloaded automatically.

To view the status of all Shipyard actions, run

.. code-block:: console

   ./shipyard.sh get actions

Example output:

.. code-block:: console

   Name                   Action                                   Lifecycle        Execution Time             Step Succ/Fail/Oth        Footnotes        
   update_software        action/01D9ZSVG70XS9ZMF4Z6QFF32A6        Complete         2019-05-03T21:33:27        13/0/1                    (1)              
   update_software        action/01DAB3ETP69MGN7XHVVRHNPVCR        Failed           2019-05-08T06:52:58        7/0/7                     (2)       

To view the status of the individual steps of a particular action, copy its action ID and run the following command:

.. code-block:: console

  ./shipyard.sh describe action/01DAB3ETP69MGN7XHVVRHNPVCR

Example output:

.. code-block:: console

   Name:                  update_software                             
   Action:                action/01DAB3ETP69MGN7XHVVRHNPVCR           
   Lifecycle:             Failed                                      
   Parameters:            {}                                          
   Datetime:              2019-05-08 06:52:55.366919+00:00            
   Dag Status:            failed                                      
   Context Marker:        18993f2c-1cfa-4d42-9320-3fbd70e75c21        
   User:                  shipyard                                    

   Steps                                                                Index        State            Footnotes        
   step/01DAB3ETP69MGN7XHVVRHNPVCR/action_xcom                          1            success                           
   step/01DAB3ETP69MGN7XHVVRHNPVCR/dag_concurrency_check                2            success                           
   step/01DAB3ETP69MGN7XHVVRHNPVCR/deployment_configuration             3            success                           
   step/01DAB3ETP69MGN7XHVVRHNPVCR/validate_site_design                 4            success                           
   step/01DAB3ETP69MGN7XHVVRHNPVCR/armada_build                         5            failed                           
   step/01DAB3ETP69MGN7XHVVRHNPVCR/decide_airflow_upgrade               6            None                              
   step/01DAB3ETP69MGN7XHVVRHNPVCR/armada_get_status                    7            success                           
   step/01DAB3ETP69MGN7XHVVRHNPVCR/armada_post_apply                    8            upstream_failed                           
   step/01DAB3ETP69MGN7XHVVRHNPVCR/skip_upgrade_airflow                 9            upstream_failed                              
   step/01DAB3ETP69MGN7XHVVRHNPVCR/upgrade_airflow                      10           None                              
   step/01DAB3ETP69MGN7XHVVRHNPVCR/deckhand_validate_site_design        11           success                           
   step/01DAB3ETP69MGN7XHVVRHNPVCR/armada_validate_site_design          12           upstream_failed                           
   step/01DAB3ETP69MGN7XHVVRHNPVCR/armada_get_releases                  13           failed                         
   step/01DAB3ETP69MGN7XHVVRHNPVCR/create_action_tag                    14           None                              

To view the logs from a particular step such as armada_build, which has failed in the above example, run

.. code-block:: console

   ./shipyard.sh logs step/01DAB3ETP69MGN7XHVVRHNPVCR/armada_build

Viewing Logs From Kubernetes Pods
---------------------------------

To view the logs from any pod in the Running or Completed state, run

.. code-block:: console

   kubectl logs -n ${NAMESPACE} ${POD_NAME}

To view logs from a specific container within a pod in the Running or Completed state, run

.. code-block:: console

   kubectl logs -n ${NAMESPACE} ${POD_NAME} -c ${CONTAINER_NAME}

If logs cannot be retrieved due to the pod entering the Error or CrashLoopBackoff state, it may be necessary to use the -p option to retrieve logs from the previous instance:

.. code-block:: console

   kubectl logs -n ${NAMESPACE} ${POD_NAME} -p

.. _caaspoperations:

CaaS Platform Operations
========================

Disable transactional update for development purposes
-----------------------------------------------------

CaaSP has a documentation for `transactional updates <https://www.suse.com/documentation/suse-caasp-3/book_caasp_admin/data/sec_admin_software_transactional-updates.html>`_.

It is not recommended to disable transactional updates.

Run the following to prevent a cluster from being updated:

.. code-block:: console

   systemctl --now disable transactional-update.timer

Run the following if you only want to override once a week, instead of daily:

.. code-block:: console

   mkdir /etc/systemd/system/transactional-update.timer.d
   cat << EOF > /etc/systemd/system/transactional-update.timer.d/override.conf
   [Timer]
   OnCalendar=
   OnCalendar=weekly
   EOF
   systemctl daemon-reload

Or use the traditional systemctl commands:

.. code-block:: console

   systemctl edit transactional-update.timer
   systemctl restart transactional-update.timer
   systemctl status transactional-update.timer

Check the next run:

.. code-block:: console

   systemctl list-timers


.. _kubernetesoperations:

Kubernetes Operations
=====================

Kubernetes has documentation for `troubleshooting typical problems with applications and clusters <https://kubernetes.io/docs/tasks/debug-application-cluster/troubleshooting//>`_.


.. _tips_and_tricks:

Tips and Tricks
===============


Display all images used by a component
--------------------------------------

Use neutron as n example:

.. code-block:: console

   kubectl get pods -n openstack -l application=neutron -o jsonpath="{.items[*].spec.containers[*].image}"|tr -s '[[:space:]]' '\n' | sort | uniq -c


Remove dangling Docker images
-----------------------------

Useful after building local images:

.. code-block:: console

   docker rmi $(docker images -f "dangling=true" -q)


Setting the default context
---------------------------

So you do not have to pass "-n openstack" all the time

.. code-block:: console

   kubectl config set-context $(kubectl config current-context) --namespace=openstack