#!/usr/bin/env bash
. /etc/environment

# Set required variables
export VERSIONS_DIR="/var/www/versions"
export CURRENT_LINK="/var/www/current"
export SOURCE_DIR="/tmp/application"
export SOURCE_FILE="/tmp/application.tar.gz"
export CODEDEPLOY_DIR=$SOURCE_DIR/codedeploy

# Extract version number
case "${1}" in
"--version") DEPL_VER="$2" ;;
esac

# Create source directory if not exist
[ -d ${SOURCE_DIR} ] || mkdir -p ${SOURCE_DIR}

# Create destination directory if not exist
[ -d ${VERSIONS_DIR}/${DEPL_VER} ] || mkdir -p ${VERSIONS_DIR}/${DEPL_VER}

# Get target of existing link
PREVIOUS_VERSION_DIR=$(realpath $CURRENT_LINK)

# Extract package to source directory
tar -xzf ${SOURCE_FILE} --directory=${SOURCE_DIR}

moveSource() {
    source $CODEDEPLOY_DIR/AfterInstall/MoveSource.sh
    if [ $? -eq 0 ]; then
        echo -e "- Application: AfterInstall successfully completed.\n"
    else
        echo -e "- ERROR: Application AfterInstall failed!\n"
        exit 1
    fi
}

applicationStop() {
    source $CODEDEPLOY_DIR/ApplicationStop/Stop.sh
    if [ $? -eq 0 ]; then
        echo -e "\nApplication: ApplicationStop successfully completed.\n"
    else
        echo -e "- ERROR: Application stop failed!\n"
        exit 1
    fi
}

applicationStart() {
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
}

cleanTemp() {
    echo -e "\nCleaning up the application environment."
    echo -e " ... Remove installation files and directories."
    rm -fr $SOURCE_DIR
    rm -f $SOURCE_FILE
    echo -e "... Remove old application version\n"
    rm -fr ${PREVIOUS_VERSION_DIR}
}

# Order of functions to call
moveSource
applicationStop
applicationStart
# cleanTemp"