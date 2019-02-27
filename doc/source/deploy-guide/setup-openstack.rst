Setup OpenStack
===============

.. blockdiag::

   blockdiag {

     localhost [label="Prepare localhost"]
     ses [label="Deploy SES\n(optional)"]
     caasp [label="Deploy CaaSP\n(optional)"]
     deployer [label="Deploy deployer\n(optional)"]
     enroll_caasp [label="Enroll CaaSP\n(optional)"]
     setup_caasp_workers [label="Setup CaaSP\nfor OpenStack"]
     patch_upstream [label="Apply patches\nfrom upstream\n(for developers)"]
     build_images [label="Build docker images\n(for developers)"]
     deploy [label="Deploy Airship or\nOpenStack-Helm"]
     configure_deployment [label="Configure deployment"]

     localhost -> ses;

     group {
       color = "#EEEEEE"
       label = "Setup hosts"
       ses -> caasp;
       caasp -> deployer [folded];
       deployer -> enroll_caasp;
     }
     enroll_caasp -> configure_deployment [folded];
     localhost -> configure_deployment[folded];

     configure_deployment -> setup_caasp_workers;

     group {
       color = "red"
       label = "Setup openstack/Setup airship"
       setup_caasp_workers -> deploy, patch_upstream [folded];
       patch_upstream -> build_images;
       build_images -> deploy;
     }
   }

From this point forward, you should decide to deploy Airship or OpenStack-Helm
directly.

In separate steps
-----------------

Configuring CaaSP
~~~~~~~~~~~~~~~~~

Run the following to configure the CaaSP nodes for OpenStack:

.. code-block:: console

   ./run.sh setup_caasp_workers_for_openstack

This will update your caasp workers to:

* Point to your `deployer` host in `/etc/hosts`
* Copy your registry certificates (should developer mode be enabled)
* Create some directories of your workers with rw mode for OpenStack software.

Run developer plays
~~~~~~~~~~~~~~~~~~~

If you are a developer and want to apply upstream patches (but not
carry your own fork), you might want to run:

.. code-block:: console

   export OSH_DEVELOPER_MODE='True'
   ./run.sh patch_upstream

Build your own images by running:

.. code-block:: console

   export OSH_DEVELOPER_MODE='True'
   ./run.sh build_images

Deploy Airship/OpenStack-Helm
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you want to deploy OpenStack-Helm without Airship, run:

.. code-block:: console

   ./run.sh deploy_osh

Alternatively, if you want to use Airship to deploy OpenStack, run:

.. code-block:: console

   ./run.sh deploy_airship

In a single step
----------------

All of the above steps can be summarized in a single command.

For OpenStack-Helm only
~~~~~~~~~~~~~~~~~~~~~~~

Run the following to deploy OpenStack-Helm only:

.. code-block:: console

   ./run.sh setup_openstack

If you want to patch upstream helm charts and/or build your own images,
you need to run the following:

.. code-block:: console

   export OSH_DEVELOPER_MODE='True'
   ./run.sh setup_openstack

For Airship deployment
~~~~~~~~~~~~~~~~~~~~~~

Run the following to deploy Airship:

.. code-block:: console

   ./run.sh setup_airship

If you want to patch upstream helm charts and/or build your own images,
you need to run the following:

.. code-block:: console

   export OSH_DEVELOPER_MODE='True'
   ./run.sh setup_airship
