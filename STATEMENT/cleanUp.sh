#!/usr/bin/env bash

## BEGIN CHECK SCRIPT RUNNING UNDER SUDO
[ "$EUID" -eq 0 ] || echo -e "\nYou must be root to run this script! \nuse 'sudo !!' \n" && exit 1

# Set some parameters
export VERSIONS_DIR="/var/www/versions"
export CURRENT_LINK="/var/www/current"
export SOURCE_DIR="/tmp/application"
export SOURCE_FILE="/tmp/application.tar.gz"

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

cleanEnvironment