# MBS-PUBLISHER-PORTAL
Thisrepository contains the files required by the installation and configuration of the NodeJS and mp2 environment.



## List of files

| Type / Order | File Name | Description |
| :---: | --- | --- |
| source file | deploy.sh | Deployment script file used by the gitlab runner. |
| source file | nodejs-install.env | Environment file with details required for the installation. |
| source file | nodejs.install.sh | Installation script to install NodeJS and mp2. |
| 01 | vars-MBS-PUBLISHER-PORTAL.env | Environment file with specifics required about the targeted systems. |
| 02 | main.sh | The installation script that executes the task at hand. |


### vars-\<Service-Name\>.env

This environment file holds all details required to know what hosts are targeted for installation and a list of files that need to be transferred to thes hosts. These details are requird for the script `main.sh`.

### main.sh

This is the script that trigges the installation / configuraiton process. It has all steps in the required order. Steps can be skipped by commenting these steps out.

### nodejs-install.env

This file contains all parameters that are required to install specific versions of NodeJS and pm2.

### nodejs.install.sh

The installation script that installs NodeJS, pm2 and configures the deployment possibility for the user gitlab used by 4NET.

### deploy.sh

This script enables 4NET to deploy their applications on the specific host in a controlled manner. This script is installed in the homedirectory of the user `gitlab`. This is a non-privileged user. It can only do 1 command with sudo to get privileges: `/home/gitlab/deploy.sh`. Nothing more. 4NET has made the integration to their GitLab deployment procedure to call this script.

deploy.sh accepts 2 arguments:  
* --version <gitlab build number> (Mandatory)
* --cleanup (Optional)

`--version` The job number from the gitlab runner is passed to this argument and identified by the `--version` parameter. The script will look for the argument behind --version and processes this as the version number required by the deployment process of the script.

`--cleanup` This parameter is looked for by the script to tell if the environment needs to be cleaned. If set, the function `cleanEnvironment` will be called. It will remove any old versions except for the current and second last version.

### 