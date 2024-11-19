#!/bin/bash

# ArchLinux: pacman -S p7zip haskell-pandoc texlive-basic texlive-fontsextra texlive-fontsrecommended texlive-latexextra
# openSUSE: zypper in texlive-scheme-medium pandoc p7zip-full
# Ubuntu: apt install texlive-latex-recommended texlive-fonts-extra texlive-latex-extra pandoc p7zip-full

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'

PARENT_DIR="BOXLOCATION"
box_name="BOXNAME"
screenshots_dir="SCREENSHOTSDIR"

printf "${YELLOW}[-] Generating report...\n"

TEXINPUTS="${PARENT_DIR}/Generated_Commands/1\ -\ Reporting/templates/"

pandoc ${PARENT_DIR}/${box_name}_report.md \
-o ${PARENT_DIR}/${box_name}_report.pdf \
--from markdown+yaml_metadata_block+raw_html \
--template="eisvogel_2.5.0.tex" \
--table-of-contents \
--toc-depth 6 \
--number-sections \
--top-level-division=chapter \
--highlight-style breezedark \
--resource-path .:${screenshots_dir}

printf "${GREEN}[+] Report generated\n"

printf "${YELLOW}[-] Removing Empty Files and Folders FS...\n"

find ${PARENT_DIR} -empty -delete

printf "${GREEN}[+] Removed Empty Files and Folders...\n"

# files that are downloaded every time gen_notes is run
bloat_files=(
    "linpeas.sh"
    "LinEnum.sh"
    "eisvogel_2.5.0.tex"
    "phpbash.php"
    "winPEAS.bat"
    "linpeas_small.sh"
)
printf "${YELLOW}[-] Removing Bloat Files...\n"

for filename in "${bloat_files[@]}"; do
    # Find and delete the file(s) matching the current filename
    find . -type f -name "$filename" -exec rm -f {} \;
    printf "       ${BLUE}Deleted all instances of ${CYAN}${filename}\n"
done

printf "${GREEN}[+] Removed Bloat Files\n"


printf "\n\n   ${GREEN}DONE !!!   \n"