#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
CYAN='\033[0;36m'

unset GREP_OPTIONS

inf= # network interface
loc= # location of where all the files from this script will be put
box_ip= # the IP of the target box
ipurl= # web address if website
box_host= # the hostname of the target box with domain extension for DNS stuff
hosturl= # web address if website
web1=80 # default http port

i_progress=1
t_progress=6

script_date=$(date +"%D")
PWNBOX_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # the directory of where the script is being run, reference to copy notes from

usage() {
	echo -e "
	${NC}usage: $0 -d DEVICE -n NAME -i IP -n HOSTNAME

	OPTIONS:

	-h 			 	    show this menu

	-d DEVICE  		network interface of target network
	
	-n NAME   		target box name (does not need to = HOSTNAME)
	
	-i IP     		ip of the target box

	-n HOSTNAME   hostname of the target box
	"
}

while getopts “:hd:t:o:i:n:w:” OPTION
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
      ipurl="http://${box_ip}"
      ;;
    n)
      box_host=$OPTARG
      hosturl="http://${box_host}"
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

	# If Required Args are empty

	if [ -z ${inf} ]; then
		printf "${RED}[x] (-d) No Network Interface Provided!!!\n"
		exit 1
	elif [ -z ${box_name} ]; then
		printf "${RED}[x] (-o) No Box Name Provided!!! \n"
		exit 1
	elif [ -z ${box_ip} ]; then
		printf "${RED}[x] (-i) No IP Provided... \n"
		exit 1
  elif [ -z ${box_host} ]; then
		printf "${RED}[x] (-n) No Hostname provided!!! \nAt least give box name with a '.tld'. You can change all the scripts later with change_box_info.sh\n"
		exit 1
	fi

	attack_ip=$(ip a s | grep $inf | grep inet | cut -f2 -d "t" | cut -f2 -d " " | cut -f1 -d "/")
	net_subnet=$(ip a s | grep $inf | grep inet | cut -f2 -d "t" | cut -f2 -d " " | cut -f2 -d "/")
}
troubleshooting



export loc=$(pwd)/${box_name}
folder_names=("1-recon" "2-enum" "3-xp" "4-privesc" "5-misc-tools" "6-ad" "7-networking" "8-screenshots")
sub_recon=("nmap")
sub_enum=("web" "ftp" "sql" "smtp" "snmp" "smb" "nfs" "dns" "pop3" "imap" "OSINT")
sub_misc_tools=("autorecon" "nuclei" "photon_ip" "photon_host" "cewl")
ad_actions=("Accounts" "Groups" "Services" "Account_Perms" "Group_Perms" "Pwn_Paths" "Machines" "Shares" "Kerberos" "Certs" "Pivot" "Privesc")

printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Setting up Basic FS..."
i_progress=$((i_progress+1))
setup_fs () {
    mkdir -p ${loc}
    for folder_name in "${folder_names[@]}"; do
        mkdir -p ${loc}/${folder_name}
        touch ${loc}/${folder_name}/${folder_name}_mini_report.md
    done
    # Create subfolders and files for tools and services
    for recon_tool in "${sub_recon[@]}"; do
        mkdir -p ${loc}/${folder_names[0]}/${recon_tool}
        touch ${loc}/${folder_names[0]}/${recon_tool}/${recon_tool}_mini_report.md
    done
    for enum_service in "${sub_enum[@]}"; do
        mkdir -p ${loc}/${folder_names[1]}/${enum_service}
        touch ${loc}/${folder_names[1]}/${enum_service}/${enum_service}_mini_report.md
    done
    for misc_tool in "${sub_misc_tools[@]}"; do
        mkdir -p ${loc}/${folder_names[4]}/${misc_tool}
        touch ${loc}/${folder_names[4]}/${misc_tool}/${misc_tool}_mini_report.md
    done
    for ad_action in "${ad_actions[@]}"; do
        touch ${loc}/${folder_names[5]}/AD_${ad_action}_mini_report.md
    done
}
setup_fs
printf "\n${GREEN}[+]${NC} fs organization complete..."



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
  printf "${YELLOW}[-]${NC} Attempting to download SecLists to ~/Downloads/ ... \n"
  git clone https://github.com/danielmiessler/SecLists.git ~/Downloads/
  seclist_dir=$(find / -type d -name "SecLists" 2>/dev/null | tr "\n" "," | cut -f1 -d ",")
fi

directory_list1="/usr/share/wordlists/dirb/big.txt"
directory_list2="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
domain_list="${seclist_dir}/DNS/subdomains-top1000000.txt"
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



printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Setting up reporting..."
i_progress=$((i_progress+1))
reporting() {

  # Replace variables in helpful scripts and markdown files with values of variables found in this script
  for file in ${loc}/Generated_Commands/1\ -\ Reporting/*; do
    if [[ -f "$file" ]]; then
        #echo "Processing file: $file"

        # Perform sed replacements
        sed -i "s|BOXLOCATION|${loc}|g" "$file"
        sed -i "s|PARENT_DIR|${loc}|g" "$file"
        sed -i "s|BOXNAME|${box_name}|g" "$file"
        sed -i "s|SCREENSHOTSDIR|${folder_names[7]}|g" "$file"
        sed -i "s|REPORTAUTHOR|${USER}|g" "$file"
        sed -i "s|REPORTDATE|${script_date}|g" "$file"

        # Check if file is *.md
        if [[ "$file" != *.md ]]; then
            # if its a .sh file, just move it to the main dir
            mv "$file" "$loc/"
        fi
    fi
  done

  mv ${loc}/Generated_Commands/1\ -\ Reporting/box_dump_report.md ${loc}/${box_name}_dump_report.md
  echo -e "## USER\n\n\`\`\`\n\`\`\`\n\n\n## ROOT\n\n\`\`\`\n\`\`\`" >> ${loc}/${box_name}_proofs.md 
  mv ${loc}/Generated_Commands/1\ -\ Reporting/report_template.md ${loc}/${box_name}_report.md

}
reporting
printf "\n${GREEN}[+]${NC} Reporting Setup"



printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Formatting notes..."
i_progress=$((i_progress+1))
formatNotes() {

  # Dictionary for search-and-replace strings
  declare -A replacements=(
      ["\${inf}"]="${inf}"
      ["\${box_name}"]="${box_name}"
      ["\${box_ip}"]="${box_ip}"
      ["\${ipurl}"]="${ipurl}"
      ["\${box_host}"]="${box_host}"
      ["\${hosturl}"]="${hosturl}"
      ["\${web1}"]="${web1}"
      ["\${rtemp}"]="${rtemp}"
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
  find ${loc} -type f -name "*.md" | while read -r file; do
      replace_in_file "$file"
  done
  # Find and process all bash files (this is why external scripts are downloaded later)
  find ${loc} -type f -name "*.sh" | while read -r file; do
      replace_in_file "$file"
  done
}
formatNotes
printf "\n${GREEN}[+]${NC} Notes formatted..."



printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Generating useful files...\n"
usefulFiles(){

    # Generate SSH keys
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ${loc}/${folder_names[3]}/user_persis.rsa -N "" > /dev/null 2>&1
    chmod 600 ${loc}/${folder_names[3]}/user_persis.rsa
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ${loc}/${folder_names[3]}/root_persis.rsa -N "" > /dev/null 2>&1
    chmod 600 ${loc}/${folder_names[3]}/root_persis.rsa

    # Add public SSH keys to the mini report
    {
        user_rsa=$(cat ${loc}/${folder_names[3]}/user_persis.rsa.pub)
        root_rsa=$(cat ${loc}/${folder_names[3]}/root_persis.rsa.pub)
        echo -e "### New Usable SSH Pub Keys\n\n> add to ~/.ssh/authorized_keys\n\n"
        echo -e "User\n\`\`\`\necho -e \"${user_rsa}\" >> /home/user/.ssh/authorized_keys"
        echo -e "\n\`\`\`\n\nRoot\n\`\`\`\necho \"${root_rsa}\" >> /root/.ssh/authorized_keys\n\`\`\`"

    } >> ${loc}/${folder_names[3]}/${folder_names[3]}_mini_report.md
}
usefulFiles
printf "\n${GREEN}[+]${NC} Generated useful files..."

# update file permissions
find "$loc" -type f -exec chmod 664 {} \;
find "$loc" -type d -exec chmod 775 {} \;
find "$loc" -type f -name "*.sh" -exec chmod 777 {} \;

# add box to /etc/hosts
printf "\n${YELLOW}[-]${NC}Make sure to run the following:\n${CYAN}sudo echo \"${box_ip}        ${box_host}\" >> /etc/hosts${NC}"

# check if pandoc template for report exists on system where it should be
if [ ! -e /usr/share/pandoc/data/templates/eisvogel.latex ]; then
 printf "\n${YELLOW}[-]${NC}Run this as well:\n${CYAN}sudo cp ${loc}/Generated_Commands/1\ -\ Reporting/eisvogel_2.5.0.latex /usr/share/pandoc/data/templates/eisvogel.latex; sudo chmod 777 /usr/share/pandoc/data/templates/${NC}"
fi

# make sure you can quickly access lots of useful scripts for uploading/running on a target machine
printf "\n${YELLOW}[-]${NC}Make sure your malicious files are ready to serve:\n${CYAN}${loc}/get_scripts.sh\n${NC}"

printf "\n${GREEN}DONE!!!\n"