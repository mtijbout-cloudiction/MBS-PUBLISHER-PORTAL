#!/usr/bin/env bash

if [ $# -eq 0 ]
  then
    echo -e "No arguments supplied.\nPlease provide name of env file to process ..."
    exit 1
fi

# Source the variables
ENV_FILE=$1
. ./"${ENV_FILE}"
echo -e "\nEnvironment file loaded: ${ENV_FILE}"

USER=cloudiction
SSH_ID="~/.ssh/id_cloudiction"
ADMIN="-i ${SSH_ID} ${USER}"

for i in "${HOSTS[@]}"
do
   echo -e "Now connecting to: $i"
   ssh ${ADMIN}@$i mkdir -p /home/${USER}/scripts
   scp -C -i ${SSH_ID} ./deploy.sh ./nodejs-install.env ./nodejs.install.sh ${USER}@${i}:~/scripts
   ssh ${ADMIN}@$i chmod +x /home/${USER}/scripts/*.sh
   ssh ${ADMIN}@$i ls -l /home/${USER}/scripts/
   ssh ${ADMIN}@$i sudo /home/cloudiction/scripts/nodejs.install.sh
done
