#!/usr/bin/env bash

# Become root
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

# Check if user gitlab exists
exists=$(grep -c "^${GITLAB_USER}:" /etc/passwd)
if [ $exists -ne 0 ]; then
    echo -e "\nThe user ${GITLAB_USER} does not exist.\nERROR: Abort installation. First create user and try again"
else
    echo -e "\nThe user ${GITLAB_USER} exists.\nContinue installation ...\n"
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
cat /etc/sudoers | grep gitlab > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "SUDO permissions for user gitlab already set."
else
    echo -e "Set SUDO permissions for user gitlab."
    # Make backup of existing active sudoers file.
    cp /etc/sudoers /etc/sudoers.bak-${DATETIME}

    # Insert INS_STRING after INS_LOC location
    INS_LOC="# User privilege specification"
    INS_STRING='gitlab    '$(hostname)' = NOPASSWD: /home/gitlab/deploy.sh'
    # Add line after the search string INS_LOC
    sed -i '/'"${INS_LOC}"'/a '"${INS_STRING}" /etc/sudoers
fi

# Some checks:
cat /etc/sudoers
ls -l /home/gitlab/deploy.sh
