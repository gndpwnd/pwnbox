#!/bin/bash

# Uses WGET to download common system enumeration and privilege escalation tools.
# Also downloads useful docker images

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'
RED='\033[0;31m'

echo "Select 'quickserv' install directory"
read -p "Enter a path ( must exist, e.g. /opt ): " dir_path

# Remove trailing slashes and expand to full path
quikserv_dir=$(realpath -m "$dir_path/quikserv" 2>/dev/null)

# Check if the path is valid and writable
if [[ -z "$quikserv_dir" ]]; then
    echo "Error: Invalid path."
    exit 1
fi

# Check if parent directory exists
parent_dir=$(dirname "$quikserv_dir")
if [[ ! -d "$parent_dir" ]]; then
    echo "Error: Parent directory '$parent_dir' does not exist."
    exit 1
fi

# Attempt to create the directory
mkdir -p "$quikserv_dir" 2>/dev/null

linux_dir="${quikserv_dir}/linux"
windows_dir="${quikserv_dir}/windows"
web_dir="${quikserv_dir}/web"

winpriv_dir="${windows_dir}/privesc"
winsysenum_dir="${windows_dir}/sysenum"
winsystools_dir="${windows_dir}/systools"
linpriv_dir="${linux_dir}/privesc"
#linsysenum_dir="${linux_dir}/sysenum" # have no need

mkdir $linux_dir
mkdir $windows_dir
mkdir $web_dir
mkdir $winpriv_dir
mkdir $winsysenum_dir
mkdir $linpriv_dir
#mkdir $linsysenum_dir # have no need

webURLS=(
    "https://raw.githubusercontent.com/Arrexel/phpbash/refs/heads/master/phpbash.php"
)

for url in "${webURLS[@]}"; do
    filename=$(basename "$url")
    file_path="${winpriv_dir}/${filename}"
    #echo "Checking for file: $file_path..."
    if [ -e "$file_path" ]; then
        echo "File already exists: $file_path. Skipping download."
    else
        #echo "WGET XP $url..."
        if ! wget -O ${web_dir}/$(basename "$url") "$url" 2>/dev/null; then
            printf "${RED}Warning: Failed to download ${YELLOW}${url}${NC}\n"
        else
            printf "${GREEN}[+] ${NC}${filename}\n"
        fi
    fi
done

winPrivURLS=(
    "https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64"
    "https://github.com/peass-ng/PEASS-ng/releases/download/20241011-f83883c6/winPEAS.bat"
    "https://raw.githubusercontent.com/frizb/Windows-Privilege-Escalation/refs/heads/master/windows_recon.bat"
    "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/refs/heads/dev/Recon/PowerView.ps1"
    "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/refs/heads/dev/Privesc/PowerUp.ps1"
    "https://raw.githubusercontent.com/740i/pentest-notes/refs/heads/master/RedTeam_CheatSheet.ps1"
    "https://raw.githubusercontent.com/Tib3rius/Windows-PrivEsc-Setup/refs/heads/master/setup.bat"
    "https://raw.githubusercontent.com/corelan/mona/master/mona.py"
    "https://github.com/ParrotSec/mimikatz/raw/refs/heads/master/x64/mimikatz.exe"
    "https://github.com/ParrotSec/mimikatz/raw/refs/heads/master/x64/mimidrv.sys"
    "https://github.com/ParrotSec/mimikatz/raw/refs/heads/master/x64/mimilib.dll"
)

for url in "${winPrivURLS[@]}"; do
    filename=$(basename "$url")
    file_path="${winpriv_dir}/${filename}"
    #echo "Checking for file: $file_path..."
    # Check if the file already exists
    if [ -e "$file_path" ]; then
        echo "File already exists: $file_path. Skipping download."
    else
        #echo "WGET PRIVESC $url..."
        if ! wget -O "$file_path" "$url" 2>/dev/null; then
            printf "${RED}Warning: Failed to download ${YELLOW}${url}${NC}\n"
        else
            printf "${GREEN}[+] ${NC}${filename}\n"
        fi
    fi
done

