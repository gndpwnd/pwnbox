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
"https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32"
"https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64"
"https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh"
"https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64"
"https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_10.1.2_build/ghidra_10.1.2_PUBLIC_20220125.zip"
"https://github.com/RustScan/RustScan/releases/download/2.0.1/rustscan_2.0.1_amd64.deb"
"https://github.com/carlospolop/PEASS-ng/releases/download/20220310/linpeas.sh"
"https://github.com/carlospolop/PEASS-ng/releases/download/20220310/winPEAS.bat"
"https://github.com/carlospolop/PEASS-ng/releases/download/20220310/winPEASany_ofs.exe"
"https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_linux_amd64.gz"
"https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_windows_amd64.gz"
"https://github.com/jpillora/chisel/releases/download/v1.7.7/chisel_1.7.7_windows_386.gz"
"https://download.sysinternals.com/files/PSTools.zip"
"https://download.sysinternals.com/files/SysinternalsSuite.zip"
"https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20210810-2/mimikatz_trunk.zip"
"https://d2ap6ypl1xbe4k.cloudfront.net/Hopper-v4-4.7.1-Linux.deb"
"https://github.com/obsidianmd/obsidian-releases/releases/download/v0.12.15/obsidian_0.12.15_amd64.deb"
"https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-6.22.207-Linux-x64.deb"
"http://ftp.de.debian.org/debian/pool/main/libi/libindicator/libindicator3-7_0.5.0-2_amd64.deb"
"http://ftp.de.debian.org/debian/pool/main/liba/libappindicator/libappindicator3-1_0.4.92-7_amd64.deb"
"https://raw.githubusercontent.com/corelan/mona/master/mona.py"
"https://download.visualstudio.microsoft.com/download/pr/c505a449-9ecf-4352-8629-56216f521616/bd6807340faae05b61de340c8bf161e8/dotnet-sdk-6.0.201-linux-x64.tar.gz"
"https://github.com/syvaidya/openstego/releases/download/openstego-0.8.4/openstego_0.8.4-1_all.deb"
"https://www.netresec.com/?download=NetworkMiner"
"https://raw.githubusercontent.com/Tib3rius/Windows-PrivEsc-Setup/master/setup.bat"
"https://raw.githubusercontent.com/Tib3rius/privesc-setup/master/privesc-setup.sh"

# Maps
"https://github.com/C0nd4/OSCP-Priv-Esc/raw/main/images/Linux%20Privilege%20Escalation.png"
"https://github.com/C0nd4/OSCP-Priv-Esc/raw/main/images/Windows%20Privilege%20Escalation.png"
"https://github.com/hxhBrofessor/PrivEsc-MindMap/raw/main/Linux-Privesc.JPG"
"https://github.com/hxhBrofessor/PrivEsc-MindMap/raw/main/windows-mindMap.JPG"

