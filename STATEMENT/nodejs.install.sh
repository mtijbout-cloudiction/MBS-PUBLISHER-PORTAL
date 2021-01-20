#!/usr/bin/env bash
# Version: 20201119-1442
#
# Installation of the deploy.sh file is moved to a separate script: installDeploy.sh

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
source ~/.profile

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

# # Install pm2
# echo -e "- Install pm2 version: $PM2VERSION"
# npm install -g pm2@${PM2VERSION} # -g to install package globally

# Install YARN
npm install -g yarn@${YARNVERSION}


# # Install dependency for Puppeteer: chromium browser
# sudo apt update && sudo apt install -y chromium-browser

# # Install Puppeteer
# echo -e "- Install puppeteer version: $PUPPETEERVER"
# npm install puppeteer@${PUPPETEERVER} -g --unsafe-perm=true # -g to install package globally

    echo -e "\nMake PM2 start as service at system boot ..."
    # Copy custom service file pm2-gitlab.service
    cp $DIR/pm2-gitlab.service /etc/systemd/system
    # Enable service
    systemctl daemon-reload
    systemctl enable pm2-gitlab.service


# The End ...
echo -e "\nFinished processing $0\n\n"