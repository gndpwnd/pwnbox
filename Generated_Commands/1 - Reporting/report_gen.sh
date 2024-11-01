#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'

PARENT_DIR="${loc}"

printf "${YELLOW}[+] Generating report...\n"
pandoc ${PARENT_DIR}/${box_name}_report.md --from-o ${PARENT_DIR}/${box_name}_report.pdf \
--from markdown \
--template="${PARENT_DIR}/Generated_Commands/1\ -\ Reporting/eisvogel_2.5.0.tex" \
--table-of-contents \
--toc-depth 6 \
--number-sections \
--top-level-division=chapter \
--highlight-style breezedark

printf "${GREEN}[+] Report generated\n"
printf "${YELLOW}[+] Cleaning FS...\n"

find ${PARENT_DIR} -empty -delete
rm -rf ${PARENT_DIR}/cmds2run/

printf "${GREEN}[+] FS has been cleaned of empty files and folders.\n"