#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
if (( $EUID != 0 )); then
	printf "${RED}[x] sudo privileges not detected!!!\n"
	printf "This must be run as root.\nUse: ${NC}'sudo bash $0'\n"
 	exit
fi
unset GREP_OPTIONS
echo "nameserver 1.1.1.1" > /etc/resolv.conf
echo "nameserver 1.0.0.1" >> /etc/resolv.conf
printf printf "${GREEN}[+] ${BLUE}Installed Cloudflare DNS...\n"

# Wireless Drivers
printf "${GREEN}[+] ${BLUE}Installing Wireless Drivers...\n"
git clone https://github.com/aircrack-ng/rtl8812au.git
cd rtl8812au/
make &&  make install