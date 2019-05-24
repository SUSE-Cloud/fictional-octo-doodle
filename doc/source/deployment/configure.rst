.. _configuredeployment:

Configure Cloud
===============

.. blockdiag::

   blockdiag {
     default_fontsize = 11;
     deployer [label="Setup deployer"]
     ses_integration [label="SES Integration"]
     configure [label="Configure\nCloud"]
     setup_caasp_workers [label="Setup CaaS Platform\nworker nodes"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build Docker images\n(for developers)"]
     deploy_airship [label="Deploy Airship"]
     deploy_openstack [label="Deploy OpenStack"]

     group {
       configure
       color="red"
     }

     deployer -> ses_integration;
     ses_integration -> configure;
     configure -> setup_caasp_workers;

     group {
       color = "#EEEEEE"
       label = "Cloud Deployment"
       setup_caasp_workers -> patch_upstream;
       patch_upstream -> build_images;
       build_images -> deploy_airship [folded];
       setup_caasp_workers -> deploy_airship;
       deploy_airship -> deploy_openstack;
     }
   }


This :term:`workspace`, structured like an `ansible-runner` directory,
contains the following deployment artifacts:

| socok8s-workspace
| ├── inventory
| │   └── hosts.yml
| ├── env
| │   └── extravar
| ├── ses_config.yml
| └── kubeconfig


Configure the Inventory
-----------------------

You can create an inventory based on the hosts.yml file in the `examples`
folder.  (*examples/workdir/inventory/hosts.yml*)

.. literalinclude:: ../../../examples/workdir/inventory/hosts.yml

For each group, a `hosts:` key should be added for each of the hosts you are
using. For example:

.. code-block:: yaml

   airship-openstack-control-workers:
     hosts:
       caasp-worker-001:
         ansible_host: 10.86.1.144

The group `airship-ucp-workers` specifies the list of CaaS Platform worker
nodes to which the Airship Under Cloud Platform (UCP) services will be
deployed. The UCP services in socok8s include Armada, Shipyard, Deckhand,
Pegleg, Keystone, Barbican, and core infrastructure services such as
MariaDB, RabbitMQ, and PostgreSQL.

The group `airship-openstack-control-workers` specifies the list of CaaS
Platform worker nodes that make up the OpenStack control plane. The
OpenStack control plane includes Keystone, Glance, Cinder, Nova, Neutron,
Horizon, Heat, MariaDB, RabbitMQ and so on.

The group `airship-openstack-compute-workers` defines the CaaS Platform worker
nodes used as OpenStack Compute Nodes. Nova Compute, Libvirt, Open vSwitch (OVS)
are deployed to these nodes.

For most users, UCP and OpenStack control planes can share the same worker
nodes. The OpenStack Compute Nodes should be dedicated worker nodes unless
a light workload is expected.

See also
`Ansible Inventory Hosts and Groups
<https://docs.ansible.com/ansible/2.7/user_guide/intro_inventory.html#hosts-and-groups>`_.

.. tip::

   Do not add `localhost` as a host in your inventory.
   It is a host specially considered by Ansible.
   If you want to create an inventory node for your local
   machine, add your machine's hostname inside your inventory,
   and specify this host variable: **ansible_connection: local**

.. note ::

   If Deployer is running as a non-root user, replace ansible_user: value for
   the soc-deployer entry with your logged in user.

Configure for SES Integration
-----------------------------

The file `ses_config.yml` is the output from :ref:`ses_integration`, and must
be present in the workspace.

The Ceph admin keyring and user keyring, in **base64**, must be present in the
file `env/extravars` in your workspace.

The Ceph admin keyring can be obtained by running the following on ceph host.

.. code-block:: yaml

  echo $( sudo ceph auth get-key client.admin ) | base64

For example:

.. code-block:: yaml

  ceph_admin_keyring_b64key: QVFDMXZ6dGNBQUFBQUJBQVJKakhuYkY4VFpublRPL1RXUEROdHc9PQo=
  ceph_user_keyring_b64key: QVFDMXZ6dGNBQUFBQUJBQVJKakhuYkY4VFpublRPL1RXUEROdHc9PQo=

Configure for Kubernetes
------------------------

socok8s relies on kubectl and Helm commands to configure your OpenStack
deployment. You need to provide a `kubeconfig` file on the `deployer` node,
in your workspace. You can fetch this file from the Velum UI on your
SUSE CaaS Platform cluster.

Configure the VIP that will be used for OpenStack service public endpoints
--------------------------------------------------------------------------

Add `socok8s_ext_vip:` with its appropriate value for your
environment in your `env/extravars`. This should be an available IP
on the external network (in a development environment, it can be the same as
CaaSP cluster network).

For example:

.. code-block:: yaml

   socok8s_ext_vip: "10.10.10.10"


Configure the VIP that will be used for Airship UCP service endpoints
--------------------------------------------------------------------------

Add `socok8s_dcm_vip:` with its appropriate value for your
environment in your `env/extravars`. This should be an available IP
on the Data Center Management (DCM) network (in development environment, it
can be the same as CaaSP cluster network).

For example:

.. code-block:: yaml

   socok8s_dcm_vip: "192.168.51.35"


Configure Cloud Scale Profile
-----------------------------

The Pod scale profile in socok8s allows you to specify the desired number of
Pods that each Airship and OpenStack service should run.

There are two built-in scale profiles: `minimal` and `ha`. `minimal` will
deploy exactly one Pod for each service, making it suitable for demo or trial
on a resource-limited system. `ha` (High Availability) ensures at least two
instances of Pods for all services, and three or more Pods for services that
require quorum and are more heavily used.

To specify the scale profile to use, add `scale_profile:` in the
`env/extravars`.

For example:


.. code-block:: yaml

   scale_profile: ha

The definitions of the Pod scale profile can be found in this repository:
playbooks/roles/airship-deploy-ucp/files/profiles.

You can customize the built-in profile or create your own profile following
the file name convention.


Advanced Configuration
----------------------

socok8s deployment variables respects Ansible general precedence.
Therefore all the variables can be adapted.

You can override most user-facing variables with host vars and
group vars.

.. note ::

   You can also use extravars, as they always win.
   extravars can be used to override any deployment code.
   Use it at your own risk.

socok8s is flexible, and allows you to override the value of any upstream Helm
chart value with the appropriate overrides.

.. note ::

   Please read the page :ref:`userscenarios` for inspiration on overrides.
