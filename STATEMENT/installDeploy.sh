#!/usr/bin/env bash
# Version: 20201028-1707

# Let's begin ...
echo -e "\n\nStart processing $0"

# Current date and time of script execution
DATETIME=`date +%Y%m%d_%H%M%S`

# Aquire the location of this script and use it as reference point
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load environment settings:
. "${DIR}"/nodejs-install.env

echo -e "\nBackup existing script:"

echo -e "- Create backup directory if not exist ..."
BCK_DIR="/home/${GITLAB_USER}/backups"
[ -d ${BCK_DIR} ] || mkdir -p ${BCK_DIR}
chmod 700 ${BCK_DIR}

echo -e "- Backup existing delpoy.sh"
cp /home/${GITLAB_USER}/deploy.sh ${BCK_DIR}/deploy.sh.bak-${DATETIME}

echo -e "- Install possibility to deploy application packages"
cp "${DIR}"/deploy.sh /home/${GITLAB_USER}/deploy.sh
chmod 700 /home/${GITLAB_USER}/deploy.sh

# Enable SUDO for this command
echo -e "\nSet sudo permissions for user ${GITLAB_USER}"
cat /etc/sudoers | grep ${GITLAB_USER} > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "- sudo permissions for user ${GITLAB_USER} already set."
else
    echo -e "- Set SUDO permissions for user gitlab."
    echo -e "- Make backup of existing active sudoers file ..."
    cp /etc/sudoers /etc/sudoers.bak-${DATETIME}

    echo -e "- Make modifications to sudoers file ..."
    # Insert INS_STRING after INS_LOC location
    INS_LOC="# User privilege specification"
    INS_STRING=${GITLAB_USER}'    '$(hostname)' = NOPASSWD: /home/'${GITLAB_USER}'/deploy.sh'
    # Add line after the search string INS_LOC
    sed -i '/'"${INS_LOC}"'/a '"${INS_STRING}" /etc/sudoers
fi
