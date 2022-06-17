#!/bin/bash
dest_loc=$1
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage () {
	printf "\n${NC}usage: $0 <destination folder>\n\n"
	printf "${NC}example usage: $0 /opt\n\n"
	exit
}

if [ "$#" -ne 1 ]; then
	usage 
fi
if [ -z $dest_loc ]; then
	printf "${RED}No destination folder provided...\n"
	usage
fi
if [ ! -d "$dest_loc" ]; then
	printf "${GREEN}Creating $dest_loc...\n"
	mkdir $dest_loc
else
	printf "${YELLOW}$dest_loc exists moving forward...\n"
fi

tools=(
# Trolling
"jmhobbs/terminal-parrot"
# Recon
"Tib3rius/AutoRecon"
# Networking
"iphelix/dnschef bitbrute/evillimiter"
# Hardware
"jopohl/urh dwisiswant0/apkleaks attify/firmware-analysis-toolkit aircrack-ng/rtl8812au"
# Web
"ffuf/ffuf maurosoria/dirsearch s0md3v/Photon D35m0nd142/LFISuite kurobeats/fimap hakluke/hakrawler ChrisTruncer/EyeWitness aboul3la/Sublist3r s0md3v/XSStrike nccgroup/shocker"
# Exploitation
"trustedsec/unicorn pentestmonkey/php-reverse-shell swisskyrepo/PayloadsAllTheThings"
# Post-Exploitaion
"loseys/BlackMamba calebstewart/pwncat Screetsec/TheFatRat n1nj4sec/pupy jm33-m0/emp3r0r redcode-labs/Bashark bats3c/shad0w"
# Active-Directory
"byt3bl33d3r/pth-toolkit galkan/crowbar cobbr/Covenant cobbr/SharpSploit lgandx/Responder-Windows EmpireProject/Empire SecureAuthCorp/impacket samratashok/nishang GhostPack/Rubeus GhostPack/Seatbelt gentilkiwi/kekeo NetSPI/PowerUpSQL samratashok/ADModule"
# Automation
"JohnHammond/poor-mans-pentest izar/pytm Gallopsled/pwntools bee-san/pyWhat OWASP/Amass malwaredllc/byob"
# Encryption
"Ganapati/RsaCtfTool"
# Reversing
"mentebinaria/retoolkit InstinctEx/deobfuscatetools beurtschipper/Depix jtpereyda/boofuzz icsharpcode/ILSpy volatilityfoundation/volatility"
# OSINT
"laramies/theHarvester alpkeskin/mosint sherlock-project/sherlock qeeqbox/social-analyzer twintproject/twint althonos/InstaLooter WebBreacher/WhatsMyName GuidoBartoli/sherloq lanmaster53/recon-ng smicallef/spiderfoot mikf/gallery-dl akamhy/waybackpy laramies/metagoofil aliparlakci/bulk-downloader-for-reddit streamlink/streamlink iojw/socialscan megadose/holehe ytdl-org/youtube-dl AmIJesse/Elasticsearch-Crawler"
# Social
"An0nUD4Y/blackeye"
# Forensics
"decalage2/oletools sleuthkit/autopsy"
# Other
"internetwache/GitTools danielmiessler/SecLists andrew-d/static-binaries 0dayCTF/reverse-shell-generator"
)

cats=(
"Trolling"
"Recon"
"Networking"
"Hardware"
"Web"
"Exploitation"
"Post-Exploitaion"
"Active-Directory"
"Automation"
"Encryption"
"Reversing"
"OSINT"
"Social"
"Forensics"
"Other"
)

get_git_tools () {
	export i=0
	for list in "${tools[@]}"
		do
		mkdir -p $dest_loc/${cats[$i]}
		printf "\n\n${NC}Downloading Category: ${YELLOW}${cats[$i]}\n\n"
		for repo in $list
			do
			tool_name=$(echo $repo | cut -f2 -d "/")
			printf "\n${GREEN}[+] ${NC}Cloning into ${GREEN}${tool_name}${BLUE}\n"
			git clone https://github.com/${repo}.git ${dest_loc}/${cats[$i]}/${tool_name}
		done
		i=$((i+1))
	done
}

get_git_tools