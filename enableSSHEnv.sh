#!/usr/bin/env bash

# Let's begin ...
echo -e "\n\nStart processing $0"

# Current date and time of script execution
DATETIME=`date +%Y%m%d_%H%M%S`

# Aquire the location of this script and use it as reference point
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load environment settings:
. "${DIR}"/nodejs-install.env

# Set the stage for the performance
SSHD_CONF=/etc/ssh/sshd_config
DES_STR="PermitUserEnvironment yes"
CUR_STR="#PermitUserEnvironment no"


fnBackup() {
    echo -e "\nCreate backup of Backup ${SSHD_CONF}"
    sudo cp ${SSHD_CONF} ${SSHD_CONF}.bak-${DATETIME} || \
        echo -e "- ERROR: Backup of ${SSHD_CONF} failed!"  $$ \
        exit 1
}

fnRestartSSH() {
    echo -e "\nRestart SSH service"
    sudo systemctl restart ssh
    if [ $? -eq 0 ]; then
        echo -e "- Restart SSH service is succesfull."
    else
        echo -e "- ERROR: Restart SSH service failed."
    fi
}

fnEnablePermitUserEnvironment() {
    echo -e "\nEnable usage of ~/.ssh/environment file"
    if grep -Fxq "${DES_STR}" ${SSHD_CONF}
    then
        echo -e "- ${SSHD_CONF} PermitUserEnvironment already enabled."
    else
        # Create backup first
        fnBackup

        echo -e "- Set PermitUserEnvironment to yes"
        # Add line after the search string INS_LOC
        sudo sed -i '/'"${CUR_STR}"'/a '"${DES_STR}" ${SSHD_CONF}

        # Restart SSH service
        fnRestartSSH
    fi
}

fnEnablePermitUserEnvironment

# The End ...
echo -e "\nFinished processing $0\n\n"
