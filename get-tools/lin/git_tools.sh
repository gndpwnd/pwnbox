#!/bin/bash
dest_loc=$1
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
if [ "$#" -ne 1 ]; then
	printf "\n${NC}usage: $0 <destination folder>\n\n"
	printf "${NC}example usage: $0 /opt/\n\n"
	exit 
fi
if [ -z $dest_loc ]; then
	printf "${RED}No destination folder provided...\n"
	printf "${NC}usage: $0 <destination folder>"
	printf "${NC}example usage: $0 /opt/"
	exit
fi
if [ ! -d "$dest_loc" ]; then
	printf "${GREEN}Creating $dest_loc...\n"
	mkdir $dest_loc
else
	printf "${YELLOW}$dest_loc exists, moving forward...\n"
fi

git_tools=(

# Trolling in wargames

"jmhobbs/terminal-parrot"

# Recon

"Tib3rius/AutoRecon"

# Networking

"iphelix/dnschef"
"bitbrute/evillimiter"

# Hardware

"jopohl/urh"
"dwisiswant0/apkleaks"
"attify/firmware-analysis-toolkit"
"aircrack-ng/rtl8812au"

# Web

"ffuf/ffuf"
"maurosoria/dirsearch"
"s0md3v/Photon"
"D35m0nd142/LFISuite"
"kurobeats/fimap"
"hakluke/hakrawler"
"ChrisTruncer/EyeWitness"
"aboul3la/Sublist3r"
"s0md3v/XSStrike"
"nccgroup/shocker"

# Exploitation

"trustedsec/unicorn"
"pentestmonkey/php-reverse-shell"
"swisskyrepo/PayloadsAllTheThings"

# Post-Exploitaion

"loseys/BlackMamba"
"calebstewart/pwncat"
"Screetsec/TheFatRat"
"n1nj4sec/pupy"
"jm33-m0/emp3r0r"
"redcode-labs/Bashark"
"bats3c/shad0w"

# Active Directory

"byt3bl33d3r/pth-toolkit"
"galkan/crowbar"
"cobbr/Covenant"
"cobbr/SharpSploit"
"lgandx/Responder-Windows"
"EmpireProject/Empire"
"SecureAuthCorp/impacket"
"samratashok/nishang"
"GhostPack/Rubeus"
"GhostPack/Seatbelt"

# Automation

"JohnHammond/poor-mans-pentest"
"izar/pytm"
"Gallopsled/pwntools"
"bee-san/pyWhat"
"OWASP/Amass"
"malwaredllc/byob"

# Encryption

"Ganapati/RsaCtfTool"

# Databases

"0dayCTF/reverse-shell-generator"

# Reversing

"mentebinaria/retoolkit"
"InstinctEx/deobfuscatetools"
"beurtschipper/Depix"
"jtpereyda/boofuzz"
"icsharpcode/ILSpy"
"volatilityfoundation/volatility"

# Misc

"internetwache/GitTools"
"danielmiessler/SecLists"
"andrew-d/static-binaries"

# OSINT

"laramies/theHarvester"
"alpkeskin/mosint"
"sherlock-project/sherlock"
"qeeqbox/social-analyzer"
"twintproject/twint"
"althonos/InstaLooter"
"WebBreacher/WhatsMyName"
"GuidoBartoli/sherloq"
"lanmaster53/recon-ng"
"smicallef/spiderfoot"
"mikf/gallery-dl"
"akamhy/waybackpy"
"laramies/metagoofil"
"aliparlakci/bulk-downloader-for-reddit"
"streamlink/streamlink"
"iojw/socialscan"
"megadose/holehe"
"ytdl-org/youtube-dl"
"AmIJesse/Elasticsearch-Crawler"

# Social
An0nUD4Y/blackeye

# Files
"decalage2/oletools"
)

prog=1
progt=${#git_tools[@]}
for repo in ${git_tools[@]}
do
	tool_name=$(echo $repo | cut -f2 -d "/")
	if [[ ! -d "${dest_loc}/${tool_name}" ]]
	then
		printf "${GREEN}[${prog}/${progt}] ${NC}Cloning into ${BLUE}${tool_name}\n"
		git clone https://github.com/${repo}.git ${dest_loc}/${tool_name} > /dev/null 2>&1
	else
		printf "${RED}[${prog}/${progt}] ${YELLOW}${tool_name}${NC} exists\n"
	fi
	prog=$((prog+1))
done
printf "${GREEN}DONE!!!"
