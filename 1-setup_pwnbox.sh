#!/bin/bash

##############################
#        Main Vars  	     #
##############################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

i_progress=1
t_progress=6
unset GREP_OPTIONS

##############################
# 			Options 	 	 #
##############################

usage() {
	echo -e "
	${NC}usage: pwnbox -d DEVICE -o NAME -i IP -n HOST -r TEMPLATE -w TOKEN

	OPTIONS:

	-h 			 	show this menu

	-d DEVICE  		network interface of target network
	
	-o NAME   		target box name (does not need to = HOST)
	
	-i IP     		ip of the target box

	-n HOST   		(optional) hostname of the target box
					You can always run the gen_commands script
					with only the hostname later.

	-r TEMPLATE 	 	select a report template (1-6)
						leave blank, or use 0 for default
					
						Templates (Default 1)   				
						
						1. OSCP whoisflynn
						2. OSCP v2
						3. OSWE xl_sec
						4. OSWP v1
						5. OSED v1
						6. OSEP ceso

	-w TOKEN		 	(optional) wordpress api token
	"
}

inf=
box_name=
box_ip=
box_host=
rtemp=
wpapi=

while getopts “:hd:t:o:i:n:r:w:” OPTION
do
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    d)
      inf=$OPTARG
      ;;
    o)
      box_name=$OPTARG
      ;;
    i)
      box_ip=$OPTARG
      ;;
	n)
	  box_host=$OPTARG
	  ;;
    r)
      rtemp=$OPTARG
      ;;

    w)
      wpapi=$OPTARG
      ;;
    ?)
      usage
      exit
      ;;
	:)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

##############################
# 		Troubleshooting 	 #
##############################

troubleshooting () {
	if (( $EUID != 0 )); then
		printf "${RED}[x] sudo privileges not detected!!!\n"
		exit 1
	fi

	# If Required Args are empty

	if [ -z $inf ]; then
		printf "${RED}[x] (-d) No Network Interface Provided!!!\n"
		exit 1
	elif [ -z $box_name ]; then
		printf "${RED}[x] (-o) No Name Provided!!! \n"
		exit 1
	elif [ -z $box_ip ]; then
		printf "${RED}[x] (-i) No IP Provided... \n"
		exit 1
	fi

	# Handle Optional Args
	if [ -z $rtemp ]; then
		rtemp=1
	fi
	rtemp=$((${rtemp}-1 ))

	if [ -z $wpapi ]; then
		printf "${YELLOW}[o] No wpscan token provided...\n"
		printf "${YELLOW}[o] Get started for free at${NC} https://wpscan.com/\n"
		printf "${YELLOW}[o] Moving on...\n"
	else
		wpapi2="--api-token ${wpapi} "
	fi

	attack_ip=$(ip a s | grep $inf | grep inet | cut -f2 -d "t" | cut -f2 -d " " | cut -f1 -d "/")
	net_subnet=$(ip a s | grep $inf | grep inet | cut -f2 -d "t" | cut -f2 -d " " | cut -f2 -d "/")
}
troubleshooting

##############################
# 		  Setup FS 		     #
##############################

setup_fs () {
	loc=$(pwd)/${box_name}
	basic_fs=("${box_name}_report.md" "${box_name}_proofs.md")
	obsidian_fs=("appearance.json" "app.json" "core-plugins.json" "hotkeys.json" "workspace")
	folder_names=(".obsidian" "9-screenshots-storage" "1-recon" "2-enum" "3-xp" "4-priv-enum" "5-priv-xp" "6-misc-tools" "7-AD" "8-networking")
	sub_recon=("nmap")
	sub_enum=("dns" "web" "telnet" "ftp" "smb" "nfs" "rdp" "network" "cups" "sql" "mssql" "nosql" "smtp" "snmp" "pop3" "imap" )
	misc_tools=("autorecon" "nuclei" "photon_ip" "photon_host" "cewl")
	ad_actions=("Users" "Groups" "SPNs" "User_Perms" "Group_Perms" "Pwn_Paths" "TGTs" "Machines" "Kerberos" "LDAP" "MSRPC" "")
	rep_temps=(
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSCP-exam-report-template_OS_v2.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSCP-exam-report-template_whoisflynn_v3.2.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSWE-exam-report-template_xl-sec_v1.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSWP-exam-report-template_OS_v1.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSED-exam-report-template_OS_v1.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSEP-exam-report-template_ceso_v1.md"
	)

	printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Setting up Basic FS...\n"
	i_progress=$((i_progress+1))

	mkdir ${loc}
	for file in "${basic_fs[@]}"; do
		touch ${loc}/${file}
	done
	for folder_name in "${folder_names[@]}"; do
		mkdir ${loc}/${folder_name}
		touch ${loc}/${folder_name}/mini_report.md
	done
	for file in "${obsidian_fs[@]}"; do
		touch ${loc}/.obsidian/${file}
	done
	touch ${loc}/2-enum/box_users.md
	for dir in "${sub_recon[@]}"; do
		mkdir ${loc}/1-recon/${dir}
	done
	for service in "${sub_enum[@]}"; do
		mkdir ${loc}/2-enum/${service}
		touch ${loc}/2-enum/${service}/mini_report.md
	done
	for toolname in "${misc_tools[@]}"; do
		mkdir ${loc}/6-misc-tools/${toolname}
		touch ${loc}/6-misc-tools/${toolname}/mini_report.md
	done
	for ad_action in "${ad_actions[@]}"; do
			touch ${loc}/7-AD/${ad_action}.md
	done
	touch ${loc}/8-networking/mini_report.md

}
setup_fs

