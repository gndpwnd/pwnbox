#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

unset GREP_OPTIONS

inf= # network interface
loc= # location of where all the files from this script will be put
box_ip= # the IP of the target box
box_host= # the hostname of the target box with domain extension for DNS stuff

PWNBOX_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # the directory of where the script is being run, reference to copy notes from

usage() {
	echo -e "
	${NC}usage: pwnbox -d DEVICE -n NAME -i IP -n HOSTNAME -r TEMPLATE -w TOKEN

	OPTIONS:

	-h 			 	show this menu

	-d DEVICE  		network interface of target network
	
	-n NAME   		target box name (does not need to = HOST)
	
	-i IP     		ip of the target box

	-n HOSTNAME   	(optional) hostname of the target box
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
      inf=$OPTARG # Network Interface (e.g. eth0, tun0...)
      ;;
    o)
      box_name=$OPTARG # preferrably hostname of the box with a .tld (e.g. publisher.thm)
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
	elif [ -z ${box_ip} ]; then
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


setup_fs () {
	loc=$(pwd)/${box_name}
	basic_fs=("${box_name}_report.md" "${box_name}_proofs.md")
	folder_names=("1-recon" "2-enum" "3-xp" "4-privesc" "5-misc-tools" "6-ad" "7-networking" "8-screenshots")
	sub_recon=("nmap")
	sub_enum=("web" "ftp" "smtp" "snmp" "smb" "nfs" "dns")
	sub_misc_tools=("autorecon" "nuclei" "photon_ip" "photon_host" "cewl")
	ad_actions=("Accounts" "Groups" "Services" "Account_Perms" "Group_Perms" "Pwn_Paths" "Machines" "Shares" "Kerberos" "Certs")
	rep_temps=(
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSCP-exam-report-template_OS_v2.md"
		"https://raw.githubusercontent.cosm/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSCP-exam-report-template_whoisflynn_v3.2.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSWE-exam-report-template_xl-sec_v1.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSWP-exam-report-template_OS_v1.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSED-exam-report-template_OS_v1.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSEP-exam-report-template_ceso_v1.md"
	)

	printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Setting up Basic FS...\n"
	i_progress=$((i_progress+1))

	mkdir ${loc}

	# create basic file and folder structure
	for file in "${basic_fs[@]}"; do
		touch ${loc}/${file}
	done
	for folder_name in "${folder_names[@]}"; do
		mkdir ${loc}/${folder_name}
		touch ${loc}/${folder_name}/${folder_name}_mini_report.md
	done


	# create subfolders and files for tools and services that are used often because the folders will likely be made anyway
	# also enhance notetaking with mini report files that act as a place to dump relevant information
	for dir in "${sub_recon[@]}"; do
		mkdir ${loc}/${folder_names[0]}/${dir}
		touch ${loc}/${folder_names[0]}/${dir}/mini_report.md
	done
	for service in "${sub_enum[@]}"; do
		mkdir ${loc}/${folder_names[1]}/${service}
		touch ${loc}/${folder_names[1]}/${service}/mini_report.md
	done
	for toolname in "${misc_tools[@]}"; do
		mkdir ${loc}/${folder_names[4]}/${toolname}
		touch ${loc}/${folder_names[4]}/${toolname}/mini_report.md
	done
	for ad_action in "${ad_actions[@]}"; do
			touch ${loc}/${folder_names[5]}/${ad_action}.md
	done


	# get basic scripts for exploiting low hanging fruit
	xpURLs=(
		"https://raw.githubusercontent.com/Arrexel/phpbash/refs/heads/master/phpbash.php"
		)
	for url in "${urls[privURLs]}"; do
	    echo "WGET XP $url..."
	    
	    # Attempt to download the file
	    if ! wget -O "${loc}/${folder_names[2]}/$(basename "$url")" "$url";; then
	        # If wget fails, print a warning message
	        echo "Warning: Failed to download $url"
	    fi
	done


	# get basic privesc scripts for linux and windows, if not available, then links are provided in privesc notes
	privURLs=(
		"https://github.com/peass-ng/PEASS-ng/releases/download/20241011-f83883c6/linpeas.sh"
		"https://github.com/peass-ng/PEASS-ng/releases/download/20241011-f83883c6/linpeas_small.sh"
		"https://github.com/peass-ng/PEASS-ng/releases/download/20241011-f83883c6/winPEAS.bat"
		"https://raw.githubusercontent.com/rebootuser/LinEnum/refs/heads/master/LinEnum.sh"
		)


	for url in "${urls[privURLs]}"; do
	    echo "WGET PRIVESC $url..."
	    
	    # Attempt to download the file
	    if ! wget -O "${loc}/${folder_names[3]}/$(basename "$url")" "$url";; then
	        # If wget fails, print a warning message
	        echo "Warning: Failed to download $url"
	    fi
	done


	# generate ssh keys to be used in the future (add to authorized keys on target machine)
	echo "${loc}/${folder_names[3]}/user_rsa_persis" | ssh-keygen -t rsa -b 4096 -C "your_email@example.com"; chmod 600 ${loc}/${folder_names[3]}/user_rsa_persis; 
	echo "${loc}/${folder_names[3]}/root_rsa_persis" | ssh-keygen -t rsa -b 4096 -C "your_email@example.com"; chmod 600 ${loc}/${folder_names[3]}/root_rsa_persis; 
	# add public ssh keys to privesc/persis report
	echo -e "
### New Usable SSH Pub Keys

> add to ~/.ssh/authorized_keys

User
\'\'\'
" >> ${loc}/${folder_names[3]}/mini_report.md
	
	cat ${loc}/${folder_names[3]}/user_rsa_persis.pub | tee -a ${loc}/${folder_names[3]}/mini_report.md
	
	echo -e "
\'\'\'

Root
\'\'\'
" >> ${loc}/${folder_names[3]}/mini_report.md
	
	cat ${loc}/${folder_names[3]}/root_rsa_persis.pub | tee -a 

echo -e "
\'\'\'
" >> ${loc}/${folder_names[3]}/mini_report.md

printf "\n${GREEN}[+]${NC} fs_setup complete..."
}
setup_fs


