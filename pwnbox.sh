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
	
	-o NAME   		target box name (does not need to = HOSTNAME)
	
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
folder_names=("1-recon" "2-enum" "3-xp" "4-privesc" "5-misc-tools" "6-ad" "7-networking" "8-screenshots" "9-notesdb")
sub_recon=("nmap")
sub_enum=("web" "ftp" "ssh" "sql" "smtp" "snmp" "smb" "nfs" "dns" "pop3" "imap" "OSINT")
sub_misc_tools=("autorecon" "nuclei" "photon_ip" "photon_host" "cewl")
ad_actions=("Accounts" "Groups" "Services" "Account_Perms" "Group_Perms" "Pwn_Paths" "Machines" "Shares" "Kerberos" "Certs" "Pivot" "Privesc")

printf "${GREEN}[${i_progress}/${t_progress}]${NC} Setting up Basic FS..."
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
printf "\n${GREEN}[+]${NC} FS Setup Complete..."


printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Discovering Tool Locations...\n"
i_progress=$((i_progress+1))
toolLocations() {
  # Function to check and update shell configuration files with a variable
  update_shell_config() {
      local var_name="$1"
      local dir_path="$2"
      # Update .bashrc
      if [ -f ${HOME}/.bashrc ]; then
          if ! grep -q "^export $var_name=" ${HOME}/.bashrc; then
              echo "export $var_name=\"$dir_path\"" >> ${HOME}/.bashrc
              echo "Added $var_name to ${HOME}/.bashrc"
          fi
      fi

      # Update .zshrc
      if [ -f ${HOME}/.zshrc ]; then
          if ! grep -q "^export $var_name=" ${HOME}/.zshrc; then
              echo "export $var_name=\"$dir_path\"" >> ${HOME}/.zshrc
              echo "Added $var_name to ${HOME}/.zshrc"
          fi
      fi
  }

  # make a directory to store repositories if not located on system
  notesdb_dir="${HOME}/Downloads/PWNBOX_NOTESDB"
  if [[ ! -d "$notesdb_dir" ]]; then
        echo "Creating notes database directory: $notesdb_dir"
        mkdir -p "$notesdb_dir"
  fi

  # Check or set seclists_dir
  declare -g seclists_dir=${seclists_dir:-$(grep -oP '(?<=^export\sseclists_dir=").*(?=")' ${HOME}/.bashrc ${HOME}/.zshrc | head -n 1)}
  if [[ -z "$seclists_dir" ]]; then
      echo "Searching for SecLists directory..."
      seclists_dir=$(find / -type d -name "SecLists" 2>/dev/null | head -n 1)
      if [[ -z "$seclists_dir" ]]; then
          echo "SecLists directory not found. Cloning SecLists..."
          git clone https://github.com/danielmiessler/SecLists.git ${notesdb_dir}/SecLists
          seclists_dir=${notesdb_dir}/SecLists
      fi
      update_shell_config "seclists_dir" "$seclists_dir"
  fi

  # Check or set impacket_dir
  declare -g impacket_dir=${impacket_dir:-$(grep -oP '(?<=^export\simpacket_dir=").*(?=")' ${HOME}/.bashrc ${HOME}/.zshrc | head -n 1)}
  if [[ -z "$impacket_dir" ]]; then
      echo "Searching for Impacket directory..."
      impacket_dir=$(find / -type d -name "impacket" 2>/dev/null | head -n 1)
      if [[ -z "$impacket_dir" ]]; then
          echo "Impacket directory not found. Cloning Impacket..."
          git clone https://github.com/SecureAuthCorp/impacket.git ${notesdb_dir}/impacket
          impacket_dir=${notesdb_dir}/impacket/examples
      fi
      update_shell_config "impacket_dir" "$impacket_dir"
  fi

  # Check or set swisskeyrepo payloads_dir
  declare -g payloads_dir=${payloads_dir:-$(grep -oP '(?<=^export\spayloads_dir=").*(?=")' ${HOME}/.bashrc ${HOME}/.zshrc | head -n 1)}
  if [[ -z "$payloads_dir" ]]; then
      echo "Searching for PayloadsAllTheThings directory..."
      payloads_dir=$(find / -type d -name "PayloadsAllTheThings" 2>/dev/null | head -n 1)
      if [[ -z "$payloads_dir" ]]; then
          echo "PayloadsAllTheThings directory not found. Cloning PayloadsAllTheThings..."
          git clone https://github.com/swisskyrepo/PayloadsAllTheThings.git ${notesdb_dir}/PayloadsAllTheThings
          payloads_dir=${notesdb_dir}/PayloadsAllTheThings
      fi
      update_shell_config "payloads_dir" "$payloads_dir"
  fi

  declare -g gtfobins_dir=${gtfobins_dir:-$(grep -oP '(?<=^export\sgtfobins_dir=").*(?=")' ${HOME}/.bashrc ${HOME}/.zshrc | head -n 1)}
  if [[ -z "$gtfobins_dir" ]]; then
      echo "Searching for GTFOBins directory..."
      gtfobins_dir=$(find / -type d -name "GTFOBins.github.io" 2>/dev/null | head -n 1)
      if [[ -z "$gtfobins_dir" ]]; then
          echo "GTFOBins directory not found. Cloning GTFOBins repository..."
          git clone https://github.com/GTFOBins/GTFOBins.github.io.git ${notesdb_dir}/GTFOBins.github.io
          gtfobins_dir=${notesdb_dir}/GTFOBins.github.io
      fi
      update_shell_config "gtfobins_dir" "$gtfobins_dir"
  fi

  declare -g lolbas_dir=${lolbas_dir:-$(grep -oP '(?<=^export\slolbas_dir=").*(?=")' ${HOME}/.bashrc ${HOME}/.zshrc | head -n 1)}
  if [[ -z "$lolbas_dir" ]]; then
    echo "Searching for LOLBAS directory..."
    lolbas_dir=$(find / -type d -name "LOLBAS" 2>/dev/null | head -n 1)
    if [[ -z "$lolbas_dir" ]]; then
        echo "LOLBAS directory not found. Cloning LOLBAS repository..."
        git clone https://github.com/LOLBAS-Project/LOLBAS.git ${notesdb_dir}/LOLBAS
        lolbas_dir=${notesdb_dir}/LOLBAS
    fi
    update_shell_config "lolbas_dir" "$lolbas_dir"
  fi

  declare -g taoi_dir=${taoi_dir:-$(grep -oP '(?<=^export\staoi_dir=").*(?=")' ${HOME}/.bashrc ${HOME}/.zshrc | head -n 1)}
  if [[ -z "$taoi_dir" ]]; then
    echo "Searching for 740i directory..."
    taoi_dir=$(find / -type d -name "740i" 2>/dev/null | head -n 1)
    if [[ -z "$taoi_dir" ]]; then
        echo "740i Notes directory not found. Cloning 740i Notes repository..."
        git clone https://github.com/740i/pentest-notes.git ${notesdb_dir}/740i
        taoi_dir=${notesdb_dir}/740i
    fi
    update_shell_config "taoi_dir" "$taoi_dir"
  fi

  # Verbose output for the directories
  #echo "SecLists directory: $seclists_dir"
  #echo "Impacket directory: $impacket_dir"
  #echo "PayloadsAllThings directory: $payloads_dir"

  # Set the wordlist paths based on the SecLists directory
  export directory_list1="/usr/share/wordlists/dirb/big.txt"
  export directory_list2="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
  export domain_list="${seclists_dir}/DNS/subdomains-top1000000.txt"
  export user_list="${seclists_dir}/Usernames/xato-net-10-million-usernames.txt"
  export pass_list="${seclists_dir}/Passwords/xato-net-10-million-passwords-1000000.txt"
  export subdomain_list1="${seclists_dir}/Discovery/DNS/subdomains-top1million-5000.txt"
  export subdomain_list2="${seclists_dir}/Discovery/DNS/subdomains-top1million-110000.txt"

}
toolLocations
printf "${GREEN}[+]${NC} Tool Locations Complete..."

printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Copying Commands and Notes..."
i_progress=$((i_progress+1))
copyNotes() {
  cp -r ${PWNBOX_SCRIPT_DIR}/Generated_Commands/ ${loc}/

  cp -r ${payloads_dir} ${loc}/${folder_names[8]}
  cp -r ${gtfobins_dir} ${loc}/${folder_names[8]}
  cp -r ${lolbas_dir} ${loc}/${folder_names[8]}
  cp -r ${taoi_dir} ${loc}/${folder_names[8]}
}
copyNotes
printf "\n${GREEN}[+]${NC} Notes Copied..."

printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Setting Up Reporting..."
i_progress=$((i_progress+1))
reporting() {

  # Replace variables in helpful scripts and markdown files with values of variables found in this script
  for file in ${loc}/Generated_Commands/1\ -\ Reporting/*; do
    if [[ -f "$file" ]]; then
        #echo "Processing file: $file"

        # Perform sed replacements
        sed -i "s|BOXLOCATION|${loc}|g" "$file"
        sed -i "s|BOXNAME|${box_name}|g" "$file"
        sed -i "s|SCREENSHOTSDIR|${folder_names[7]}|g" "$file"
        sed -i "s|REPORTAUTHOR|${USER}|g" "$file"
        sed -i "s|REPORTDATE|${script_date}|g" "$file"

        # Check if file is *.md
        if [[ "$file" != *.md && "$file" != *.tex ]]; then
            # if its a .sh file, just move it to the main dir
            mv "$file" "$loc/"
        fi
    fi
  done

  mv ${loc}/Generated_Commands/1\ -\ Reporting/box_dump_report.md ${loc}/${box_name}_dump_report.md
  echo -e "## Enumerated\n\n\`\`\`\n\`\`\`\n\n\n## USER\n\n\`\`\`\n\`\`\`\n\n\n## ROOT\n\n\`\`\`\n\`\`\`" >> ${loc}/${box_name}_proofs.md 
  mv ${loc}/Generated_Commands/1\ -\ Reporting/report_template.md ${loc}/${box_name}_report.md

}
reporting
printf "\n${GREEN}[+]${NC} Reporting Setup"



printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Formatting Notes..."
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
      ["SUBDOMAIN_LIST1"]="${subdomain_list1}"
      ["SUBDOMAIN_LIST2"]="${subdomain_list2}"
      # Add more pairs as needed
  )

  # Function to replace strings in a file
  replace_in_file() {
      local file=$1
      for search in "${!replacements[@]}"; do
          # Escape replacement value to safely handle special characters
          replacement=$(printf '%s' "${replacements[$search]}" | sed 's+[&+\]+\\&+g')
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
printf "\n${GREEN}[+]${NC} Notes Formatted..."



printf "\n${GREEN}[${i_progress}/${t_progress}]${NC} Generating Useful Files...\n"
usefulFiles(){

    # Generate an SSH key for ssh persistence
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ${loc}/${folder_names[3]}/persis_rsa -N "" > /dev/null 2>&1
    chmod 600 ${loc}/${folder_names[3]}/persis_rsa

    # Add public SSH key to the mini report
    {
        persis_rsa=$(cat ${loc}/${folder_names[3]}/persis_rsa.pub)
        echo -e "### New Usable SSH Pub Key\n\n> add to ${HOME}/.ssh/authorized_keys\n\n"
        echo -e "User\n\`\`\`\necho -e \"${persis_rsa}\" >> /home/user/.ssh/authorized_keys"
        echo -e "\n\`\`\`\n\nRoot\n\`\`\`\necho -e \"${persis_rsa}\" >> /root/.ssh/authorized_keys\n\`\`\`"

    } >> ${loc}/${folder_names[3]}/${folder_names[3]}_mini_report.md
}
usefulFiles
printf "${GREEN}[+]${NC} Generated Useful Files...\n"

# update file permissions
find "$loc" -type f -exec chmod 664 {} \;
find "$loc" -type d -exec chmod 775 {} \;
find "$loc" -type f -name "*.sh" -exec chmod 777 {} \;

# add box to /etc/hosts
printf "\n${YELLOW}[-]${NC} Make sure to run the following:\n${CYAN}sudo sed -i \"1s/^/${box_ip}        ${box_host}\\\\n/\" /etc/hosts${NC}"



# check if pandoc template for report exists on system where it should be
if [ ! -e /usr/share/pandoc/data/templates/eisvogel.tex ]; then
 printf "\n${YELLOW}[-]${NC} Copy Latex Report Template:\n${CYAN}sudo cp ${loc}/Generated_Commands/1\ -\ Reporting/eisvogel_2.5.0.tex /usr/share/pandoc/data/templates/eisvogel.tex; sudo chmod 777 /usr/share/pandoc/data/templates/${NC}\n"
fi

# make sure you can quickly access lots of useful scripts for uploading/running on a target machine
#printf "\n\n${YELLOW}[-]${NC} Make sure your malicious files are ready to serve:\n${CYAN}${loc}/get_scripts.sh${NC}\n"

printf "\n\n${GREEN}DONE!!!\n"