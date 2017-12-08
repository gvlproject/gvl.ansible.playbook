This [Ansible][ansible] playbook is used to build the components required to run
[The Genomics Virtual Laboratory (GVL)][GVL]. If you do not plan to make any
customisations of the GVL build, and you are using an OpenStack based cloud,
you do not need to build the image yourself and can download a publicly available
image instead. Otherwise, see the "Build your Own Image" section for instructions
on creating a customised build.


Downloading a pre-built image
-----------------------------
GVL 4.2.0 Beta 1 - [Download](https://swift.rc.nectar.org.au:8888/v1/AUTH_377/gvl_resources/images/GVL_4.2.0_beta1.qcow2)

GVL 4.1.0 - [Download](https://swift.rc.nectar.org.au:8888/v1/AUTH_377/gvl_resources/images/GVL_4.1.0.qcow2)

GVL 4.0.0 - [Download](https://swift.rc.nectar.org.au:8888/v1/AUTH_377/gvl_resources/images/GVL_4.0.0.qcow2)

See the "Launching" section below for information on how to make your image launchable
on your private cloud. 


Building your own image
-----------------------
The playbook is heavily reliant on the [Galaxy CloudMan playbook][cloudman] and
is intended for anyone wanting to deploy a customised version of the GVL on a
public or private cloud. The overall process for building the GVL follows very closely
the one for building *Galaxy on the Cloud* and hence it is recommended to first
read [this page][building] that describes the high-level concepts of the build
process - just use this playbook instead of the one mentioned in that document.

There are several roles contained in this playbook; the roles manage
the build process of different components:

  **GVL-Image**: Installs components required for a GVL image snapshot. Implements
  only the differences from a base CloudMan image.

  **GVL-FS**: Installs components required for a GVL filesystem snapshot.
  Implements only the differences from a base CloudMan filesystem.

These roles are intended to be run on an Ubuntu (16.04) system.

Installing
----------
To get going, it is necessary to clone this repository and then pull in all
the dependent roles:
```
git clone https://github.com/gvlproject/gvl.ansible.playbook.git
ansible-galaxy install -r requirements.yml -p roles
```

If targeting AWS instances and want to have Elastic Network Adapter (ENA)
enabled, you will also need to install `boto` (v2) and `awscli` Python packages
as well as export the following environment vars with their appropriate values:
`EC2_REGION`, `AWS_ACCESS_KEY`, `AWS_SECRET_KEY`. If you have multiple profiles
defined for your `aws` command (i.e., in `~/aws/credentials`) and you don't want
to use the default one, also do `export AWS_PROFILE=<profile name>`. The target
instance will need to have an elastic IP associated with it and you will also
need to set the path to your Python interpreter in the inventory file under the
localhost host definition.

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

    ansible-playbook -i inventory/builders playbook.yml --tags "gvl-image" --extra-vars vnc_password=<choose a password> --extra-vars psql_galaxyftp_password=<choose a password> --extra-vars cleanup=yes [--extra-vars cm_aws_instance_id=<aws inst id>]

On average, the build time takes about 1 hour. *Note that after the playbook
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

Launching
----------
Once the Machine Image has been built (or downloaded from our public images) and made
available on your private cloud, the next step is to configure the
[GVL launcher](https://beta.launch.usegalaxy.org) so that it can launch the built image.
You cannot directly launch the image without the Launcher because the launcher passes
in some "user data" to contextualize the image, and manually performing this process
is error-prone, inconvenient and therefore not recommended. To get your cloud/image
added to the launcher, simply mail us at help@genome.edu.au and we'll help you with
the process.

Alternatively, you can also setup your own private
[launch](https://github.com/galaxyproject/cloudlaunch) server. 
  

[ansible]: http://www.ansible.com/
[GVL]: http://genome.edu.au/
[cloudman]: https://github.com/galaxyproject/galaxy-cloudman-playbook/
[goc]: https://wiki.galaxyproject.org/Cloud
[gp]: http://galaxyproject.org/
[building]: https://wiki.galaxyproject.org/CloudMan/Building
[production]: https://wiki.galaxyproject.org/Admin/Config/Performance/ProductionServer
[packer]: https://packer.io/
[nectar]: https://nectar.org.au/research-cloud/
