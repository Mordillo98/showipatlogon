#!/bin/bash

source /opt/showipatlogon/SETTINGS

# This below will make sure this is ran as sudo

if [ "$EUID" -ne 0 ]
  then 
    printf "\n"
    printf "Please run as root/sudo user.\n"
    printf "\n"
    exit
fi

## 
## MAIN
##

${INSTALL_FOLDER}/create-welcome > /etc/issue
