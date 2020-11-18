#!/usr/bin/env bash
# Version: 20201112-1210

# Let's begin ...
echo -e "\n\nStart processing $0"

TIMEZONE="Europe/Amsterdam"
echo -e "\n- Set the timezone to ${TIMEZONE}"
sudo timedatectl set-timezone ${TIMEZONE}

# The End ...
echo -e "\nFinished processing $0\n\n"
