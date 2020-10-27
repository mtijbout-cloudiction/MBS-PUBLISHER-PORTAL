#!/usr/bin/env bash

# Let's begin ...
echo -e "\n\nStart processing $0"

# Load the PATH environment AND location for pm2
# Environment now provided by SSHD 
#. /etc/environment

echo -e "\nSet required variables ..."
export VERSIONS_DIR="/var/www/versions"
export CURRENT_LINK="/var/www/current"
export SOURCE_DIR="/tmp/application"
export SOURCE_FILE="/tmp/application.tar.gz"
export CODEDEPLOY_DIR=$SOURCE_DIR/codedeploy

echo -e "\nExtract version number from input ..."
case "${1}" in
"--version") DEPL_VER="$2" ;;
esac

echo -e "\nCreate source directory if not exist ..."
[ -d ${SOURCE_DIR} ] || mkdir -p ${SOURCE_DIR}

echo -e "\nCreate destination directory if not exist ..."
[ -d ${VERSIONS_DIR}/${DEPL_VER} ] || mkdir -p ${VERSIONS_DIR}/${DEPL_VER}

echo -e "\nGet target of existing link:"
PREVIOUS_VERSION_DIR=$(realpath $CURRENT_LINK)

echo -e "\nExtract package to source directory ..."
tar -xzf ${SOURCE_FILE} --directory=${SOURCE_DIR}

moveSource() {
    echo -e "\n Execute: MoveSource:"
    source $CODEDEPLOY_DIR/AfterInstall/MoveSource.sh
    if [ $? -eq 0 ]; then
        echo -e "- Application: AfterInstall successfully completed.\n"
    else
        echo -e "- ERROR: Application AfterInstall failed!\n"
        exit 1
    fi
}

applicationStop() {
    echo -e "\n Execute: ApplicationStop:"
    source $CODEDEPLOY_DIR/ApplicationStop/Stop.sh
    if [ $? -eq 0 ]; then
        echo -e "\nApplication: ApplicationStop successfully completed.\n"
    else
        echo -e "- ERROR: Application stop failed!\n"
        exit 1
    fi
}

applicationStart() {
    echo -e "\n Execute: ApplicationStart:"
    # Create the symbolic link to the new version.
    echo -e "\nCreate symbolic link from new DEPL_VER to current."
    ln -sfn ${VERSIONS_DIR}/${DEPL_VER} ${CURRENT_LINK}
    if [ $? -eq 0 ]; then
        echo -e "- Link successfully created.\n"
    else
        echo -e "- ERROR: Link creation failed!\n"
        exit 1
    fi
    # Change ownership to gitlab user
    chown gitlab:gitlab -R ${VERSIONS_DIR}/${DEPL_VER}
    # Call start script from application codebase
    source $CODEDEPLOY_DIR/ApplicationStart/Start.sh
    if [ $? -eq 0 ]; then
        echo -e "\nApplication: ApplicationStart successfully completed.\n"
    else
        echo -e "- ERROR: Application: ApplicationStart failed!\n"
        exit 1
    fi
    echo -e "\nMake PM2 start as service at system boot ..."
    env PATH=$PATH:/usr/local/nvm/versions/node/v12.18.2/bin /usr/local/nvm/versions/node/v12.18.2/lib/node_modules/pm2/bin/pm2 startup systemd -u gitlab --hp /home/gitlab
}

cleanTemp() {
    echo -e "\nCleaning up the application environment:"
    echo -e "- Remove installation files and directories."
    rm -fr $SOURCE_DIR
    rm -f $SOURCE_FILE
    echo -e "- Remove old application version\n"
    rm -fr ${PREVIOUS_VERSION_DIR}
}

# Order of functions to call
moveSource
applicationStop
applicationStart
# cleanTemp"

# The End ...
echo -e "\nFinished processing $0\n\n"
