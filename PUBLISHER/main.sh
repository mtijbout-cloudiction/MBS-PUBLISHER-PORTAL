#!/usr/bin/env bash

# Check if an environment file is supplied on the command line.
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
    echo -e "\nNow connecting to: $i"

    echo -e "- Create the scripts folder ..."
    ssh ${ADMIN}@$i mkdir -p /home/${USER}/scripts

    echo -e "- Copy over the files ..."
    # Copy all files over as listed in the array FILES (from env file)
    scp -C -i ${SSH_ID} ${FILES[@]} ${USER}@${i}:~/scripts

    echo -e "\n- Make the script files executable ..."
    ssh ${ADMIN}@$i chmod +x /home/${USER}/scripts/*.sh

    echo -e "- See what is in the scripts folder:"
    ssh ${ADMIN}@$i ls -l /home/${USER}/scripts/

    # echo -e "\n- Start the nodejs installation ..."
    # ssh ${ADMIN}@$i sudo /home/cloudiction/scripts/nodejs.install.sh

    # echo -e "- Enable usage of ~/.ssh/environment file ..."
    # ssh ${ADMIN}@$i sudo /home/cloudiction/scripts/enableSSHEnv.sh

    echo -e "- Fill ~/.ssh/environment file ..."
    ssh ${ADMIN}@$i sudo /home/cloudiction/scripts/setSSHEnv.sh
done
