#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
if (( $EUID != 0 )); then
	printf "${RED}sudo privileges not detected!!!\n"
	printf "This must be run as root.\nUse: ${NC}'sudo bash $0'\n"
 	exit
fi
snap_packages=(
"code --classic",
"sublime-text --classic",
"simplescreenrecorder",
"vlc",
"spotify",
"discord",
"element-client",
"telegram-desktop",
"obs-studio",
"thunderbird",
"gimp",
"kdenlive",
"audacity",
"powershell",
"keepassxc",
"libreoffice",
"libreoffice-calc",
"libreoffice-draw",
"libreoffice-impress",
"libreoffice-math",
"libreoffice-writer",
"librepcb",
"android-studio --classic"
)
for package in "${snap_packages[@]}"; do
	printf "${GREEN}Installing ${BLUE}${package}${NC}\n"
	snap install ${package}
done

echo -e "
${YELLOW}[-] Add the following line to your user's .bashrc or .zshrc:${NC}

export DOTNET_ROOT=/snap/dotnet-sdk/current

" 
printf "${GREEN}[+] Done!!!"