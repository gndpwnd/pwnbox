#!/bin/bash
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'

PARENT_DIR="BOXLOCATION"

printf "${YELLOW}[-] Removing Empty Files and Folders FS...\n"

find ${PARENT_DIR} -empty -delete
find ${PARENT_DIR} -empty -delete # once more just to confirm

# Don't need my notes across every single excersise, just the report and relevant files
rm -rf ${PARENT_DIR}/Generated_Commands/

printf "${GREEN}[+] Removed Empty Files and Folders...\n"

# files that are copied or downloaded every time gen_notes is run
bloat_files=(
    "linpeas.sh"
    "LinEnum.sh"
    "eisvogel_2.5.0.tex"
    "phpbash.php"
    "winPEAS.bat"
    "linpeas_small.sh"

    "change_box_info.sh"
    "report_gen.sh"
    "sensitive_scan.sh"
    "cleanup.sh"
)
printf "${YELLOW}[-] Removing Bloat Files...\n"

for filename in "${bloat_files[@]}"; do
    # Find and delete the file(s) matching the current filename
    find . -type f -name "$filename" -exec rm -f {} \;
    #printf "       ${BLUE}Deleted all instances of ${CYAN}${filename}\n"
done

printf "${GREEN}[+] Removed Bloat Files\n"


printf "\n\n   ${GREEN}DONE !!!   \n"