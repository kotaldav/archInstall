#/bin/bash

set -uo pipefail

# Script url: https://git.io/JvWGU

hostname=$(dialog --stdout --inputbox "Enter hostname" 0 0) || exit 1
clear
: ${hostname:?"hostname cannot be empty"}

username=$(dialog --stdout --inputbox "Enter username" 0 0) || exit 1
clear
: ${username:?"username cannot be empty"}

pass=$(dialog --stdout --passwordbox "Enter password" 0 0) || exit 1
clear
: ${pass:?"password cannot be empty"}

pass2=$(dialog --stdout --passwordbox "Confirm password" 0 0) || exit 1
clear
[[ "$pass" == "$pass2" ]] || ( echo "Password did not match"; exit 1 )

devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
device=$(dialog --stdout --menu "Select installation disk" 0 0 0 ${devicelist}) || exit 1
clear

## Calculating swap size
## For possibility of using hibernation, swap size needs to be at least the size of RAM
swap_size=$(free -m | awk '/Mem:/ {print $2}')
swap_end=$(( $swap_size + 1 + 500 ))

## Partitioning disk
parted --script "${device}" \
  mklabel gpt \
  mkpart ESP fat32 1Mib 500MiB \
  set 1 boot on \
  mkpart primary linux-swap 500Mib ${swap_end} \
  mkpart primary ext4 ${swap_end} 100%

part_esp="/dev/sda1"
part_swap="/dev/sda2"
part_root="/dev/sda3"

mkfs.fat -F32 "${part_esp}"
mkfs.ext4 "${part_root}"
mkswap "${part_swap}"
swapon "${part_swap}"

# Mounting file systems
mount "${part_root}" /mnt
mkdir /mnt/efi
mount "${part_esp}" /mnt/efi

pacstrap /mnt base linux linux-firmware
genfstab -t PARTUUID /mnt >> /mnt/etc/fstab
echo "${hostname}" > /mnt/etc/hostname

## install other base packages
pacstrap /mnt sudo wget unzip zip 

## install shell
pacstrap /mnt zsh zsh-config

## install network tools
pacstrap /mnt dnsutils wireless_tools openssh

## install window manager
pacstrap /mnt i3-gapsi i3blocks i3status i3lock xorg-server xorg-xinit arandr

## install file manager
pacstrap /mnt ranger

## install audio control
pacstrap /mnt pulseaudio pulseaudio-alsa pulseaudio-bluetooth pavucontrol

## install video control
pacstram /mnt 

## install utilities
pacstrap /mnt redshift chromium okular

## install fonts
pacstrap /mnt noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-monofur ttf-dejavu xorg-fonts-misc ttf-font-awesome

## install docker & kubernetes tools
pacstrap /mnt docker 

## set locale
echo "LAN=en_GB.UTF-8" > /mnt/etc/locale.conf

## chroot into new system
arch-chroot /mnt useradd -mU -s /usr/bin/zsh -G wheel,docker,video,audio "$username"
arch-chroot /mnt chsh -s /usr/bin/zsh

echo "$username:$pass" | chpasswd --root /mnt
echo "root:$pass" | chpasswd --root /mnt

#TODO - boot loader








