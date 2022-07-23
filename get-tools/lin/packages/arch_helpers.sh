# yay

cd /opt
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R debugpoint:users ./yay
id debugpoint
cd yay
makepkg -si
cd /opt

# snap

cd /opt
git clone https://aur.archlinux.org/snapd.git
cd snapd
makepkg -si
sudo systemctl start snapd
sudo systemctl enable snapd