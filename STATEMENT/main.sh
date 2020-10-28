#!/usr/bin/env bash
# Version: 20201028-1707
#
# This is the main script to controll the installation flow. 
#
# Steps can be commented out to skip steps that are not required. For example 
# on a system that has NodeJS already installed, white testing it does not need 
# installed ove and over again.


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

# Specify the Cloudiction Admin credential details. While executing a password 
# for the private key may be asked.
USER=cloudiction
SSH_ID="~/.ssh/id_cloudiction"
ADMIN="-i ${SSH_ID} ${USER}"

# For each host in the array the below actions are performed.
for i in "${HOSTS[@]}"
do
    echo -e "\nNow connecting to: $i"

    echo -e "- Create the scripts folder ..."
    ssh ${ADMIN}@$i mkdir -p /home/${USER}/scripts

    echo -e "\n- Copy over the files ..."
    # Copy all files over as listed in the array FILES (from env file)
    scp -C -i ${SSH_ID} ${FILES[@]} ${USER}@${i}:~/scripts

    echo -e "\n- Make the script files executable ..."
    ssh ${ADMIN}@$i chmod +x /home/${USER}/scripts/*.sh

    echo -e "\n- See what is in the scripts folder:"
    ssh ${ADMIN}@$i ls -l /home/${USER}/scripts/

    # echo -e "\n- Start the nodejs installation ..."
    # ssh ${ADMIN}@$i sudo /home/cloudiction/scripts/nodejs.install.sh

    echo -e "\n- Install delploy.sh ..."
    ssh ${ADMIN}@$i sudo /home/cloudiction/scripts/installDeploy.sh

    # echo -e "\n- Enable usage of ~/.ssh/environment file ..."
    # ssh ${ADMIN}@$i sudo /home/cloudiction/scripts/enableSSHEnv.sh

    # echo -e "\n- Fill ~/.ssh/environment file ..."
    # ssh ${ADMIN}@$i sudo /home/cloudiction/scripts/setSSHEnv.sh
done
