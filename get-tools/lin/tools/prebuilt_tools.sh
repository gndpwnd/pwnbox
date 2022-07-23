#!/bin/bash
dest_loc=$1
if [ "$#" -ne 1 ]; then
	printf "usage: $0 <destination folder> \n"
	printf "example usage: $0 /opt/server/ \n"
	exit 
fi

if [ -z $dest_loc ]; then
	printf "No destination folder provided... \n"
	printf "usage: $0 <destination folder> \n"
	printf "example usage: $0 /opt/server/ \n"
	exit
fi
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
links=(
"https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.1.2_build/ghidra_10.1.2_PUBLIC_20220125.zip"
"https://github.com/RustScan/RustScan/releases/download/2.0.1/rustscan_2.0.1_amd64.deb"
"https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_linux_amd64.gz"
"https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_windows_amd64.gz"
"https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_windows_386.gz"
"https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20210810-2/mimikatz_trunk.zip"
"https://d2ap6ypl1xbe4k.cloudfront.net/Hopper-v4-4.7.1-Linux.deb"
"https://github.com/obsidianmd/obsidian-releases/releases/download/v0.12.15/obsidian_0.12.15_amd64.deb"
"https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-6.22.207-Linux-x64.deb"
"http://ftp.de.debian.org/debian/pool/main/libi/libindicator/libindicator3-7_0.5.0-2_amd64.deb"
"http://ftp.de.debian.org/debian/pool/main/liba/libappindicator/libappindicator3-1_0.4.92-7_amd64.deb"
"https://download.visualstudio.microsoft.com/download/pr/c505a449-9ecf-4352-8629-56216f521616/bd6807340faae05b61de340c8bf161e8/dotnet-sdk-6.0.201-linux-x64.tar.gz"
"https://github.com/syvaidya/openstego/releases/download/openstego-0.8.4/openstego_0.8.4-1_all.deb"
"https://www.netresec.com/?download=NetworkMiner"
)
deployable_links=(
"https://raw.githubusercontent.com/Tib3rius/Windows-PrivEsc-Setup/master/setup.bat"
"https://raw.githubusercontent.com/Tib3rius/privesc-setup/master/privesc-setup.sh"
"https://raw.githubusercontent.com/corelan/mona/master/mona.py"
"https://download.sysinternals.com/files/PSTools.zip"
"https://download.sysinternals.com/files/SysinternalsSuite.zip"
"https://github.com/carlospolop/PEASS-ng/releases/download/20220310/linpeas.sh"
"https://github.com/carlospolop/PEASS-ng/releases/download/20220310/winPEAS.bat"
"https://github.com/carlospolop/PEASS-ng/releases/download/20220310/winPEASany_ofs.exe"
"https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32"
"https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64"
"https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh"
"https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64"
)


files=(
)
for link in "${links[@]}"; do
	filename=$(echo $link | rev | cut -f1 -d "/" | rev)
	files+=("$filename")
done

deployable_files=(
)
for link in "${deployable_links[@]}"; do
	filename=$(echo $link | rev | cut -f1 -d "/" | rev)
	deployable_files+=("$filename")
done

i=0
prog=1
progt=${#links[@]}
if [[ ! -d "${dest_loc}" ]]
then
	mkdir $dest_loc
	cd $dest_loc
	printf "${BLUE}Created ${GREEN}${dest_loc}${BLUE}...\n"
else
	printf "${YELLOW}${dest_loc}${YELLOW} exists, moving forward...\n"
fi
for link in "${links[@]}"; do
	if [[ ! -f "${dest_loc}tool/${files[i]}" ]]
	then
		printf "${GREEN}[${prog}/${progt}] ${NC}Downloading ${BLUE}${files[i]}${NC}\n"
		wget ${link} -P ${dest_loc}tools/ > /dev/null 2>&1
	else
		printf "${RED}[${prog}/${progt}] ${YELLOW}${dest_loc}${files[i]}${NC} exists\n"
	fi
	i=$((i+1))
	prog=$((prog+1))	
done

i=0
prog=1
progt=${#deployable_links[@]}
if [[ ! -d "${dest_loc}/deployable_tools/" ]]
then
	mkdir ${dest_loc}/deployable_tools/
	cd ${dest_loc}/deployable_tools/
	printf "${BLUE}Created ${GREEN}${dest_loc}${BLUE}...\n"
else
	printf "${YELLOW}${dest_loc}${YELLOW} exists, moving forward...\n"
fi
for link in "${deployable_links[@]}"; do
	if [[ ! -f "${dest_loc}/deployable_tools/${deployable_files[i]}" ]]
	then
		printf "${GREEN}[${prog}/${progt}] ${NC}Downloading ${BLUE}${deployable_files[i]}${NC}\n"
		wget ${link} -P ${dest_loc}/deployable_tools/ > /dev/null 2>&1
	else
		printf "${RED}[${prog}/${progt}] ${YELLOW}${dest_loc}${deployable_files[i]}${NC} exists\n"
	fi
	i=$((i+1))
	prog=$((prog+1))	
done

# Recent update to the inteltechniques site nulls the following download
#curl -u osint8:book4529zw -O https://inteltechniques.com/osintbook8/tools.zip > /dev/null 2>&1
#mkdir ${dest_loc}tools/inteltechniques
#unzip tools.zip -d ${dest_loc}tools/inteltechniques/
#mv ${dest_loc}tools/inteltechniques/tools/* ${dest_loc}tools/inteltechniques/
#rm -rf ${dest_loc}tools/inteltechniques/tools/ tools.zip

printf "${GREEN}DONE!!!"