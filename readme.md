This [Ansible][ansible] playbook is used to build the components required to run
[The Genomics Virtual Laboratory (GVL)][GVL]. The playbook
is heavily reliant on the [Cloudman][cloudman] playbook and is intended for anyone
wanting to deploy a customised version of the GVL on a public or private cloud.

There are several roles contained in this playbook; the roles manage
the build process of different components:

  **GVL-Image**: Installs components required for a GVL image snapshot. Implements only the differences from a base cloudman image.
  **GVL-FS**: Installs components required for a GVL filesystem snapshot. Implements only the differences from a base cloudman filesystem.

The build instructions are identical to cloudman's build instructions, which can be found  [here][building].

These roles are intended to be run on an Ubuntu (14.04) system.

Machine Image
-------------
The easiest method for building the base machine image is to use [Packer][packer].
Once you have it installed, check any variables specified at the top of
`packer.json`, check the formatting of the file with `packer validate packer.json`,
and run it with `packer build packer.json`. The command will provison an instance,
run the Ansible image build role, and create a Machine Image. By default, images will be
created on both AWS and Openstack/NeCTAR. Custom options
can be set by editing `packer.json`, under `extra_arguments` section.

To build an image without Packer, make sure the default values provided in the
`group_vars/all` and `group_vars/image-builder.yml` files suite you. Create
a copy of `inventory/builders.sample` as `inventory/builders`, launch a new
instance and set the instance IP address under `image-builder` host group in the
`builders` file. Also, set `hosts` line in `cloud.yml` to `image-builder` while
commenting out `connection: local` line. Finally, run the role with

    ansible-galaxy install -r requirements_roles.txt -p roles
    ansible-playbook -i inventory/builders cloud.yml --tags "machine-image" --extra-vars vnc_password=<choose a password> --extra-vars cleanup=yes

On average, the build time takes about 30 minutes. *Note that after the playbook
has run to completion, you will no longer be able to ssh into the instance!* If
you still need to ssh, set `--extra-vars cleanup=no` in the above command.
Before creating the image, however, you must rerun the playbook with that flag
set.

### Customizing
A configuration file exposing adjustable options is available under
`group_vars/image-builder.yml`. Besides allowing you to set some
of the image configuration options, this file allows you to easily control which
steps of the image building process run. This can be quite useful if a step fails
and you want to rerun only it or if you're just trying to run a certain steps.
Common variables for all the roles in the playbook are stored in `group_vars/all`.

GVL File System (GVL-FS)
-----------------------------
Launch an instance of the machine image built in the previous step and attach a
new volume to it. Create a (`XFS`) file system on that volume and mount it
(under `/mnt/galaxy`). Note that this can also be done from CloudMan's
Admin page by adding a new-volume-based file system. Change the value
of `psql_galaxyftp_password` in `group_vars/all` and set the launched instance
IP in `inventory/builders` under `galaxyFS-builder` host group and run the
role with

    ansible-playbook -i inventory/builders cloud.yml --tags "galaxyFS"

You may want to customise the list of tools that are installed prior to running the command above.
This can be done by editing shed_tool_list.yaml.gvl. You may also want to update the default container
to which the GVL filesystem archive will be uploaded (in group_vars/galaxyFS-builder.yml)

After the run has completed (typically ~15 minutes), you need to create a snapshot of the file
system. Before doing so, stop any services that might still be using the file
system, unmount the file system and create a snapshot of it from the Cloud's console.

### Customizing
This role requires a number of configuration options for the Galaxy application,
CloudMan application, PostgreSQL the database, as well as the glue linking those.
The configuration options have been aggregated under
`group_vars/galaxyFS-builder.yml` and represent reasonable defaults.
Keep in mind that changing the options that influence how the system is deployed
and/or managed may also require changes in CloudMan. Common variables for all the
roles in the playbook are stored in `group_vars/all`.


[ansible]: http://www.ansible.com/
[GVL]: http://genome.edu.au/
[cloudman]: http://usecloudman.org/
[goc]: https://wiki.galaxyproject.org/Cloud
[gp]: http://galaxyproject.org/
[building]: https://wiki.galaxyproject.org/CloudMan/Building
[production]: https://wiki.galaxyproject.org/Admin/Config/Performance/ProductionServer
[packer]: https://packer.io/