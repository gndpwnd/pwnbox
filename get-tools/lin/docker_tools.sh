#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
tools=(
"byt3bl33d3r/crackmapexec",
"calebjstewart/pwncat",
"empireproject/empire",
"oscarakaelvis/evil-winrm",
"belane/bloodhound",
"rickdejager/stegseek",
"paradoxis/stegcracker",
"bannsec/stegoveritas",
"dominicbreuker/stego-toolkit",
"rustscan/rustscan",
"empireproject/empire",
"projectdiscovery/nuclei",
"projectdiscovery/subfinder",
"projectdiscovery/httpx",
"projectdiscovery/naabu",
"projectdiscovery/interactsh-client",
"wpscanteam/wpscan",
)

tool_aliases=(
"docker run -it --entrypoint=/bin/sh --name crackmapexec -v ~/.cme:/root/.cme byt3bl33d3r/crackmapexec",
"docker run -v \"./\":/work -t pwncat",
"export scripts_dir='/opt/server/ps_scripts/'; export exe_dir='/opt/server/exe/'; docker run --rm -ti --name evil-winrm -v \${scripts_dir}:/ps1_scripts -v \${exe_dir}:/exe_files -v \${pwd}:/data oscarakaelvis/evil-winrm",
"docker run -v \$(pwd)/data/:/data -it paradoxis/stegcracker",
"docker run --rm -it -v \$(pwd):/steg rickdejager/stegseek",
"sudo docker run -it --rm bannsec/stegoveritas",
"docker run -it --rm -v \$(pwd)/files_4_inspection:/files_4_inspection dominicbreuker/stego-toolkit /bin/bash",
"docker run -it --rm rustscan/rustscan:2.0.0",
"docker run -it -p 7474:7474 -e DISPLAY=unix\$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --device=/dev/dri:/dev/dri -v \$(pwd)/data:/data --name bloodhound belane/bloodhound"
"docker run projectdiscovery/nuclei",
"docker run projectdiscovery/subfinder",
"cat sub_domains.txt | docker run -i projectdiscovery/httpx",
"docker run projectdiscovery/naabu",
"docker run projectdiscovery/interactsh-client",
"docker run -it --rm wpscanteam/wpscan"
)

prog=1
progt=${#tools[@]}
for tool in "${tools[@]}"; do
	toolname=$(echo ${tool} | cut -f2 -d "/" | cut -f1 -d ":")
	printf "${GREEN}[${prog}/${progt}] ${NC}Pulling ${tool} ${BLUE}\n"
	docker pull $tool
	#echo -e "alias ${toolname}=\"${tool_aliases[${tool}]}\"" >> ~/.bash_aliases
	#echo -e "alias ${toolname}=\"${tool_aliases[${tool}]}\"" >> ~/.zshrc
	prog=$((${prog}+1))
done

printf "${GREEN}[DONE]${NC}\n"