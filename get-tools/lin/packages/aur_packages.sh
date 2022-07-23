#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
if (( $EUID != 0 )); then
	printf "${RED}[x] sudo privileges not detected!!!\n"
	printf "This must be run as root.\nUse: ${NC}'sudo bash $0'\n"
 	exit
fi

aur_packages=(
    "spotify",
    "discord",
    "element-desktop-git",
    "telegram-desktop-bin",
    "obs-studio-git",
    "droidcam-obs-plugin-git",
    "thunderbird-bin",
    "gimp-git",
    "visual-studio-code-bin",
    "sublime-text-4",
    "vlc-git",
    "kdenlive-git",
    "audacity-git",
    "powershell-git",
    "keepassxc-git",
    "libreoffice-dev-bin",
    "librepcb-git",
    "android-studio",
    "apkstudio-git",
    "balena-etcher",
    "vmware-workstation",
    "simplescreenrecorder-git",
    "obsidian-appimage"
)

for package in "${aur_packages[@]}"; do
    printf "${GREEN}Installing ${BLUE}${package}${NC}\n"
    sudo pacman -S --noconfirm ${package}
done

printf "${GREEN}[+] Done!!!"