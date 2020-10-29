# Deploy Mechanism NodeJS pm2 packages

This repository folder contains the scripts used for deploying NodeJS pm2 packages from GitLab Runner managed by 4NET.

To give 4NET access to the virtual machines, a non-privileged account (named `gitlab`) is created and is accessible via SSH keys.

On the virtual machine, the user gitlab is only permitted to run 1 command with elevated privileges: `/home/gitlab/deploy.sh` (exactly as written here. ~/deploy.sh will NOT work).

From the GitLab Runner, 4NET executes SSH commands to copy over new packages and executes the deploy.sh script.

Files relevant to this process:

| **Name** | **Description** |
| --- | ---
| deploy.sh | Script that is called by gitlab runner with sudo. This script is under control of Cloudiction. |
| MoveSource.sh | The script that moves the extracted application package into the right place. This script is maintained by 4NET.  It has some specifics in it to make it work, so it is stored here for future reference. |
| Start.sh | The script that reloads the application configuration with pm2 and starts the new configuration. This script is maintained by 4NET.  It has some specifics in it to make it work, so it is stored here for future reference. |
