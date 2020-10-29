#!/usr/bin/env bash
# Version: 20201029-1000

# Let's begin ...
echo -e "\n\nStart processing $0"

# Aquire the location of this script and use it as reference point
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Load environment settings:
echo -e "\nLoading environment settings from: "${HOME}"/.ssh/environment"
. "${HOME}"/.ssh/environment

# Load the PATH environment AND location for pm2
# Environment now provided by SSHD 
#. /etc/environment
echo -e "\n- The PATH is configured to:\n  $PATH"

echo -e "\nSet required variables ..."
export VERSIONS_DIR="/var/www/versions"
export CURRENT_LINK="/var/www/current"
export SOURCE_DIR="/tmp/application"
export SOURCE_FILE="/tmp/application.tar.gz"
export CODEDEPLOY_DIR=$SOURCE_DIR/codedeploy

# Process the build number provided via the --version <number> parameter input.
echo -e "\nExtract deployment number from input:"
case "${1}" in
"--version") DEPL_VER="$2" ;;
esac
echo -e "- Deployment number: ${DEPL_VER}"
echo -e "- Updated the versions tracker file ${VERSIONS_DIR}/versions.list"
echo  ${DEPL_VER} >> ${VERSIONS_DIR}/versions.list

echo -e "\nCreate source directory if not exist ..."
[ -d ${SOURCE_DIR} ] || mkdir -p ${SOURCE_DIR}

echo -e "\nCreate destination directory if not exist ..."
[ -d ${VERSIONS_DIR}/${DEPL_VER} ] || mkdir -p ${VERSIONS_DIR}/${DEPL_VER}

echo -e "\nGet target of existing link:"
PREVIOUS_VERSION_DIR=$(realpath $CURRENT_LINK)
echo -e "- Existing active deployment: $PREVIOUS_VERSION_DIR"

echo -e "\nExtract package to source directory ..."
tar -xzf ${SOURCE_FILE} --directory=${SOURCE_DIR}

moveSource() {
    echo -e "\nExecute: MoveSource:"
    source $CODEDEPLOY_DIR/AfterInstall/MoveSource.sh
    if [ $? -eq 0 ]; then
        echo -e "- Application: AfterInstall successfully completed.\n"
    else
        echo -e "- ERROR: Application AfterInstall failed!\n"
        exit 1
    fi
}

applicationStop() {
    echo -e "\nExecute: ApplicationStop:"
    source $CODEDEPLOY_DIR/ApplicationStop/Stop.sh
    if [ $? -eq 0 ]; then
        echo -e "\n- Application: ApplicationStop successfully completed.\n"
    else
        echo -e "- ERROR: Application stop failed!\n"
        exit 1
    fi
}

applicationStart() {
    echo -e "\nExecute: ApplicationStart:"
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
        echo -e "\n- Application: ApplicationStart successfully completed.\n"
    else
        echo -e "- ERROR: Application: ApplicationStart failed!\n"
        exit 1
    fi
    echo -e "\nMake PM2 start as service at system boot ..."
    env PATH=$PATH:/usr/local/nvm/versions/node/v12.18.2/bin /usr/local/nvm/versions/node/v12.18.2/lib/node_modules/pm2/bin/pm2 startup systemd -u gitlab --hp /home/gitlab
}

cleanEnvironment() {
    echo -e "\nCleaning up the deployment environment:"
    echo -e "- Remove installation files and directories."
    echo -e "  - Removing: $SOURCE_DIR"
    rm -fr $SOURCE_DIR
    echo -e "  - Removing: $SOURCE_FILE"
    rm -f $SOURCE_FILE

    echo -e "\n- Remove old application versions from ${VERSIONS_DIR}\n"
    echo -e "  - Build array of version directories..."
    VERSIONS_LIST=( $(cat ${VERSIONS_DIR}/versions.list) )
    echo -e "  - Total list: \n${VERSIONS_LIST[@]}\n"
    echo -e "  - Total number items in array: ${#VERSIONS_LIST[@]}\n"

    # Specify the number of last versions to keep e.g. 3= keep last 3 versions.
    KEEP_VERSIONS=2     # 2= current and 1 previous version
    echo -e "\n  - Versions to keep: ${KEEP_VERSIONS}"
    # Remove the last item, times the specified number to keep.
    for ((i=1;i<=KEEP_VERSIONS;i++)); do
        unset 'VERSIONS_LIST[${#VERSIONS_LIST[@]}-1]'
    done

    echo -e "  - Items in array to work on: \n${VERSIONS_LIST[@]}\n"
    echo -e "  - Total number items in array: ${#VERSIONS_LIST[@]}\n"

    # For the remainder of items in the array do
    echo -e "  - Start removing the directories ..."
    for VER_DIR in "${VERSIONS_LIST[@]}"
    do
        echo -e "  - Removing directory $VER_DIR"
        rm -fr ${VERSIONS_DIR}/${VER_DIR}
    done

    echo -e "\nUpating the versions.list file ..."
    cd ${VERSIONS_DIR}
    ls -d */ | cut -f1 -d'/' > versions.list

    echo -e "\n- Finished removing old version directories."
}

# Process the --cleanup argument.
echo -e "\nCheck if argument --cleanup is provided to cleanup the deployments"
case "${1}" in
    "--cleanup")
        echo -e "- Order for cleanup is given. Start processing ..."
        cleanEnvironment
        ;;
esac


# Order of functions to call
moveSource
applicationStop
applicationStart
# cleanEnvironment

# The End ...
echo -e "\nFinished processing $0\n\n"
