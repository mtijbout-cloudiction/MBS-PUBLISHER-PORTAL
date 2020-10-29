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
    - [installDeploy.sh](#installdeploysh)
    - [deploy.sh](#deploysh)
    - [enableSSHEnv.sh](#enablesshenvsh)
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
| [enableSSHEnv.sh](#enablesshenvsh) | Script to configure SSH to use environment files. |
| installDeploy.sh | Script to install / update the deploy.sh script |
| [main.sh](#mainsh) | The installation script that executes the task at hand. |
| [nodejs-install.env](#nodejs-installenv) | Environment file with details required for the installation. |
| [nodejs.install.sh](#nodejsinstallsh) | Installation script to install NodeJS and mp2. |
| [setSSHEnv.sh](#setsshenvsh) | Script used to fill the environment files used by SSH with the latest details |
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


### installDeploy.sh

This script configures the capability for a service account, in this case the account gitlab, to deploy application packages from gitlab.

The script assumes that the account is already created on the system. It will install a script in the homedirectory of the account and secure it with permissions. Next it will edit the sudoers file to limit the sudo capabilities to only this one command with elevated privileges (e.g. sudo) for this account. It can only do 1 command with sudo to get privileges: `/home/gitlab/deploy.sh`. Nothing more.

Result is that only Cloudiction can alter the contents of the deploy.sh script and that the service account cannot start any other commands with elevated privileges.


### deploy.sh

This is the script that enables 4NET to deploy their applications on the specific host in a controlled manner. 4NET has made the integration to their GitLab deployment procedure to call this script.

deploy.sh accepts 2 arguments:  
* --version <gitlab build number> (Mandatory)
* --cleanup (Optional)

`--version` The job number from the gitlab runner is passed to this argument and identified by the `--version` parameter. The script will look for the argument behind --version and processes this as the version number required by the deployment process of the script.

`--cleanup` This parameter is looked for by the script to tell if the environment needs to be cleaned. If set, the function `cleanEnvironment` will be called. It will remove any old versions except for the current and second last version.

### enableSSHEnv.sh

This script configures the SSH server (sshd_conf) to use environment files for non-interactive shells used by  executing a command remotely via ssh. When you login to a terminal with ssh user@host, it is called an interactive shell and for that user the whole profile is loaded. This is not the case with non-interactive shells.

### setSSHEnv.sh

This script fills the environment file(s) used by the SSH server, enabled by the script `enableSSHEnv.sh`.

What it does is:

* It reads the current version of NVM (Mandatory)
* Fills the environment file for the gitlab user as specified in `nodejs-install.env` (Mandatory)
* Fills the environment file in the /etc/skel template folder used by the system to create (future) new users (Optional)
