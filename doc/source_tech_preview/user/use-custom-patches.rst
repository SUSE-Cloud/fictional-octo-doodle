.. _custompatches:

===================
Use custom patches
===================


To apply upstream patches in your environment, set your patch numbers under the
`dev_patcher_user_patches` key on `${WORKDIR}/env/extravars`:

.. code-block:: yaml

  dev_patcher_user_patches:
    # test patch for keystone
    - 12345
    # test patch for cinder
    - 12345


These patches will only be carried in your environment. If you want to change
the product (for developer mode or not), please submit a pull request to the
`socok8s GitHub repository <https://github.com/SUSE-Cloud/socok8s>`_.

.. note::

    This list of patches provided via extravars will be appended to the default
    patches list available on the dev-patcher role vars.
