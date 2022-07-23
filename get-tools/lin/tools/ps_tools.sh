#!/bin/bash
dest_loc=$1
if [ "$#" -ne 1 ]; then
	printf "usage: $0 <destination folder> \n"
	printf "example usage: $0 /opt \n"
	exit 
fi

if [ -z $dest_loc ]; then
	printf "${RED}No destination folder provided...\n"
	printf "${NC}usage: $0 <destination folder> \n"
	printf "${NC}example usage: $0 /opt/server/ps_scripts/ \n"
	exit
fi
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
scripts=(
"EmpireProject/Empire/master/data/module_source/situational_awareness/host/Invoke-WinEnum"
"EmpireProject/Empire/master/data/module_source/credentials/Invoke-PowerDump"
"EmpireProject/Empire/master/data/module_source/credentials/Invoke-TokenManipulation"
"EmpireProject/Empire/master/data/module_source/credentials/Invoke-DCSync"
"EmpireProject/Empire/master/data/module_source/credentials/Invoke-Mimikatz"
"EmpireProject/Empire/master/data/module_source/credentials/Invoke-Kerberoast"
"PowerShellEmpire/PowerTools/master/PowerView/powerview"
"PowerShellEmpire/PowerTools/master/PowerUp/PowerUp"
"PowerShellMafia/PowerSploit/master/Privesc/Get-System"
"PowerShellMafia/PowerSploit/master/Exfiltration/Get-Keystrokes"
"PowerShellMafia/PowerSploit/master/Exfiltration/Get-GPPPassword"
"PowerShellMafia/PowerSploit/master/Exfiltration/Get-GPPAutologon"
"PowerShellMafia/PowerSploit/master/Exfiltration/Get-TimedScreenshot"
"Kevin-Robertson/Tater/master/Tater"
"rasta-mouse/Sherlock/master/Sherlock"
"itm4n/PrivescCheck/master/PrivescCheck"
"411Hall/JAWS/master/jaws-enum"
"Arvanaghi/SessionGopher/master/SessionGopher"
"samratashok/nishang/master/Shells/Invoke-PowerShellTcp"
"besimorhino/powercat/master/powercat"
"mmessano/PowerShell/master/dns-dump"
"hausec/ADAPE-Script/master/ADAPE"
"orlyjamie/mimikittenz/master/Invoke-mimikittenz"
)
prog=1
progt=$((${#scripts[@]}+1))
if [[ ! -d "${dest_loc}" ]]
then
	printf "${BLUE}Creating ${GREEN}${dest_loc}${BLUE}...${NC}\n"
else
	printf "${YELLOW}${dest_loc}${YELLOW} exists, moving forward...\n"
fi
for script in "${scripts[@]}"; do
	script_name=$(echo $script | rev | cut -d '/' -f 1 | rev)
	printf "${GREEN}[${prog}/${progt}] ${NC}Downloading ${BLUE}${script_name}\n"
	wget https://raw.githubusercontent.com/${script}.ps1 -P ${dest_loc} > /dev/null 2>&1
	prog=$((prog+1))	
done
for (( i = 0; i < 10; i++ )); do
	rm -rf ${dest_loc}/*.ps1.${i} > /dev/null 2>&1
done
printf "${GREEN}[${prog}/${progt}] ${NC}Removed Duplicates from ${dest_loc} \n"
printf "${GREEN}DONE!!!"