copyNotes() {
  printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Copying Notes..."
  cp -r ${PWNBOX_SCRIPT_DIR}/Generated_Commands/ ${loc}/
  printf "\n${GREEN}[+]${NC} Notes Copied..."
}

printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Searching for wordlists..."
seclist_dir=$(find / -type d -name "SecLists" 2>/dev/null | tr "\n" "," | cut -f1 -d ",")
if [ -z "$seclist_dir" ]; then
  printf "${YELLOW}[-]${NC} SecLists directory not found... \n"
  printf "${YELLOW}[-]${NC} Attempting to download SecLists... \n"
  git clone https://github.com/danielmiessler/SecLists.git
  seclist_dir=$(find / -type d -name "SecLists" 2>/dev/null | tr "\n" "," | cut -f1 -d ",")
fi

domain_list="${seclist_dir}/DNS/subdomains-top1000000.txt"
directory_list1="/usr/share/wordlists/dirb/big.txt"
directory_list2="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
user_list="${seclist_dir}/Usernames/xato-net-10-million-usernames.txt"
pass_list="${seclist_dir}/Passwords/xato-net-10-million-passwords-1000000.txt"

imp_dirs=$(find / -type d -name 'impacket' -print 2>/dev/null | grep 'impacket')
if [ -z "$imp_dirs" ]; then
  printf "${YELLOW}[-]${NC} Impacket directory not found... \n"
  printf "${YELLOW}[-]${NC} Attempting to download Impacket... \n"
  git clone https://github.com/SecureAuthCorp/impacket.git
  imp_dirs=$(find / -type d -name 'impacket' -print 2>/dev/null | grep 'impacket')
fi
imp_dir=$(echo $imp_dirs | tr '\n' ' '| cut -f1 -d ' ')
imp_dir="${imp_dir}/examples"
printf "\n${GREEN}[+]${NC} Search for wordlists complete..."

printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Formatting notes..."
formatNotes() {

  declare -A replacements=(
      ["\${inf}"]=${inf}
      ["\${box_name}"]=${box_name}
      ["\${box_ip}"]=${box_ip}
      ["\${box_host}"]=${box_host}
      ["\${rtemp}"]=${rtemp}
      ["\${wpapi}"]=${wpapi}
      ["\${imp_dir}"]=${imp_dir}
      ["\${directory_list1}"]=${directory_list1}
      ["\${directory_list2}"]=${directory_list2}
      ["\${user_list}"]=${user_list}
      ["\${pass_list}"]=${pass_list}
      ["\${loc}/\${folder_names[0]}"]="${loc}/${folder_names[0]}"
      ["\${loc}/\${folder_names[1]}"]="${loc}/${folder_names[1]}"
      ["\${loc}/\${folder_names[2]}"]="${loc}/${folder_names[2]}"
      ["\${loc}/\${folder_names[3]}"]="${loc}/${folder_names[3]}"
      ["\${loc}/\${folder_names[4]}"]="${loc}/${folder_names[4]}"
      ["\${loc}/\${folder_names[5]}"]="${loc}/${folder_names[5]}"
      ["\${loc}/\${folder_names[6]}"]="${loc}/${folder_names[6]}"
      ["\${loc}/\${folder_names[7]}"]="${loc}/${folder_names[7]}"
      #["\${}"]=${}
      # Add more pairs as needed
  )

  # Function to replace strings in a file
  replace_in_file() {
      local file=$1
      for search in "${!replacements[@]}"; do
          sed -i "s/$search/${replacements[$search]}/g" "$file"
      done
  }

  # Find and process all markdown files
  find . -type f -name "*.md" | while read -r file; do
      replace_in_file "$file"
  done

  echo "Notes formatted"
}

printf "\n${GREEN}[+]${NC} Notes formatted..."
printf "\n${GREEN}DONE!!!\n"