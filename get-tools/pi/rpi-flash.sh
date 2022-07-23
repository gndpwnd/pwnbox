#!/bin/bash

read -p "What is the full path to the rpi os image?> " imgdir
read -p "Would you like to enable ssh?> " sshen
clear

echo "Setting up drive..."
lsblk
echo "Have you plugged in the sd card yet?"
echo "Press c to continue..."
while : ; do
read -n 1 k <&1
if [[ $k = c ]] ; then
	echo ""
printf "Ok then, moving on....."
break
fi
done
clear

lsblk
read -p "What is the drive identifier? (Ex: sda, sdb, sdc)> " dv
echo "Formatting drive..."
sudo umount /dev/$dv*
sudo parted /dev/$dv --script -- mklabel msdos
sudo parted /dev/$dv --script -- mkpart primary fat32 1MiB 100%
sudo mkfs.fat -F32 /dev/${dv}1
clear

echo "Copying files..."
sudo dd if=$imgdir of=/dev/$dv bs=4M; sync
clear

if [[ $sshen = y ]] ; then
	echo "Enabling ssh..."
	sudo mount /dev/${dv}1 /mnt
  touch /mnt/ssh
	umount /mnt
	clear
fi

echo "Image Flashed: $imgdir"
echo "Drive: /dev/$dv"
if [[ $sshen = y ]] ; then
	echo "SSH: enabled"
else
  echo "SSH: not enabled"
fi
echo "Done!"