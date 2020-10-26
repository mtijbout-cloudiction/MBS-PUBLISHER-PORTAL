#!/usr/bin/env bash

NVM_VER=$(sudo cat /usr/local/nvm/alias/default)

# echo $NVM_VER
cat <<EOF >> /etc/environment
export PATH="\$PATH:/usr/local/nvm/versions/node/v${NVM_VER}/bin"
EOF
