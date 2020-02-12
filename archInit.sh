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
swap_size=$(free -m | awk '/Mem:/ {print $2')
swap_end=$(( $swap_size + 1 + 250 ))

## Partitioning disk
parted --script "${device}" -- mklabel gpt \
  mkpart EXP fat32 1Mib 250MiB \
  set 1 boot on \
  mkpart primary linux-swap 250Mib ${swap_end} \
  mkpart primary ext4 ${swap_end} 100%