chmod -R 777 ${loc}

##############################
#  			Scans	     	#
##############################

port_scans () {
	n_scan=1
	n_scans=3

	printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Starting Basic Port Scans...\n"
	i_progress=$((i_progress+1))


	printf "\n${BLUE}[${n_scan}/${n_scans}]${NC} rustscan\n"
	if [[ "$(docker image ls | grep rustscan)" =~ "rustscan/rustscan"* ]]; then
        printf "${YELLOW}[o] rustscan image already exists...\n"
	else
        printf "${YELLOW}[o] rustscan image does not exist...\n"
        printf "${YELLOW}[o] Pulling rustscan image...\n"
        docker pull rustscan/rustscan
	fi
	printf "${YELLOW}[o] Running rustscan...\n"
	export init_ports=$(docker run rustscan/rustscan -ga $box_ip | cut -f2 -d "[" | cut -f1 -d "]")
	printf "\n${BLUE}${init_ports}\n"
	n_scan=$((n_scan+1))


	printf "\n${BLUE}[${n_scan}/${n_scans}]${NC} masscan - tcp\n"
	sudo masscan -p0-65535 $box_ip --max-rate 1000 -oG ${loc}/1-recon/masscan-tcp.md -e $inf
	declare -g tcp=$(cat ${loc}/1-recon/masscan-tcp.md | grep -oP '(?<=Ports: )\S*'| cut -f1 -d "/" | tr '\n' ',' | rev | cut -f2- -d "," | rev)
	printf "\n${BLUE}${tcp}\n"
	n_scan=$((n_scan+1))


	printf "\n${BLUE}[${n_scan}/${n_scans}]${NC} masscan - udp\n"
	sudo masscan -pU:0-65535 $box_ip --max-rate 1000 -oG ${loc}/1-recon/masscan-udp.md -e $inf
	declare -g udp=$(cat ${loc}/1-recon/masscan-udp.md | grep -oP '(?<=Ports: )\S*'| cut -f1 -d "/" | tr '\n' ',' | rev | cut -f2- -d "," | rev)
	printf "\n${BLUE}${udp}\n"
	n_scan=$((n_scan+1))


	declare -g all_ports="${tcp},${udp}"
	if [[ $all_ports == *, ]]; then
		all_ports=$(echo $all_ports | rev | cut -f2- -d "," | rev)
	fi

	printf "\n${BLUE}[${n_scan}/${n_scans}]${NC} Nmap - tcp\n"
	nmap_report="${loc}/1-recon/nmap/ip_tcp.md"
	nmap -Pn -vvv -p ${all_ports} -sC -sV -oN ${nmap_report} $box_ip
}
port_scans

##############################
#  		Reporting	     	 #
##############################

