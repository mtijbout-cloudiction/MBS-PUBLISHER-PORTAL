#!/usr/bin/env bash
# Version: 20201102-1303
#
# Purpose:
# This script is used to update the PATH setting in the /etc/environment file.

# General settings & variables:
ETC_ENV_FILE="/etc/environment"

# Current date and time of script execution
DATETIME=`date +%Y%m%d_%H%M%S`

# Backup /etc/environment
cp /etc/environment /etc/environment.bak-${DATETIME}

# Add NVM to /etc/environment
ETC_ENVi=$(cat ${ETC_ENV_FILE} | grep PATH)    # Read line with PATH value
ETC_ENVm=${ETC_ENVi::-1}    # Strip last character - double-quote
NVM_VER=$(sudo cat /usr/local/nvm/alias/default)    # Retrieve current NVM version
ETC_ENVo="${ETC_ENVm}:/usr/local/nvm/versions/node/v${NVM_VER}/bin"'"'    # Add path to NVM with version
sed -i -e 's,'${ETC_ENVi}','${ETC_ENVo}',' ${ETC_ENV_FILE}    # Replache the old line with new line
# sed -i 's/'"${ETC_ENVi}"'/'"${ETC_ENVo}"'/' ${ETC_ENV_FILE}    # Replache the old line with new line
cat ${ETC_ENV_FILE}    # Show content of file after modification
