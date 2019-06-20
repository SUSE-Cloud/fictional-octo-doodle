.. _requirements:


System Requirements
===================

Before you begin the installation, your system must meet the following
requirements.

Infrastructure
--------------

* The `Deployer` must run openSUSE Leap 15 or SUSE Linux Enterprise 15. See
  :ref:`setupdeployer` for required deployment tools and packages.

  .. note::
     To install openSUSE Leap 15, follow the instructions at
     https://software.opensuse.org/distributions/leap.

* The :term:`CaaS Platform` cluster must run the latest :term:`CaaS Platform`
  version 3.

  .. note::
     The CaaS Platform Installation Quick Start guide is available at:
     https://www.suse.com/documentation/suse-caasp-3/singlehtml/book_caasp_installquick/book_caasp_installquick.html.

     You must register the CaaS Platform product to get access to the update
     repository. We strongly recommend enabling the auto-update repository
     during CaaS Platform installation. If auto update is not enabled, you
     must run ``transactional update`` following the instructions from the
     `CaaSP documentation <https://www.suse.com/documentation/suse-caasp-3/book_caasp_admin/data/sec_admin_software_transactional-updates.html>`_.

* The :term:`SES` cluster must run :term:`SES` version 5.5.

  .. note::
     The SES deployment guide is available at:
     https://www.suse.com/documentation/suse-enterprise-storage-5/singlehtml/book_storage_deployment/book_storage_deployment.html


Minimum Node Specification
--------------------------

:term:`Deployer` node
+++++++++++++++++++++

* (v)CPU: 4
* Memory: 4GB
* Storage: 40GB

:term:`CaaS Platform` worker node
+++++++++++++++++++++++++++++++++

* (v)CPU: 6
* Memory: 16GB
* Storage: 80GB

  If the work node is used as Compute node, sizing should be determined by
  the target workloads on the compute node.

:term:`SES` node
++++++++++++++++

* (v)CPU: 6
*  Memory: 16GB
*  Storage: 80GB

Cluster size
------------

A minimal :term:`CaaS Platform` cluster requires one administration node, one
master node and two worker nodes.

SUSE Containerized OpenStack enrolls :term:`CaaS Platform` work nodes for two
different purposes: control plane where the Airship and OpenStack services
run and compute nodes where customer workloads are hosted.

For a minimal cloud, you should plan one worker node for the control plane,
and one or more worker nodes as OpenStack compute nodes.

For a high availability (HA) cloud, we recommend three worker nodes designated
for the Airship and OpenStack control plane, and additional worker nodes
allocated for compute. For detailed information about scale profiles, see
:ref:`configurecloudscaleprofile`.

Network Requirements
--------------------

* CaaS Platform networking
    Create necessary CaaS Platform networks before deploying SUSE Containerized
    OpenStack. Separating traffic by function is recommended but not required.

* Storage Network
    A separate storage network can be created to isolate storage traffic. This
    separate network should be present on the Caas Platform and ses_config.yml
    mon_host: section.

* VIP for Airship and OpenStack
    Virtual IP address will be assigned to Pods allowing ingress to Airship
    and OpenStack services. The ingress IP assignments for these services must
    be on a subnet present on the Caas Platform nodes and an IP that is
    not currently in use. VIPs are configured in env/extravars

* DNS
    Installing SUSE Containerized OpenStack updates /etc/hosts on all CaaS Platform
    nodes and Deployer. If expanding testing beyond these devices, we
    recommend using DNS for sharing this data. It is possible to configure the
    Deployer with dnsmasq to supply DNS functionality, but this is beyond the
    scope of this preview.

Distributed Virtual Routing (DVR) is not supported in this Technology Preview.

Only flat networks are supported in SUSE Containerized OpenStack Cloud.

  .. note::
     Network configuration examples can be found in :ref:`userscenarios`
