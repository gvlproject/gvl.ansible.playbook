This [Ansible][ansible] playbook is used to build the components required to run
[The Genomics Virtual Laboratory (GVL)][GVL]. The playbook
is heavily reliant on the [Galaxy CloudMan playbook][cloudman] and is intended
for anyone wanting to deploy a customised version of the GVL on a public or
private cloud. The overall process for building the GVL follows very closely
the one for building *Galaxy on the Cloud* and hence it is recommended to first
read [this page][building] that describes the high-level concepts of the build
process - just use this playbook instead of the one mentioned in that document.

There are several roles contained in this playbook; the roles manage
the build process of different components:

  **GVL-Image**: Installs components required for a GVL image snapshot. Implements
  only the differences from a base CloudMan image.

  **GVL-FS**: Installs components required for a GVL filesystem snapshot.
  Implements only the differences from a base CloudMan filesystem.

These roles are intended to be run on an Ubuntu (14.04) system.

Installing
----------
To get going, it is necessary to clone this repository and then pull in all
the dependent roles:
```
git clone https://github.com/gvlproject/gvl.ansible.playbook.git
ansible-galaxy install -r requirements.yml -p roles
```

Machine Image
-------------
The easiest method for building the base machine image is to use [Packer][packer].
Once you have it installed, check any variables specified at the top of
`packer.json`, check the formatting of the file with `packer validate packer.json`,
and run it with `packer build packer.json`. The command will provision an instance,
run the Ansible image build role, and create a Machine Image. By default, images will be
created on both AWS and the [NeCTAR cloud][nectar] (OpenStack-based). Custom options
can be set by editing `packer.json`, under the `extra_arguments` section.

Alternatively, to build an image without Packer, make sure the default values
provided in the `gvl.ansible.image` role and `gvl.ansible.filesystem` role suite
you. Create a copy of `inventory/builders.sample` as `inventory/builders`, launch
a new instance and set the instance IP address under `gvl-image-hosts` host
group in the `builders` file.

    ansible-playbook -i inventory/builders playbook.yml --tags "gvl-image" --extra-vars vnc_password=<choose a password> --extra-vars psql_galaxyftp_password=<choose a password> --extra-vars cleanup=yes

On average, the build time takes about 3 hours. *Note that after the playbook
has run to completion, you will no longer be able to ssh into the instance!* If
you still need to ssh, set `--extra-vars cleanup=no` in the above command.
If you run with that flag, before creating the image, you must rerun the
playbook with that flag set.

### Customizing
A configuration file exposing adjustable options is available under
`group_vars/image-builder.yml`. Besides allowing you to set some
of the image configuration options, this file allows you to easily control which
steps of the image building process run. This can be quite useful if a step fails
and you want to rerun only it or if you're just trying to run a certain steps.

GVL File System (GVL-FS)
-----------------------------
Launch an instance of the machine image built in the previous step and when
CloudMan comes up, choose the *Cluster only* with *transient storage* option
(under *Additional startup options*). Insert the instance IP address in
`inventory/builders` file under `galaxyFS-builder` host group and change the value
of `psql_galaxyftp_password` in `group_vars/all`; run the role with

    ansible-playbook -i inventory/builders playbook.yml --tags "gvl-fs" --extra-vars psql_galaxyftp_password=<choose a password>

Running above command will automatically install a number of Galaxy tools. The list of
tools that can be installed can be changed by editing `shed_tool_list.yaml.gvl`.
You may also want to update the default container
to which the GVL filesystem archive will be uploaded.

### Customizing
This playbook requires a number of configuration options for the Galaxy application,
CloudMan application, PostgreSQL the database, as well as the glue linking those.
The configuration options have been aggregated under
`defaults/main.yml` in each role, and represent reasonable defaults.
Keep in mind that changing the options that influence how the system is deployed
and/or managed may also require changes in CloudMan.


[ansible]: http://www.ansible.com/
[GVL]: http://genome.edu.au/
[cloudman]: https://github.com/galaxyproject/galaxy-cloudman-playbook/
[goc]: https://wiki.galaxyproject.org/Cloud
[gp]: http://galaxyproject.org/
[building]: https://wiki.galaxyproject.org/CloudMan/Building
[production]: https://wiki.galaxyproject.org/Admin/Config/Performance/ProductionServer
[packer]: https://packer.io/
[nectar]: https://nectar.org.au/research-cloud/
