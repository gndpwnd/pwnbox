#!/bin/bash
websites=(
"https://www.osboxes.org/",
# Maps
"https://github.com/C0nd4/OSCP-Priv-Esc/raw/main/images/Linux%20Privilege%20Escalation.png",
"https://github.com/C0nd4/OSCP-Priv-Esc/raw/main/images/Windows%20Privilege%20Escalation.png",
"https://github.com/hxhBrofessor/PrivEsc-MindMap/raw/main/Linux-Privesc.JPG",
"https://github.com/hxhBrofessor/PrivEsc-MindMap/raw/main/windows-mindMap.JPG"
)

for site in "${websites[@]}"; do
	xdg-open ${site}
done
