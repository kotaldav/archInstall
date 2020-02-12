#/bin/bash

set -uo pipefail

# Script url: https://git.io/JvWGU

hostname=$(dialog --stdout --inputbox "Enter hostname" 0 0) || exit 1
: ${hostname:?"hostname cannot be empty"}

username=$(dialog --stdout --inputbox "Enter username" 0 0) || exit 1
: ${username:?"username cannot be empty"}

pass=$(dialog --stdout --passwordbox"Enter password" 0 0) || exit 1
: ${pass:?"password cannot be empty"}

pass2=$(dialog --stdout --passwordbox"Confirm password" 0 0) || exit 1
[[ "$pass" == "$pass2" ]] || ( echo "Password did not match"; exit 1 )

devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)

