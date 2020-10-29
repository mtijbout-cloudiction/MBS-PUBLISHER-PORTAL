# MBS-PUBLISHER-PORTAL
Thisrepository contains the files required by the installation and configuration of the NodeJS and mp2 environment.



### List of files

| Type / Order of Execution | File Name | Description |
| --- | --- | --- |
| source file | deploy.sh | Deployment script file used by the gitlab runner. |
| source file | nodejs-install.env | Environment file with details required for the installation. |
| source file | nodejs.install.sh | Installation script to install NodeJS and mp2. |
| 01 | vars-MBS-PUBLISHER-PORTAL.env | Environment file with specifics required about the targeted systems. |
| 02 | main.sh | The installation script that executes the task at hand. |




#### nodejs-install.env

This file contains all parameters that are required to install specific versions of NodeJS and pm2.

#### nodejs.install.sh

The installation script that installs NodeJS, pm2 and configures the deployment possibility for the user gitlab used by 4NET.

#### deploy.sh

This script enables 4NET to deploy their applications on the specific host in a controlled manner. This script is installed in the homedirectory of the user `gitlab`. This is a non-privileged user. It can only do 1 command with sudo to get privileges: `/home/gitlab/deploy.sh`. Nothing more. 