reoprting () {
	printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Setting up Reporting...\n"
	i_progress=$((i_progress+1))

	rtemp_name=$(echo ${rep_temps[${rtemp}]} | rev | cut -f1 -d "/" | rev | cut -f1 -d ".")
	printf "\n${BLUE}[Template] ${NC}${rtemp_name}\n"

	if [ ! -e /usr/share/pandoc/data/templates/eisvogel.latex ]; then
		wget https://github.com/Wandmalfarbe/pandoc-latex-template/releases/download/v2.0.0/Eisvogel-2.0.0.zip
		mkdir eisvogel && unzip Eisvogel-2.0.0.zip -d eisvogel
		sudo mv eisvogel/eisvogel.latex /usr/share/pandoc/data/templates/eisvogel.latex
		rm -rf Eisvogel-2.0.0.zip eisvogel
	fi

	echo -e "
#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'

PARENT_DIR=\"${loc}\"

printf \"\${YELLOW}[+] Generating report...\\n\"
pandoc \${PARENT_DIR}/${box_name}_report.md -o \${PARENT_DIR}/${box_name}_report.pdf \\
--from markdown+yaml_metadata_block+raw_html \\
--template eisvogel \\
--table-of-contents \\
--toc-depth 6 \\
--number-sections \\
--top-level-division=chapter \\
--highlight-style breezedark

printf \"\${GREEN}[+] Report generated\\n\"
printf \"\${YELLOW}[+] Cleaning FS...\\n\"

find \${PARENT_DIR} -empty -delete
rm -rf \${PARENT_DIR}/cmds2run/

printf \"\${GREEN}[+] FS has been cleaned of empty files and folders.\\n\"

	" > ${loc}/report_gen.sh

	if [[ $rtemp != 0 ]]; then
		wget ${rep_temps[${rtemp}]} -O ${loc}/${box_name}_report.md > /dev/null 2>&1	
	else

		echo -e "

---
title: \"${box_name} Report\"
author: [\"${USER}\"]
date: "$(date +\"%D\")"
subject: \"Markdown\"
keywords: [Markdown, Example]
subtitle: \"Box Report\"
lang: \"en\"
titlepage: true
titlepage-color: \"1E90FF\"
titlepage-text-color: \"FFFAFA\"
titlepage-rule-color: \"FFFAFA\"
titlepage-rule-height: 2
book: true
classoption: oneside
code-block-font-size: \scriptsize
---
# ${box_name} Report

# Methodologies

I utilized a widely adopted approach to performing penetration testing that is effective in testing how well the ${box_name} machine is secured.
Below is a breakout of how I was able to identify and exploit the variety of systems and includes all individual vulnerabilities found.

## Information Gathering

The information gathering portion of a penetration test focuses on identifying the scope of the penetration test.
During this penetration test, I was tasked with exploiting the ${box_name} machine.

The specific IP address was:

- ${box_ip}

## Penetration

The penetration testing portions of the assessment focus heavily on gaining access to a variety of systems.
During this penetration test, I was able to successfully gain access to the ${box_name} machine.

\\\newpage

### System IP: ${box_ip}

#### Service Enumeration

The service enumeration portion of a penetration test focuses on gathering information about what services are alive on a system or systems.
This is valuable for an attacker as it provides detailed information on potential attack vectors into a system.
Understanding what applications are running on the system gives an attacker needed information before performing the actual penetration test.
In some cases, some ports may not be listed.

Server IP Address | Ports Open
------------------|----------------------------------------
${box_ip}      | **TCP: ${tcp}** \ **UDP: ${udp}**

\\\newpage

**Nmap Scan Results:**

Service Scan:

\`\`\`bash

\`\`\`

Notable Output:

\`\`\`txt

\`\`\`

Vulnerability Scan:

\`\`\`bash

\`\`\`

Notable Output:

\`\`\`txt

\`\`\`


\\\newpage

#### Initial Access

**Vulnerability Exploited:**

**Vulnerability Explanation:**

Reference: *link*

**Vulnerability Fix:**

Reference: *link*

**Severity:** Critical

\\\newpage

**Exploit Code:**

Reference: *link*

\\\newpage

**Local.txt Proof Screenshot**

![x](screenshots-storage/image.png)

**Local.txt Contents**

\`\`\`txt
localtxt
\`\`\`

\\\newpage

#### Privilege Escalation

**Vulnerability Exploited:**

**Vulnerability Explanation:**

Reference: *link*


**Vulnerability Fix:**

Reference: *link*

**Severity:** Critical

\\\newpage

**Exploit Code:**

Reference: *link*

\\\newpage

**Proof Screenshot Here:**

![x](screenshots-storage/image.png)

**Proof.txt Contents:**

\`\`\`txt
prooftxt
\`\`\`

\\\newpage

## Maintaining Access

Maintaining access to a system is important to us as attackers, ensuring that we can get back into a system after it has been exploited is invaluable.
The maintaining access phase of the penetration test focuses on ensuring that once the focused attack has occurred (i.e. a buffer overflow), we have administrative access over the system again.
Many exploits may only be exploitable once and we may never be able to get back into a system after we have already performed the exploit.

## House Cleaning

The house cleaning portions of the assessment ensures that remnants of the penetration test are removed.
Often fragments of tools or user accounts are left on an organization's computer which can cause security issues down the road.
Ensuring that we are meticulous and no remnants of our penetration test are left over is important.

After collecting trophies from the ${box_name} machine was completed, I removed all user accounts, passwords, and malicious codes used during the penetration test.
Technicians should not have to remove any user accounts or services from the system.

\\\newpage

# Appendix - Additional Items

## Appendix - Proof and Local Contents:

IP (Hostname) | Local.txt Contents | Proof.txt Contents
--------------|--------------------|-------------------
${box_ip}   |  localtxt | prooftxt

\\\newpage

## Appendix - /etc/passwd contents

\`\`\`txt

\`\`\`

\\\newpage

## Appendix - /etc/shadow contents

\`\`\`txt

\`\`\`
" > ${loc}/${box_name}_report.md
fi
}
reoprting

##############################
# 		Make ENV Script      #
##############################

gen_env_script () {
	printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Setting up ENV Script...\n"
	i_progress=$((i_progress+1))
	
	ipurl=http://${box_ip}
	ipurl_https=https://${box_ip}

	if [ ! -z "$box_host" -a "$box_host"!=" " ]; then
		hosturl=http://${box_host}
		hosturl_https=https://${box_host}
		tld=$(echo ${box_host} | | rev | cut -f1 -d "." | rev)
	fi
	echo -e "
	#!/bin/bash
	export host=${box_host}
	export ip=${box_ip}
	export init_ports=
	export tcp=
	export udp=
	export all_ports=
	export tld=${tld}
	export web1=80
	export web2=443
	export web3=8080
	export rdp=5985
	export lport=4321
	export ipurl=${ipurl}
	export hosturl=${hosturl}
	export ipurl_https=${ipurl_https}
	export hosturl_https=${hosturl_https}
	export user1=\"bob\"
	export passw1=\"password\"
	export domain=\"domain-name\"
	export dc1=domain_controller_ip
	export dc1h=domain_controller_hostname
	export ps_scripts_path=\"/opt/server/ps_scripts/\"
	export exe_paths=\"/opt/server/exe/\"
	export attack_ip=$(ip a s | grep $inf | grep inet | cut -f2 -d "t" | cut -f2 -d " " | cut -f1 -d "/")
	export net_subnet=$(ip a s | grep $inf | grep inet | cut -f2 -d "t" | cut -f2 -d " " | cut -f2 -d "/")
	export wpscan_token=${wpapi}
	" > ${loc}/box_vars.sh

	sed -i "s+init_ports=+init_ports=${init_ports}+gi" ${loc}/box_vars.sh
	sed -i "s+tcp=+tcp=${tcp}+gi" ${loc}/box_vars.sh
	sed -i "s+udp=+udp=${udp}+gi" ${loc}/box_vars.sh
	sed -i "s+all_ports=+all_ports=${all_ports}+gi" ${loc}/box_vars.sh

	chmod -R 777 ${loc}
	chown $USER -R ${loc}
}
gen_env_script


##############################
# 		Gen Commands         #
##############################

script_loc2=$(find / -type f -name "2-pwnbox_gen_commands.sh" 2>/dev/null | tr "\n" "," | cut -f1 -d ",")
if [ -z "$script_loc2" ]; then
  printf "${YELLOW}[-]${NC} Gen Commands Scripts not found... \n"
  printf "${YELLOW}[-]${NC} Attempting to download pwnbox... \n"
  git clone https://github.com/gndpwnd/pwnbox.git
  script_loc2=$(find / -type f -name "2-pwnbox_gen_commands.sh" 2>/dev/null | tr "\n" "," | cut -f1 -d ",")
fi

printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Generating Commands...\n"
i_progress=$((i_progress+1))

if [ ! -z "$box_host" -a "$box_host"!=" " ]; then
	sudo bash ${script_loc2} -d ${inf} -o ${loc} -i ${box_ip} -n ${box_host}
else
	sudo bash ${script_loc2} -d ${inf} -o ${loc} -i ${box_ip}
fi

##############################
#  		Wrapping UP    	 	 #
##############################

wrap_up () {
	printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Wrapping up..."
	i_progress=$((i_progress+1))
	printf "${GREEN}Next Steps:${NC}\n"
	echo -e "

	1. Set up ENV variables with this script:  

		${loc}/box_vars.sh 

	2. Make sue you have a period before the command like so: 

		. ./box_vars.sh

	3. You will need to setup ENV in every new terminal you open...

	4. You can now open ${loc} in your favourite markdown editor.

	5. Happy pwning!
	"
	printf "\n${GREEN}[+]${NC} Done!\n"
}
wrap_up