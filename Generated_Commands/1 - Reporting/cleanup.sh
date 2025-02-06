#!/bin/bash
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'

PARENT_DIR="BOXLOCATION"

# Don't need my notes across every single excersise, just the report and relevant files
printf "${YELLOW}[-] Generated Commands...\n"
rm -rf ${PARENT_DIR}/Generated_Commands/
printf "${GREEN}[+] Removed Generated Commands\n"

printf "${YELLOW}[-] Notes DB...\n"
rm -rf ${PARENT_DIR}/9-notesdb/
printf "${GREEN}[+] Removed Notes DB\n"

# files that are copied or downloaded every time pwnbox is run
bloat_files=(
    "eisvogel_2.5.0.tex"
    "hydra.restore"
)
printf "${YELLOW}[-] Removing Bloat Files...\n"

for filename in "${bloat_files[@]}"; do
    # Find and delete the file(s) matching the current filename
    find . -type f -name "$filename" -exec rm -f {} \;
    #printf "       ${BLUE}Deleted all instances of ${CYAN}${filename}\n"
done

# remove obsidian files
find . -type d -name ".obsidian" -exec rm -rf {} \;

printf "${GREEN}[+] Removed Bloat Files\n"

printf "${YELLOW}[-] Removing Empty Files and Folders FS...\n"

find ${PARENT_DIR} -empty -delete

printf "${GREEN}[+] Removed Empty Files and Folders...\n"


printf "\n\n   ${GREEN}DONE !!!   \n"