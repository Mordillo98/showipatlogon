#!/bin/bash

# DECLARE VARIABLES
#

source ./SETTINGS # Loads all the needed variables for this script.

#
# Making sure this script will be ran with admin priviledge.
#                                                       

if [ "$EUID" -ne 0 ]
  then
    printf "\n${CYAN}This script needs to be ran with admin privileges to execute properly.\n"
    
    while true; do
    
      Y_N_Answer="" 
    
      printf "\n${WHITE}Would you like to run it again withe the SUDO command? (Y/n): " Y_N_Answer
      read Y_N_Answer
    
      if [ -z "${Y_N_Answer}" ] ;
        then Y_N_Answer="Y"
      fi
      
      case $Y_N_Answer in
        [Yy]* ) printf "${NC}"; sudo ./remove-showipatlogon.sh; exit;;
	[Nn]* ) printf "\n${CYAN}Bye bye...\n\n"; exit;;
	* ) printf "\n${YELLOW}Please answer Yes or No.\n";;
      esac

    done
fi

# 
# Putting back the original /etc/issue file.
#

cp ${INSTALL_FOLDER}/issue_bck /etc/issue 2> /dev/null 

#
# Removing the Symbolink links of showipatlogon and showip.
#

rm ${SYMBOLIC_LINK_FOLDER}/showipatlogon 2> /dev/null
rm ${SYMBOLIC_LINK_FOLDER}/showip 2> /dev/null

#
# Removing the execution of showipatlogon.boot under getty@service.
#

mkdir -p ${INSTALL_FOLDER} 2>/dev/null

FIND_THIS="/"
TO_REPLACE="\/"
SED_INSTALL_FOLDER=$(echo "${INSTALL_FOLDER//$FIND_THIS/$TO_REPLACE}")

cp  /usr/lib/systemd/system/getty@.service $INSTALL_FOLDER

sed -i "/ExecStartPre=${SED_INSTALL_FOLDER}\/showipatlogon.boot/d" ${INSTALL_FOLDER}/getty@.service

cp ${INSTALL_FOLDER}/getty@.service /usr/lib/systemd/system/getty@.service
rm ${INSTALL_FOLDER}/getty@.service

systemctl daemon-reload

#
# Removing the $INSTALL_FOLDER folder.
#
rm -rf $INSTALL_FOLDER 2>/dev/null

# Final words?

printf "\n"

SILENT=$(echo "$1" | tr '[:upper:]' '[:lower:]')

if [ "$SILENT" != "--silent" ] && [ "$SILENT" != "-s" ] ; then
	printf "${GREEN}+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n"
	printf "${CYAN}The showipatboot uninstallation has now completed successfully.${NC}\n\n"
	printf "${GREEN}+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n${NC}"
fi
