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
rtemp=
wpapi=

i_progress=1
t_progress=6

PWNBOX_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # the directory of where the script is being run, reference to copy notes from

usage() {
	echo -e "
	${NC}usage: $0 -d DEVICE -n NAME -i IP -n HOSTNAME -r TEMPLATE -w TOKEN

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
	#if (( $EUID != 0 )); then
	#	printf "${RED}[x] sudo privileges not detected!!!\n"
	#	exit 1
	#fi

	# If Required Args are empty

	if [ -z ${inf} ]; then
		printf "${RED}[x] (-d) No Network Interface Provided!!!\n"
		exit 1
	elif [ -z ${box_name} ]; then
		printf "${RED}[x] (-o) No Name Provided!!! \n"
		exit 1
	elif [ -z ${box_ip} ]; then
		printf "${RED}[x] (-i) No IP Provided... \n"
		exit 1
  elif [ -z ${box_host} ]; then
		printf "${RED}[x] (-n) No hostname provided!!! At least give box name with a '.tld'. You can change all the scripts later with Generated_Commands/change_hostname.sh\n"
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


loc=$(pwd)/${box_name}
basic_fs=("${box_name}_report.md" "${box_name}_proofs.md")
folder_names=("1-recon" "2-enum" "3-xp" "4-privesc" "5-misc-tools" "6-ad" "7-networking" "8-screenshots")
sub_recon=("nmap")
sub_enum=("web" "ftp" "smtp" "snmp" "smb" "nfs" "dns")
sub_misc_tools=("autorecon" "nuclei" "photon_ip" "photon_host" "cewl")
ad_actions=("Accounts" "Groups" "Services" "Account_Perms" "Group_Perms" "Pwn_Paths" "Machines" "Shares" "Kerberos" "Certs")
rep_temps=(
		"pwnbox default"
    "https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSCP-exam-report-template_OS_v2.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSCP-exam-report-template_whoisflynn_v3.2.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSWE-exam-report-template_xl-sec_v1.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSWP-exam-report-template_OS_v1.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSED-exam-report-template_OS_v1.md"
		"https://raw.githubusercontent.com/noraj/OSCP-Exam-Report-Template-Markdown/master/src/OSEP-exam-report-template_ceso_v1.md"
	)


printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Setting up Basic FS...\n"
setup_fs () {
    i_progress=$((i_progress+1))

    mkdir -p ${loc}

    # Create basic file and folder structure
    for file in "${basic_fs[@]}"; do
        touch ${loc}/${file}
    done
    for folder_name in "${folder_names[@]}"; do
        mkdir -p ${loc}/${folder_name}
        touch ${loc}/${folder_name}/${folder_name}_mini_report.md
    done

    # Create subfolders and files for tools and services
    for dir in "${sub_recon[@]}"; do
        mkdir -p ${loc}/${folder_names[0]}/${dir}
        touch ${loc}/${folder_names[0]}/${dir}/mini_report.md
    done
    for service in "${sub_enum[@]}"; do
        mkdir -p ${loc}/${folder_names[1]}/${service}
        touch ${loc}/${folder_names[1]}/${service}/mini_report.md
    done
    for toolname in "${sub_misc_tools[@]}"; do
        mkdir -p ${loc}/${folder_names[4]}/${toolname}
        touch ${loc}/${folder_names[4]}/${toolname}/mini_report.md
    done
    for ad_action in "${ad_actions[@]}"; do
        touch ${loc}/${folder_names[5]}/${ad_action}.md
    done
}
setup_fs
printf "\n${GREEN}[+]${NC} fs organization complete...\n"


printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Copying Notes..."
i_progress=$((i_progress+1))
copyNotes() {
  cp -r ${PWNBOX_SCRIPT_DIR}/Generated_Commands/ ${loc}/
}
copyNotes
printf "\n${GREEN}[+]${NC} Notes Copied..."


printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Searching for wordlists..."
i_progress=$((i_progress+1))
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



printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Setting up reporting...\n"
i_progress=$((i_progress+1))
reporting() {

	rtemp_name=$(echo ${rep_temps[${rtemp}]} | rev | cut -f1 -d "/" | rev | cut -f1 -d ".")
	printf "\n${BLUE}[Template] ${NC}${rtemp_name}\n"

  if rtemp=0; then
    mv ${loc}/Generated_Commands/1\ -\ Reporting/report_template_basic.md ${loc}/${box_name}_report.md
  fi

	#if [ ! -e /usr/share/pandoc/data/templates/eisvogel.latex ]; then
	#	sudo cp ${loc}/Generated_Commands/1\ -\ Reporting/eisvogel.latex /usr/share/pandoc/data/templates/eisvogel.latex
	#fi
}
reporting
printf "\n${GREEN}[+]${NC} Reporting Setup\n"


printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Formatting notes...\n"
i_progress=$((i_progress+1))
formatNotes() {

  # Dictionary for search-and-replace strings
  declare -A replacements=(
      ["\${inf}"]="${inf}"
      ["\${box_name}"]="${box_name}"
      ["\${box_ip}"]="${box_ip}"
      ["\${box_host}"]="${box_host}"
      ["\${rtemp}"]="${rtemp}"
      ["\${wpapi}"]="${wpapi}"
      ["\${imp_dir}"]="${imp_dir}"
      ["\${directory_list1}"]="${directory_list1}"
      ["\${directory_list2}"]="${directory_list2}"
      ["\${user_list}"]="${user_list}"
      ["\${pass_list}"]="${pass_list}"
      ["\${loc}"]="${loc}"
      # Add more pairs as needed
  )

  # Function to replace strings in a file
  replace_in_file() {
      local file=$1
      for search in "${!replacements[@]}"; do
          # Escape replacement value to safely handle special characters
          replacement=$(printf '%s' "${replacements[$search]}" | sed 's/[&/\]/\\&/g')
          # Use | as a delimiter to avoid conflicts with /
          sed -i "s|$search|$replacement|g" "$file"
      done
  }

  # Find and process all markdown files
  find . -type f -name "*.md" | while read -r file; do
      replace_in_file "$file"
  done
  # Find and process all bash files (this is why external scripts are downloaded later)
  find . -type f -name "*.sh" | while read -r file; do
      replace_in_file "$file"
  done

  echo "Notes formatted"
}
formatNotes
printf "\n${GREEN}[+]${NC} Notes formatted..."


printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Grabbing some scripts...\n"
lowhangfruit(){
    # Get basic scripts for exploiting low-hanging fruit
    xpURLs=(
        "https://raw.githubusercontent.com/Arrexel/phpbash/refs/heads/master/phpbash.php"
    )
    for url in "${xpURLs[@]}"; do  # Correctly reference xpURLs
        echo "WGET XP $url..."
        if ! wget -O ${loc}/${folder_names[2]}/$(basename "$url") "$url" ; then
            echo "Warning: Failed to download $url"
        fi
    done

    # Get basic privesc scripts for Linux and Windows
    privURLs=(
        "https://github.com/peass-ng/PEASS-ng/releases/download/20241011-f83883c6/linpeas.sh"
        "https://github.com/peass-ng/PEASS-ng/releases/download/20241011-f83883c6/linpeas_small.sh"
        "https://github.com/peass-ng/PEASS-ng/releases/download/20241011-f83883c6/winPEAS.bat"
        "https://raw.githubusercontent.com/rebootuser/LinEnum/refs/heads/master/LinEnum.sh"
    )

    for url in "${privURLs[@]}"; do  # Correctly reference privURLs
        echo "WGET PRIVESC $url..."
        if ! wget -O ${loc}/${folder_names[3]}/$(basename "$url") "$url" ; then
            echo "Warning: Failed to download $url"
        fi
    done

    # Generate SSH keys
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ${loc}/${folder_names[3]}/user_rsa_persis -N ""
    chmod 600 ${loc}/${folder_names[3]}/user_rsa_persis
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ${loc}/${folder_names[3]}/root_rsa_persis -N ""
    chmod 600 ${loc}/${folder_names[3]}/root_rsa_persis

    # Add public SSH keys to the mini report
    {
        echo -e "### New Usable SSH Pub Keys\n\n> add to ~/.ssh/authorized_keys\n\nUser\n\`\`\`"
        cat ${loc}/${folder_names[3]}/user_rsa_persis.pub
        echo -e "\n\`\`\`\n\nRoot\n\`\`\`"
        cat ${loc}/${folder_names[3]}/root_rsa_persis.pub
        echo -e "\n\`\`\`"
    } >> ${loc}/${folder_names[3]}/mini_report.md
}
lowhangfruit
printf "\n${GREEN}[+]${NC} scripts grabbed..."

sed -i "s/BOXLOCATION/${loc}/g" ${loc}/Generated_Commands/1\ -\ Reporting/change_box_info.sh
printf "\nMake sure to run the following:\n\n     sudo echo \"${box_ip}        ${box_host}\" >> /etc/hosts"
chmod -R 777 ${loc}
printf "\n${GREEN}DONE!!!\n"