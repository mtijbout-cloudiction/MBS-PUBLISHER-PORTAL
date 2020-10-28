#!/usr/bin/env bash

# Let's begin ...
echo -e "\n\nStart processing $0"

# Become root
echo -e "\nBecome root for this exercise ..."
[ `whoami` = root ] || exec su -c $0 root

# Fix tput empty terminal error
if [ -n "$TERM" ] && [ "$TERM" = unknown ] ; then
  TERM=dumb
fi

# Aquire the location of this script and use it as reference point
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load environment settings:
. "${DIR}"/nodejs-install.env

# Current date and time of script execution
DATETIME=`date +%Y%m%d_%H%M%S`

# Must be root to use this tool
if [ "$EUID" -ne 0 ]; then
    echo -e "\nPlease run this script AFTER become root (sudo su).\n"
    exit 1
fi

# Check if user for gitlab deployments exists
echo -e "\nCheck if user ${GITLAB_USER} exists:"
exists=$(grep -c "^${GITLAB_USER}:" /etc/passwd)
if [ $exists -ne 1 ]; then
    echo -e "- The user ${GITLAB_USER} does not exist.\n- ERROR: Abort installation. First create user and try again"
    exit 1
else
    echo -e "- The user ${GITLAB_USER} exists.\n- Continue installation ...\n"
fi

# Create directory for global nvm installation
mkdir -p ${NVM_DIR}

# Install NVM globally available.
curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | NVM_DIR=/usr/local/nvm bash

# Refresh profile to load new variables
#source ~/.profile

# Make nvm globally available for everyone
cat > /etc/profile.d/nvm.sh <<EOF
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF

# Load into profile
source /etc/profile.d/nvm.sh

# Install specified version of node.js
echo -e "Install node.js version ${NJSVERSION}"
nvm install ${NJSVERSION}

# Install pm2
echo -e $PM2VERSION
npm install -g pm2@${PM2VERSION} # -g to install package globally

# Install possibility to deploy application packages
cp "${DIR}"/deploy.sh /home/gitlab/deploy.sh
chmod 700 /home/gitlab/deploy.sh

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

# Some checks:

# echo -e "\nShow the contents of /etc/passwd:\n"
# cat /etc/sudoers
# ls -l /home/gitlab/deploy.sh

# The End ...
echo -e "\nFinished processing $0\n\n"