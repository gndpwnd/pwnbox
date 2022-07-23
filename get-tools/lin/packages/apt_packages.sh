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
have_repo=$(cat sources.list | grep "deb http://http.kali.org/kali kali-rolling main contrib non-free")
if [[ $have_repo == *"deb http://http.kali.org/kali kali-rolling main non-free contrib"* ]]
then
	if [[ $have_repo != *"#"* ]]
	then
		printf "${GREEN}[+] ${BLUE}Kali Linux Repo is installed...\n"
	else
		printf "${YELLOW}[o] ${NC}Kali Linux Repo has been commented out...\n"
		sed -i "s+#deb http://http.kali.org/kali+d" /etc/apt/sources.list > /dev/null 2>&1
		sed -i "s+# deb http://http.kali.org/kali+d" /etc/apt/sources.list > /dev/null 2>&1
		printf "${GREEN}[+] ${NC}Kali Linux Repo has been uncommented...\n"
		echo 'deb http://http.kali.org/kali kali-rolling main non-free contrib' >> /etc/apt/sources.list
		printf "${GREEN}[+] ${NC}Kali Linux Repo is now installed...\n"
	fi
else
	printf "${YELLOW}[o] ${NC}Kali Linux Repo does not exist...\n"
	wget -q -O - archive.kali.org/archive-key.asc | apt-key add > /dev/null 2>&1
	apt-key adv --keyserver hkp://keys.gnupg.net --recv-keys 7D8D0BF6
	echo 'deb http://http.kali.org/kali kali-rolling main non-free contrib' >> /etc/apt/sources.list
	printf "${GREEN}[+] ${NC}Kali Linux Repo is now installed...\n"
fi
apt-get update > /dev/null 2>&1
printf "${GREEN}[+] ${NC}Everything is up to date...\n"
tools_list=(
"curl"
"snapd"
"apt-transport-https"
"htop"
"iftop"
"sqlitebrowser" 
"default-jdk"
"terminator"
"git"
"docker.io"
"cherrytree"
"wireshark" 
"sqlitebrowser"  
"terminator" 
"openvpn" 
"audacity" 
"exiftool" 
"nasm" 
"binwalk" 
"radare2" 
"gdb" 
"gqrx-sdr" 
"clusterssh" 
"audacity" 
"bloodhound"
"tor"
"nmap" 
"masscan" 
"exploitdb" 
"armitage" 
"set" 
"dsniff" 
"nikto" 
"osrframework" 
"recon-ng"
"netdiscover" 
"legion" 
"voiphopper" 
"zaproxy" 
"enum4linux" 
"dmitry" 
"dnsrecon" 
"dnsenum"
"dnstracer" 
"theharvester" 
"thc-ipv6"
"reaver" 
"aircrack-ng" 
"rtlsdr-scanner" 
"gqrx-sdr" 
"wifite" 
"pixiewps" 
"burpsuite"
"dirb" 
"dirbuster" 
"gobuster" 
"wpscan" 
"wordlists" 
"sqlmap" 
"sqlninja" 
"uniscan" 
"websploit" 
"ffuf" 
"siparmyknife"
"powersploit" 
"backdoor-factory" 
"veil-evasion" 
"bettercap" 
"beef-xss" 
"rtpflood"
"crunch" 
"hash-identifier" 
"john" 
"johnny" 
"rainbowcrack" 
"hashcat" 
"arduino" 
"crowbar" 
"hydra"
"powershell-empire" 
"starkiller"
"adb" 
"bison" 
"gawk" 
"bc" 
"ccache" 
"device-tree-compiler" 
"dex2jar" 
"android-sdk"
"iperf3" 
"speedtest-cli" 
"vlc"
"build-essential"
"libelf-dev" 
"linux-headers-$(uname -r)"
"realtek-rtl88xxau-dkms"
"remmina"
"smtp-user-enum"
"ismtp"
"onesixtyone"
"snmpenum"
"snmpcheck"
"texlive-latex-recommended"
"texlive-fonts-extra"
"texlive-latex-extra" 
"pandoc" 
"p7zip-full"
"texlive-xetex"
"ruby"
"ruby-dev"
"golang"
"python3"
"python3-dev"
"python3-pip"
"mono-devel"
"tcpflow"
)
packages=""
for tool in "${tools_list[@]}"
do
	packages="${packages} ${tool}"
done
printf "${GREEN}[+] ${NC}Installing packages...${NC}\n"
apt install -fy ${packages}
printf "${GREEN}[++++++++++] Packages have been installed...!!!${NC}\n"
printf "${GREEN}[+] ${NC}Enabling services...${NC}\n"

# Miscellaneous Packages
curl https://sh.rustup.rs -sSf | sh -s -- -y

services=(
"docker",
"snapd"
)
for service in ${services[@]}
do
	systemctl start $service
	systemctl enable $service
done
echo -e "
${YELLOW}[o] ${NC}Just some final notes...${NC}
Run the following commands if you want to:

1. Add your user to the docker group
groupadd docker
usermod -aG docker <your user>
systemctl restart docker

"
