#!/bin/bash

########################################################################
#                                                                      #
# ShowIpAtBoot                                                         #
# -+-+-+-+-+-+                                                         #
#                                                                      #
# This software will show the IP addresses of the network adapters     #
# (wired and wireless) available from a systemd boot of ArchLinux      # 
# through the /etc/issue file at login.                                #
#                                                                      #
# You can also see the same information by simply executing the        #
# showip, or showipatboot commands after logging in.                   #
#                                                                      #
########################################################################

#
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
        [Yy]* ) printf "${NC}"; sudo ./install-showipatlogon.sh; exit;;
	[Nn]* ) printf "\n${CYAN}Bye bye...\n\n"; exit;;
	* ) printf "\n${YELLOW}Please answer Yes or No.\n";;
      esac

    done
fi

# 
# Clean Up old Installation
#
# Making sure the /etc/issue has the right permissions, 
# and prevent it to be deleted.
#

touch /etc/issue 2> /dev/null
chmod 771 /etc/issue

# Making sure all the dependencies are installed

# 
# Fedora 32
# 

if ! [ -z "$(uname -r | grep fc32)" ] ; then

  if [ -z "$(rpm -qa | grep net-tools)" ] > /dev/null ; then
     printf "\n${YELLOW}Installing net-tools...${NC}\n"
     dnf install net-tools -y > /dev/null
  fi

  if [ -z "$(rpm -qa | grep moreutils)" ] > /dev/null ; then
     printf "\n${YELLOW}Installing moreutils...${NC}\n"
     dnf install moreutils -y > /dev/null
  fi

fi

#
# Arch
#


if ! [ -z "$(uname -r | grep arch)" ] ; then

  if ! pacman -Qs net-tools > /dev/null ; then
     printf "\n${YELLOW}Installing net-tools...${NC}\n"
     pacman -S net-tools --noconfirm > /dev/null
  fi

  if ! pacman -Qs moreutils > /dev/null ; then
     printf "\n${YELLOW}Installing moreutils...${NC}\n"
     pacman -S moreutils --noconfirm > /dev/null
  fi

fi

#
# Copying all the scripts to the right places
# making sure they have executable permissions.
#

mkdir $INSTALL_FOLDER 2>/dev/null

cp ./create-welcome $INSTALL_FOLDER 2> /dev/null
chmod +x $INSTALL_FOLDER/create-welcome 

cp ./showipatlogon.postboot $INSTALL_FOLDER 2> /dev/null
chmod +x $INSTALL_FOLDER/showipatlogon.postboot

cp ./showipatlogon.boot $INSTALL_FOLDER 2> /dev/null
chmod +x $INSTALL_FOLDER/showipatlogon.boot

cp ./SETTINGS $INSTALL_FOLDER 2> /dev/null
chmod +x $INSTALL_FOLDER/SETTINGS

#
# Backup /etc/issue
#

if ! [ -f "${INSTALL_FOLDER}/issue_bck" ] ; then
   cp /etc/issue ${INSTALL_FOLDER}/issue_bck
fi

#
# Let's show the ip at logon on the next logoff/reboot
#

$INSTALL_FOLDER/showipatlogon.boot 

#
# To make sure we can manually execute the program
#

rm ${SYMBOLIC_LINK_FOLDER}/showipatlogon 2> /dev/null
rm ${SYMBOLIC_LINK_FOLDER}/showip 2> /dev/null
ln -s $INSTALL_FOLDER/showipatlogon.postboot $SYMBOLIC_LINK_FOLDER/showipatlogon
ln -s $INSTALL_FOLDER/showipatlogon.postboot $SYMBOLIC_LINK_FOLDER/showip
chmod +x /usr/local/bin/showipatlogon
chmod +x /usr/local/bin/showip
chmod o=+w $INSTALL_FOLDER/showipatlogon.log 2> /dev/null

#
# Making sure showipatlogon.postboot runs completly before the login prompt.
#

FIND_THIS="/"
TO_REPLACE="\/"
SED_INSTALL_FOLDER=$(echo "${INSTALL_FOLDER//$FIND_THIS/$TO_REPLACE}")

cp  /usr/lib/systemd/system/getty@.service $INSTALL_FOLDER

sed -i "/ExecStartPre=${SED_INSTALL_FOLDER}\/showipatlogon.boot/d" ${INSTALL_FOLDER}/getty@.service

sed -i "/ExecStart=/a ExecStartPre=${SED_INSTALL_FOLDER}\/showipatlogon.boot" $INSTALL_FOLDER/getty@.service

cp ${INSTALL_FOLDER}/getty@.service /usr/lib/systemd/system/getty@.service
rm ${INSTALL_FOLDER}/getty@.service

systemctl daemon-reload

# Final words?

printf "\n"

SILENT=$(echo "$1" | tr '[:upper:]' '[:lower:]')

if [ "$SILENT" != "--silent" ] && [ "$SILENT" != "-s" ] ; then
	printf "${GREEN}+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n"
	printf "${CYAN}The showipatboot installation has now completed successfully,\nand will see the IP(s) at boot at your next reboot/logoff.${NC}\n\n"
	printf "${CYAN}You can also see the IP(s) by using the command showipatlogon, \nor simply by typing showip.\n\n"
	printf "${GREEN}+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n${NC}"
fi
