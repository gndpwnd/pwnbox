#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
if (( $EUID != 0 )); then
	printf "${RED}sudo privileges not detected!!!\n"
	printf "This must be run as root.\nUse: ${NC}'sudo bash $0'\n"
 	exit
fi
apt install -fy snapd
systemctl start snapd
systemctl enable snapd
snap_packages=(
"code --classic"
"sublime-text --classic"
"simplescreenrecorder"
)
snap_aliases=(
""
)
printf "${GREEN}[+] ${BLUE}Installing packages...${NC}\n"
for package in ${snap_packages[@]}
do
	snap install $package
done
printf "${GREEN}[+] ${BLUE}Creating aliases...${NC}\n"
for package in ${snap_packages[@]}
do
	snap alias $snap_aliases
done
echo -e "
${YELLOW}[-] Add the following line to your user's .bashrc or .zshrc:${NC}

export DOTNET_ROOT=/snap/dotnet-sdk/current

" 
printf "${GREEN}[+] Done!!!"