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

