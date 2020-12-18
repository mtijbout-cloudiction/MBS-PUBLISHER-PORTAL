#!/usr/bin/env bash
# Version: 20201218-1444

# Let's begin ...
echo -e "\n\nStart processing $0"

# Define details for what needs to happen
MGTAPPS=( nmon hwinfo )
TIMEZONE="Europe/Amsterdam"

# Functions for a modular approach
fnSetTimezone() {
    echo -e "\n- Set the timezone to ${TIMEZONE}"
    sudo timedatectl set-timezone ${TIMEZONE}
}

fnInstallMgmtTooling() {
    echo -e "\n- Installing some management tooling:"
    echo -e "  - Quietly update the apt repositories ..."
    sudo apt-get -qq update

    for i in "${MGTAPPS[@]}"
    do
        echo -e "\n  - Now Checking: $i"
        if ! which ${i} > /dev/null; then
            echo -e "    - ${i} not found. Installing now ..."
            sudo apt-get -qq install -y ${i}
            if [ $? -eq 0 ]; then
                echo -e "    - ${i} installed sucessfully."
            else
                echo -e "    - ${i} did not install sucessfully."
                return ## Exit function on failure.
            fi
        else
            echo -e "    - ${i} installed. Skipping ..."
        fi
    done
}

# Calling the functions to process
fnSetTimezone
fnInstallMgmtTooling

# The End ...
echo -e "\nFinished processing $0\n\n"
