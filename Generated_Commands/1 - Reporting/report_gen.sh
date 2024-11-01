#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'

PARENT_DIR="${loc}"

printf "${YELLOW}[+] Generating report...\n"

TEXINPUTS="${PARENT_DIR}/Generated_Commands/1\ -\ Reporting/templates/"

pandoc ${PARENT_DIR}/${box_name}_report.md -o ${PARENT_DIR}/${box_name}_report.pdf \
--from markdown \
--template="eisvogel_2.5.0.tex" \
--table-of-contents \
--toc-depth 6 \
--number-sections \
--top-level-division=chapter \
--highlight-style breezedark

printf "${GREEN}[+] Report generated\n"
printf "${YELLOW}[+] Cleaning FS...\n"

find ${PARENT_DIR} -empty -delete

printf "${GREEN}[+] FS has been cleaned of empty files and folders.\n"