winSysenumURLS=(
    "EmpireProject/Empire/refs/heads/master/data/module_source/situational_awareness/host/Invoke-WinEnum"
    "EmpireProject/Empire/refs/heads/master/data/module_source/credentials/Invoke-PowerDump"
    "EmpireProject/Empire/refs/heads/master/data/module_source/credentials/Invoke-TokenManipulation"
    "EmpireProject/Empire/refs/heads/master/data/module_source/credentials/Invoke-DCSync"
    "EmpireProject/Empire/refs/heads/master/data/module_source/credentials/Invoke-Mimikatz"
    "EmpireProject/Empire/refs/heads/master/data/module_source/credentials/Invoke-Kerberoast"
    "PowerShellEmpire/PowerTools/refs/heads/master/PowerView/powerview"
    "PowerShellEmpire/PowerTools/refs/heads/master/PowerUp/PowerUp"
    "PowerShellMafia/PowerSploit/refs/heads/master/Privesc/Get-System"
    "PowerShellMafia/PowerSploit/refs/heads/master/Exfiltration/Get-Keystrokes"
    "PowerShellMafia/PowerSploit/refs/heads/master/Exfiltration/Get-GPPPassword"
    "PowerShellMafia/PowerSploit/refs/heads/master/Exfiltration/Get-GPPAutologon"
    "PowerShellMafia/PowerSploit/refs/heads/master/Exfiltration/Get-TimedScreenshot"
    "Kevin-Robertson/Tater/refs/heads/master/Tater"
    "rasta-mouse/Sherlock/refs/heads/master/Sherlock"
    "itm4n/PrivescCheck/refs/heads/master/PrivescCheck"
    "411Hall/JAWS/refs/heads/master/jaws-enum"
    "Arvanaghi/SessionGopher/refs/heads/master/SessionGopher"
    "samratashok/nishang/refs/heads/master/Shells/Invoke-PowerShellTcp"
    "besimorhino/powercat/refs/heads/master/powercat"
    "mmessano/PowerShell/refs/heads/master/dns-dump"
    "hausec/ADAPE-Script/refs/heads/master/ADAPE"
    "orlyjamie/mimikittenz/refs/heads/master/Invoke-mimikittenz"
    "chryzsh/JenkinsPasswordSpray/refs/heads/master/JenkinsPasswordSpray"
    "FortyNorthSecurity/CLM-Base64/refs/heads/master/CLM-Base64"
    "darkoperator/Veil-PowerView/refs/heads/master/PowerView/functions/Invoke-UserHunter"
    "puckiestyle/powershell/refs/heads/master/SharpHound"
    "darkoperator/Veil-PowerView/refs/heads/master/PowerView/functions/Invoke-ShareFinder"
    "NetSPI/PowerUpSQL/refs/heads/master/PowerUpSQL"
)

for url in "${winSysenumURLS[@]}"; do
    filename=$(basename "$url")
    file_path="${winsysenum_dir}/${filename}"
    #echo "Checking for file: $file_path..."
    # Check if the file already exists
    if [ -e "$file_path" ]; then
        echo "File already exists: $file_path. Skipping download."
    else
        #echo "WGET SYSENUM $url..."
        if ! wget -O "${file_path}.ps1" "https://raw.githubusercontent.com/${url}.ps1" 2>/dev/null; then
            printf "${RED}Warning: Failed to download ${YELLOW}${url}${NC}\n"
        else
            printf "${GREEN}[+] ${NC}${filename}.ps1\n"
        fi
    fi
done

linPrivURLS=(
    "https://github.com/peass-ng/PEASS-ng/releases/download/20241011-f83883c6/linpeas.sh"
    "https://github.com/peass-ng/PEASS-ng/releases/download/20241011-f83883c6/linpeas_small.sh"
    "https://raw.githubusercontent.com/rebootuser/LinEnum/refs/heads/master/LinEnum.sh"
    "https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy32"
    "https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64"
    "https://raw.githubusercontent.com/Tib3rius/privesc-setup/master/privesc-setup.sh"
)

for url in "${linPrivURLS[@]}"; do
    filename=$(basename "$url")
    file_path="${linpriv_dir}/${filename}"
    #echo "Checking for file: $file_path..."
    # Check if the file already exists
    if [ -e "$file_path" ]; then
        echo "File already exists: $file_path. Skipping download."
    else
        #echo "WGET PRIVESC $url..."
        if ! wget -O "$file_path" "$url" 2>/dev/null; then
            printf "${RED}Warning: Failed to download ${YELLOW}${url}${NC}\n"
        else
            printf "${GREEN}[+] ${NC}${filename}\n"
        fi
    fi
done

windowsSysToolsURLS=(
    "https://download.sysinternals.com/files/PSTools.zip"
    "https://download.sysinternals.com/files/SysinternalsSuite.zip"
    "https://www.netresec.com/?download=NetworkMiner"
)

for url in "${windowsSysToolsURLS[@]}"; do
    #echo "WGET SYSTOOLS $url..."
    if ! wget -P "${winsystools_dir}/" "$url" 2>/dev/null; then
        printf "${RED}Warning: Failed to download ${YELLOW}${url}${NC}\n"
    else
        printf "${GREEN}[+] ${NC}${filename}\n"
    fi
done

dockerURLS=(
    "rustscan/rustscan"
    "byt3bl33d3r/crackmapexec"
    "calebjstewart/pwncat"
    "empireproject/empire"
    "oscarakaelvis/evil-winrm"
    "belane/bloodhound"
    "SpecterOps/BloodHound"
    "rickdejager/stegseek"
    "paradoxis/stegcracker"
    "bannsec/stegoveritas"
    "dominicbreuker/stego-toolkit"
    "empireproject/empire"
    "projectdiscovery/nuclei"
    "projectdiscovery/subfinder"
    "projectdiscovery/httpx"
    "projectdiscovery/naabu"
    "projectdiscovery/interactsh-client"
    "wpscanteam/wpscan"
)

for dockerURL in "${dockerURLS[@]}"; do
    echo "Pulling Docker image: ${dockerURL}"
    if ! docker pull "${dockerURL}" 2>/dev/null; then
        printf "${RED}Warning: Failed to download ${YELLOW}${dockerURL}${NC}\n"
    else
        printf "${GREEN}[+] ${BLUE}${dockerURL}${NC}\n"
    fi
done

printf "\n${GREEN}[+] ${NC}Check out ${CYAN}${quikserv_dir}"

printf "\n\n${GREEN}DONE !!!   \n"