# MBS-PUBLISHER-PORTAL
This repository contains the files required by the installation and configuration of the NodeJS and mp2 environment.

## Table of contents
- [MBS-PUBLISHER-PORTAL](#mbs-publisher-portal)
  - [Table of contents](#table-of-contents)
  - [Installation procedure](#installation-procedure)
  - [Files in this repostory](#files-in-this-repostory)
    - [vars-\<SERVICE-NAME-DTAP(-VM-xx)\>.env](#vars-service-name-dtap-vm-xxenv)
    - [main.sh](#mainsh)
    - [nodejs-install.env](#nodejs-installenv)
    - [nodejs.install.sh](#nodejsinstallsh)
    - [deploy.sh](#deploysh)
    - [setSSHEnv.sh](#setsshenvsh)

## Installation procedure

To install a system that is ready to receive the application packages deployed by 4NET using gitlab the following steps need to be taken:

1. Install an Ubuntu virtual machine
2. On the SSHMGR server using the sshmgr.sh tool:
   1. Create a user gitlab on the virtual machine
   2. Make certificates for the user gitlab
   3. Install the authorized_keys file on the virtual machine
   4. Enable the certificate based access on the virtual machine
3. Install the application platform on the virtual machine using the scripts in this repository


## Files in this repostory

| File Name | Description |
| --- | --- |
| README.md | This documentation file. |
| deploy.sh | Deployment script file used by the gitlab runner. |
| enableSSHEnv.sh | Script to configure SSH to use environment files. |
| installDeploy.sh | Script to install / update the deploy.sh script |
| main.sh | The installation script that executes the task at hand. |
| nodejs-install.env | Environment file with details required for the installation. |
| nodejs.install.sh | Installation script to install NodeJS and mp2. |
| setSSHEnv.sh | Script used to fill the environment files used by SSH with the latest details |
| vars-\<SERVICE-NAME-DTAP(-VM-xx)\>.env | Environment file with specifics required about the targeted systems. |


### vars-\<SERVICE-NAME-DTAP(-VM-xx)\>.env

This environment file holds all details required for knowing what hosts are targeted for installation and a list of files that need to be transferred to thes hosts. These details are requird for the script `main.sh`.

These environment files can be used for a whole Service or for an indivitual machine, depending on the need and if an Application Resource Group already exists and in use.

Naming of files:

* `vars-MBS-STATEMENT-TEST-VM-01.env` > Details specific for the machine `MBS-STATEMENT-TEST-VM-01`
* vars-MBS-STATEMENT.env > Contains information for TEST, ACC, PROD and it's machines.


### main.sh

This is the script that trigges the installation / configuraiton process. It has all steps in the required order. Steps can be skipped by commenting these steps out.

The current order of steps:

1. Creating a scripts directory to store all scripts
2. Copy the specified files over to the scripts directory
3. Make the scripts exacutable
4. List what is in the scripts directory
4. Start the NodeJS installation
6. Install the deployment mechanism for gitlab
7. Enable usage of the SSHD environment file
8. Fill the SSHD environment file


### nodejs-install.env

This file contains all parameters that are required to install specific versions of NodeJS and modules.


### nodejs.install.sh

The installation script that installs NodeJS and pm2 using the specific versions specified in `nodejs-install.env`.


### deploy.sh

This script enables 4NET to deploy their applications on the specific host in a controlled manner. This script is installed in the homedirectory of the user `gitlab`. This is a non-privileged user. It can only do 1 command with sudo to get privileges: `/home/gitlab/deploy.sh`. Nothing more. 4NET has made the integration to their GitLab deployment procedure to call this script.

deploy.sh accepts 2 arguments:  
* --version <gitlab build number> (Mandatory)
* --cleanup (Optional)

`--version` The job number from the gitlab runner is passed to this argument and identified by the `--version` parameter. The script will look for the argument behind --version and processes this as the version number required by the deployment process of the script.

`--cleanup` This parameter is looked for by the script to tell if the environment needs to be cleaned. If set, the function `cleanEnvironment` will be called. It will remove any old versions except for the current and second last version.


### setSSHEnv.sh

