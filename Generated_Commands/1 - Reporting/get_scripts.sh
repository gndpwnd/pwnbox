#!/bin/bash
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'

read -p "Enter the path where you want to create the 'crazy_server' directory: " dir_path

# Remove trailing slashes and expand to full path
full_path=$(realpath -m "$dir_path/crazy_server" 2>/dev/null)

# Check if the path is valid and writable
if [[ -z "$full_path" ]]; then
    echo "Error: Invalid path."
    exit 1
fi

# Check if parent directory exists
parent_dir=$(dirname "$full_path")
if [[ ! -d "$parent_dir" ]]; then
    echo "Error: Parent directory '$parent_dir' does not exist."
    exit 1
fi

# Attempt to create the directory
mkdir -p "$full_path" 2>/dev/null

PARENT_DIR="BOXLOCATION"
linux_dir="${PARENT_DIR}/linux"
windows_dir="${PARENT_DIR}/windows"
web_dir="${PARENT_DIR}/web"

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
    echo "WGET XP $url..."
    if ! wget -O ${web_dir}/$(basename "$url") "$url" ; then
        echo "Warning: Failed to download $url"
    fi
done

winPrivURLS=(
    "https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64"
    "https://github.com/peass-ng/PEASS-ng/releases/download/20241011-f83883c6/winPEAS.bat"
    "https://raw.githubusercontent.com/frizb/Windows-Privilege-Escalation/refs/heads/master/windows_recon.bat"
    "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/refs/heads/dev/Recon/PowerView.ps1"
    "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/refs/heads/dev/Privesc/PowerUp.ps1"
    "https://raw.githubusercontent.com/Tib3rius/Windows-PrivEsc-Setup/refs/heads/master/setup.bat"
    "https://raw.githubusercontent.com/corelan/mona/master/mona.py"
    "https://github.com/ParrotSec/mimikatz/raw/refs/heads/master/x64/mimikatz.exe"
    "https://github.com/ParrotSec/mimikatz/raw/refs/heads/master/x64/mimidrv.sys"
    "https://github.com/ParrotSec/mimikatz/raw/refs/heads/master/x64/mimilib.dll"
)

for url in "${winPrivURLS[@]}"; do
    filename=$(basename "$url")
    file_path="${winpriv_dir}/${filename}"
    echo "Checking for file: $file_path..."
    # Check if the file already exists
    if [ -e "$file_path" ]; then
        echo "File already exists: $file_path. Skipping download."
    else
        echo "WGET PRIVESC $url..."
        if ! wget -O "$file_path" "$url"; then
            echo "Warning: Failed to download $url"
        else
            echo "Successfully downloaded $url to $file_path"
        fi
    fi
done

winSysenumURLS=(
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
    "chryzsh/JenkinsPasswordSpray/master/JenkinsPasswordSpray"
    "FortyNorthSecurity/CLM-Base64/master/CLM-Base64"
    "darkoperator/Veil-PowerView/master/PowerView/functions/Invoke-UserHunter"
    "puckiestyle/powershell/master/SharpHound"
    "BloodHoundAD/BloodHound/master/Collectors/AzureHound"
    "darkoperator/Veil-PowerView/master/PowerView/functions/Invoke-ShareFinder"
    "NetSPI/PowerUpSQL/master/PowerUpSQL"
)

for url in "${winSysenumURLS[@]}"; do
    filename=$(basename "$url")
    file_path="${winsysenum_dir}/${filename}"
    echo "Checking for file: $file_path..."
    # Check if the file already exists
    if [ -e "$file_path" ]; then
        echo "File already exists: $file_path. Skipping download."
    else
        echo "WGET SYSENUM $url..."
        if ! wget -O "$file_path" "$url"; then
            echo "Warning: Failed to download $url"
        else
            echo "Successfully downloaded $url to $file_path"
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
    echo "Checking for file: $file_path..."
    # Check if the file already exists
    if [ -e "$file_path" ]; then
        echo "File already exists: $file_path. Skipping download."
    else
        echo "WGET PRIVESC $url..."
        if ! wget -O "$file_path" "$url"; then
            echo "Warning: Failed to download $url"
        else
            echo "Successfully downloaded $url to $file_path"
        fi
    fi
done

windowsSysToolsURLS=(
    "https://download.sysinternals.com/files/PSTools.zip"
    "https://download.sysinternals.com/files/SysinternalsSuite.zip"
    "https://www.netresec.com/?download=NetworkMiner"
)

for url in "${windowsSysToolsURLS[@]}"; do
    filename=$(basename "$url")
    file_path="${winsystools_dir}/${filename}"
    echo "Checking for file: $file_path..."
    # Check if the file already exists
    if [ -e "$file_path" ]; then
        echo "File already exists: $file_path. Skipping download."
    else
        echo "WGET SYSTOOLS $url..."
        if ! wget -O "$file_path" "$url"; then
            echo "Warning: Failed to download $url"
        else
            echo "Successfully downloaded $url to $file_path"
        fi
    fi
done

dockerURLS=(
    "rustscan/rustscan"
    "byt3bl33d3r/crackmapexec"
    "calebjstewart/pwncat"
    "empireproject/empire"
    "oscarakaelvis/evil-winrm"
    "belane/bloodhound"
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

for dockerURL in "${dockerURLs[@]}"; do
    echo "Pulling Docker image: $dockerURL"
    docker pull "$dockerURL"
done

printf "\n\n${GREEN}DONE !!!   \n"