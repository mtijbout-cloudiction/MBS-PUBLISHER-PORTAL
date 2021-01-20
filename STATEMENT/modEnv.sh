#!/usr/bin/env bash
# Version: 20201102-1303
#
# Purpose:
# This script is used to update the PATH setting in the /etc/environment file.

# Let's begin ...
echo -e "\n\nStart processing $0"

# Current date and time of script execution
DATETIME=`date +%Y%m%d_%H%M%S`

# Define some base details
ETC_ENV_FILE="/etc/environment"
NVM_VER=$(sudo cat /usr/local/nvm/alias/default)    # Retrieve current NVM version
NVM_BASE=":/usr/local/nvm/versions/node/v"    # What to look for if already something is configured
NVM_PATH="${NVM_BASE}${NVM_VER}/bin"    # Generate NVM path tree

fnMakeBackup() {
    echo -e "- Make backup of $1"
    sudo cp "${1}" "${1}".bak-${DATETIME}
}

fnAddNVMVersion() {
    # Add NVM to /etc/environment
    ETC_ENVi=$(cat ${ETC_ENV_FILE} | grep PATH)    # Read line with PATH value
    ETC_ENVm=${ETC_ENVi::-1}    # Strip last character - double-quote
    ETC_ENVo="${ETC_ENVm}${NVM_PATH}"'"'    # Add path to NVM with version and close with double-quote
    sudo sed -i -e 's,'${ETC_ENVi}','${ETC_ENVo}',' ${ETC_ENV_FILE}    # Replache the old line with new line
}

fnReplaceVNMVersion() {
    OLD_NVM_VER=$(cat /etc/environment | grep -o -P '(?<=nvm/versions/node/v).*(?=/bin)')
    OLDVAL="${NVM_BASE}${OLD_NVM_VER}/bin"
    NEWVAL=${NVM_PATH}
    echo -e "\n- Replace strings:\n  - Old path: ${OLDVAL}\n  - New path: ${NEWVAL}"
    # Replace the old line for the new line
    sudo sed -i 's+'"${OLDVAL}"'+'"${NEWVAL}"'+' ${ETC_ENV_FILE}
}

fnTestAct() {
    echo -e "\nUpdate NVM path in ${ETC_ENV_FILE} if required:"
    grep -Fq "${NVM_BASE}" "${ETC_ENV_FILE}"
    if [ $? -eq 0 ]; then
        echo -e "- A path string for NVM exisits. Checking further ..."
        grep -Fq "${NVM_PATH}" "${ETC_ENV_FILE}"
        if [ $? -eq 0 ]; then
            echo -e "- Path for latest version is already set.\n"
            #exit 1
        else
            echo -e "- Path for another version is already set. Update it ...\n"
            fnMakeBackup ${ETC_ENV_FILE}
            fnReplaceVNMVersion
        fi
        # Set path for NVM
    else # [ $? -eq 0 ]; then
        echo -e "- No path for a NVM version is set, update ..."
        fnMakeBackup ${ETC_ENV_FILE}
        fnAddNVMVersion
    fi
}

# Start the process
fnTestAct

# Show content of file after modification
echo -e "\nDisplay result after running script:\n$(cat ${ETC_ENV_FILE})"

# The End ...
echo -e "\nFinished processing $0\n\n"