# VMs
"https://dl2.boxcloud.com/d/1/b1!UH6ZgQc7Rt7axUaXcInU8MHWraOCGrAjZlvG3KmTf999r8jD_gS7v9lg58LrvJs9FZbFO8dVKQVO6Q1NMh3mh_k1BJ1lujEQIPWzIQOZ31_7nmjLDTgscUvAyyaBQcyDkMTo2CsJZs9stm0c_OMipnMEgIVKSqHb1-lCVdfeCqVbBbShZ48NntKZ9rpSYLxfh6D-dI62zGNnpSM4-uBrYTumrg8qvcIlcrh3XJaJlYFbD2YUhqJ5mBBzbwchrDFx2VhX_wj845DT83jq7rgD0D83wPFnza4rgzu74_GZsMLi76AMlqzWa-xOmkweuSp9xLj-V1Pyt9zzBjjkOpuFPaRZCr9-qPPNfKcbUWl-sL_CpaDeyr68TVxg0OTVXm69Z4EAg2dwLqXMdildaqp7nPOClnhk1Hu4UvPeHJFoCtix1ZoYdhlp-rpIJXSrSdox6VVAlUqMKScI3u4VbnHT38MkAn1_h8ov9ojvbtf2xZpTxOJt_vikKy9KhGEpRZ41fJEahJ1k49qEUlQATeDmt22UBSpJvOkhlKmEcuoaF-elPa2_QEYOtOVD_Z3jidrDbL9Gj-E5AsHo4EJ6izksv7vJZLeEC0lYNnShSJh9Jb0AQ1it05pJU-me7XZs92G3VAZk5e7Cv0S6XxsnFXXK8NNe4Y1bQcAHbHKqkpupRGzKW3byA9cOfyYwohhCr_uSstENs9RgS9ObmKgvmzrfWHCCuKgP-2r4yJ2PQtc3aLzhcVMTUQiFxLU4bgpC6qMgDcgvEKeG1QoUfBoKZOmxGAS4cyT0I5N47PzjWlYYoPtlGdcF1jTX9URUYMPuW17Myq43j-6TovpGY-1ffxuAs29YFW_rIjKu3Q9zpjLsPlLkA5rdisPffZbQ1rCkmcH_wLsya_uKpgUHXarW61EqNYY1pMnpc2IO48KA-Veix-WFvGwiBSKIiWSzRl1f__VtrrQe9o1REActHKtKO65n14m3LFmbVQfSYjxZYXKK1uvfT3J10tiDwfMkSl26jvptEBM5MSxyGBSCdgnpCiVrHcnKZxspv8asTwKut2ZuQkbLOs58WekRsz0fWOR0TC8po7jb56yWcICOLU6qQTVv1Sl83wNBT9nv3ujApDE7KwxXi1RTARboAUiCZMk1c-0jW6dH7Ig6_g7Uonwf9AgYLR0bWDTSZFhb1O1Xo6LTMfyUTzK8GyJ-lyFdZPSu5xyD3huEXRc_LYpMqFwv2MR7c7zWytdt17gFE7jSbDyevioYmO_JLh5zWHaku_Mq62mY-AgjBR0sOn0KdhSjasGUGVkvcXW4rZbrR-njkzZeb2XeuRLR/download"

# Mining

"https://phoenixminer.info/downloads/PhoenixMiner_6.2c_Linux.tar.gz"
"https://github.com/xmrig/xmrig/releases/download/v6.18.0/xmrig-6.18.0-linux-static-x64.tar.gz"
)
files=(
)
for link in "${links[@]}"; do
	filename=$(echo $link | rev | cut -f1 -d "/" | rev)
	files+=("$filename")
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
curl -u osint8:book4529zw -O https://inteltechniques.com/osintbook8/tools.zip > /dev/null 2>&1
mkdir ${dest_loc}tools/inteltechniques
unzip tools.zip -d ${dest_loc}tools/inteltechniques/
mv ${dest_loc}tools/inteltechniques/tools/* ${dest_loc}tools/inteltechniques/
rm -rf ${dest_loc}tools/inteltechniques/tools/ tools.zip
install_local_deb_apps_script="${dest_loc}install_local_deb_apps.sh"
echo -e "
#!/bin/bash
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
if (( \$EUID != 0 )); then
	printf \"\${RED}sudo privileges not detected!!!\n\"
	printf \"This must be run as root. Use: \${NC}'sudo bash \0'\n\"
 	exit
fi
apps=(
" > ${install_local_apps_script}
for file in "${files[@]}"; do
	if file == *.deb; then
		echo -e "	\"${dest_loc}tools/${file}\"" >> ${install_local_apps_script}
	fi
done
echo -e "
)
printf \"\${GREEN}[+] \${BLUE}Installing packages...\${NC}\n\"
for appfile in \${apps[@]}
do
	apt install -fy \${appfile}
	rm -rf \${appfile}
done
printf \"\${GREEN}DONE!!!\"
" >> ${install_local_apps_script}
printf "${Yellow}User should run:${NC} sudo bash ${install_local_apps_script}\n "
printf "${GREEN}DONE!!!"