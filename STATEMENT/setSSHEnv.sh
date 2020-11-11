#!/usr/bin/env bash

# Let's begin ...
echo -e "\n\nStart processing $0"

# Aquire the location of this script and use it as reference point
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load environment settings:
. "${DIR}"/nodejs-install.env

fnReadNVMVersion() {
    echo -e "\nRead the current active installed NVM version:"
    NVM_VER=$(sudo cat /usr/local/nvm/alias/default)
    echo -e "- NVM version: $NVM_VER"
}

fnEnvGitlabUser() {
    echo -e "\nSet environment for user: ${GITLAB_USER}"
    SSH_LOC="/home/${GITLAB_USER}/.ssh"

    echo -e "- Create ${SSH_LOC} directory if not exist ..."
    [ -d ${SSH_LOC} ] || mkdir -p ${SSH_LOC}

    echo -e "- Fill ${SSH_LOC}/environment file ..."
cat <<EOF > "${SSH_LOC}/environment"
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/local/nvm/versions/node/v${NVM_VER}/bin
EOF
}

fnEnvFutureUsers() {
    echo -e "\nSet environment for all future users:"
    SKEL_LOC="/etc/skel/.ssh"

    echo -e "- Create ${SKEL_LOC} directory if not exist ..."
    [ -d ${SKEL_LOC} ] || mkdir -p ${SKEL_LOC}

    echo -e "- Fill ${SKEL_LOC}/environment file ..."
cat <<EOF > "${SKEL_LOC}/environment"
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/usr/local/nvm/versions/node/v${NVM_VER}/bin
EOF
}

fnReadNVMVersion    # Mandatory
fnEnvGitlabUser     # Mandatory
fnEnvFutureUsers    # Optional

# The End ...
echo -e "\nFinished processing $0\n\n"
