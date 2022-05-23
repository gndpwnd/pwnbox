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
unset GREP_OPTIONS
update_dns() {
	echo "nameserver 1.1.1.1" > /etc/resolv.conf
	echo "nameserver 1.0.0.1" >> /etc/resolv.conf
	printf printf "${GREEN}[+] ${BLUE}Installed Cloudflare DNS..."
}
printf "${GREEN}[+] ${BLUE}Installing Blackarch repository...\n"
pacman -S curl 2>/dev/null
curl -O https://blackarch.org/strap.sh 2>/dev/null
chmod +x strap.sh 2>/dev/null
./strap.sh 2>/dev/null
pacman -Syu 2>/dev/null
printf "${GREEN}[+] ${BLUE}Everything is up to date...\n"
tools_list=(
"curl",
"golang",
"nasm",
"python",
"python-pip",
"jre-openjdk",
"terminator",
"git",
"docker",
"wireshark",
"sqlitebrowser",
"openvpn",
"audacity",
"exiftool",
"gqrx-sdr",
"clusterssh",
"audacity",
"adb",
"linux-headers-\$(uname -r)",
"rtl88xxau-aircrack-dkms-git",
"archlinux-keyring",
)

packages=""
for tool in "${tools_list[@]}"
do
	packages=${packages}${tool}
done
printf "${GREEN}[+] ${BLUE}Installing packages...${NC}\n"
pacman -S ${packages}
printf "${GREEN}[++++++++++] Packages have been installed...!!!${NC}\n"
printf "${GREEN}[+] ${BLUE}Enabling services...${NC}\n"

# Miscellaneous Packages
curl https://sh.rustup.rs -sSf | sh -s -- -y

services=(
docker
)
for service in ${services[@]}
do
	systemctl start $service
	systemctl enable $service
done
echo -e "
Just some final notes...
Run the following commands if you want to:

1. Add your user to the docker group
groupadd docker
usermod -aG docker <your user>
systemctl restart docker

"