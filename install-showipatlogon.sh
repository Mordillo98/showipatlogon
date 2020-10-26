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

#
# Making sure all the dependencies are installed
#

if ! [ -z "$(find /usr/bin -name 'zypper')" ] ; then

  if ! [ -z "$(rpm -q lsb-release | grep "is not installed")" ] ; then
    printf "\n${YELLOW}Installing lsb-release...${NC}\n"
    zypper -nq install lsb-release > /dev/null
  fi

fi

if ! [ -z "$(find /usr/bin -name 'pacman')" ] ; then

  if ! pacman -Qs lsb-release > /dev/null ; then
     printf "\n${YELLOW}Installing lsb-release...${NC}\n"
     pacman -S lsb-release --noconfirm > /dev/null
  fi

fi

if ! [ -z "$(uname -v | grep Debian)" ] ; then
   apt-get install lsb-release -y > /dev/null 
fi

#
# OpenSuse TumbleWeed
#

if ! [ -z "$(lsb_release -d | grep -i "Tumbleweed")" ] ; then

	if ! [ -z "$(rpm -q net-tools-deprecated | grep "is not installed")" ] ; then
           printf "\n${YELLOW}Installing net-tools-deprecated...${NC}\n"
	   zypper -nq install net-tools-deprecated > /dev/null
	fi	

	if ! [ -z "$(rpm -q moreutils | grep "is not installed")" ] ; then
           printf "\n${YELLOW}Installing moreutils...${NC}\n" 
	   zypper -nq install moreutils > /dev/null
	fi

fi

#
# OpenSuse Leap 15.2
#

if ! [ -z "$(lsb_release -d | grep "Leap 15.2")" ] ; then

	if ! [ -z "$(rpm -q net-tools-deprecated | grep "is not installed")" ] ; then
           printf "\n${YELLOW}Installing net-tools-deprecated...${NC}\n"
	   zypper -nq install net-tools-deprecated > /dev/null
	fi	

	if ! [ -z "$(rpm -q moreutils | grep "is not installed")" ] ; then
           printf "\n${YELLOW}Installing moreutils...${NC}\n" 
	   zypper -nq install moreutils > /dev/null
	fi

fi

#
# Debian 10
#

if ! [ -z "$(lsb_release -d | grep "Debian GNU/Linux 10")" ] ; then

  dpkg -s net-tools &> /dev/null

  if ! [ $? -eq 0 ] ; then
     printf "\n${YELLOW}Installing net-tools...${NC}\n"
     apt-get install net-tools -y > /dev/null 
  fi

  dpkg -s moreutils &> /dev/null

  if ! [ $? -eq 0 ] ; then
     printf "\n${YELLOW}Installing moreutils...${NC}\n"
     apt-get install moreutils -y > /dev/null
  fi

fi

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

if ! [ -z "$(lsb_release -d | grep "Arch Linux")" ] ; then

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
# Ubuntu 20.4.1 LTS 
#

if ! [ -z "$(lsb_release -d | grep 20.04.1)" ] ; then

  dpkg -s net-tools &> /dev/null

  if ! [ $? -eq 0 ] ; then
     printf "\n${YELLOW}Installing net-tools...${NC}\n"
     apt-get install net-tools -y > /dev/null 
  fi

  dpkg -s moreutils &> /dev/null

  if ! [ $? -eq 0 ] ; then
     printf "\n${YELLOW}Installing moreutils...${NC}\n"
     apt-get install moreutils -y > /dev/null
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

if ! [ -z "$(lsb_release -d | grep "Debian GNU/Linux 10")" ] ; then

  rm ${SYMBOLIC_LINK_FOLDER}/ifconfig 2> /dev/null
  ln -s /usr/sbin/ifconfig $SYMBOLIC_LINK_FOLDER/ifconfig
  chmod +x $SYMBOLIC_LINK_FOLDER/ifconfig

fi

rm ${SYMBOLIC_LINK_FOLDER}/showipatlogon 2> /dev/null
rm ${SYMBOLIC_LINK_FOLDER}/showip 2> /dev/null
ln -s $INSTALL_FOLDER/showipatlogon.postboot $SYMBOLIC_LINK_FOLDER/showipatlogon
ln -s $INSTALL_FOLDER/showipatlogon.postboot $SYMBOLIC_LINK_FOLDER/showip
chmod +x $SYMBOLIC_LINK_FOLDER/showipatlogon
chmod +x $SYMBOLIC_LINK_FOLDER/showip
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

systemctl daemon-reload 2> /dev/null

# Final words?

printf "\n"

SILENT=$(echo "$1" | tr '[:upper:]' '[:lower:]')

if [ "$SILENT" != "--silent" ] && [ "$SILENT" != "-s" ] ; then
	printf "${GREEN}+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n"
	printf "${CYAN}The showipatboot installation has now completed successfully,\nand will see the IP(s) at boot at your next reboot/logoff.${NC}\n\n"
	printf "${CYAN}You can also see the IP(s) by using the command showipatlogon, \nor simply by typing showip.\n\n"
	printf "${GREEN}+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+\n\n${NC}"
fi
