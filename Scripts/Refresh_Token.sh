#!/bin/bash

sed -i -e 's/\s*$//' -e '/^$/d' -e 's/\r//g' REMOTES.txt
IFS=$'\n'
fail=0

# IF REMOTES.TXT IS EMPTY, EXTRACT ALL REMOTES INTO REMOTES.TXT
if [ ! -s "REMOTES.txt" ]; then
    while read line
    do
    # Check if line contains a string enclosed in square brackets
    if [[ $line =~ \[([^][]+)\] ]]
    then
        # Print the string enclosed in square brackets
        echo "${BASH_REMATCH[1]}" >> REMOTES.txt
    fi
    done < rclone.conf
fi

# READ THE REMOTES.TXT AND RUN REFRESH TOKEN
while IFS= read -r i
do
    echo --- "Refresh token for $i" ---
    check=$(./rclone about "$i": 2>&1)
    case "$check" in
        *"otal"*)
            echo "$check"
            ;;
        *"ailed to about: Google Photos path"*)
            ./rclone lsd "$i":album
            ;;
        "")
            echo "$i may be a Shared Drive, you should remove teamdrive = *** in your rclone.conf to about the storage"
            fail=1
            ;;
        *"invalid_access_token"*)
            echo "****** !!! FAIL !!! ******"
            echo "$i's token may be expired or revoked. Please renew the token yourself, edit rclone.conf and try again"
            fail=1
            ;;
        *"didn't find section in config file")
            echo "****** !!! FAIL !!! ******"
            echo "$i is not in your rclone.conf. Check it again if it is either correctly typed or exist"
            fail=1
            ;;
        *)
            echo "****** !!! FAIL !!! ******"
            echo "Sorry $i is not a supported remote"
            echo "Please create an issue about your unsupported remote in https://github.com/KevinNitroG/Rclone-Auto-Refresh-Token"
            fail=1
            ;;
    esac
    echo ------
    echo
done < <(grep -v '^ *#' < REMOTES.txt)

# CHECK IF THERE ARE ANY STEPS FAIL THEN EXIT 1
if [[ $fail -ne 0 ]]; then
    echo "There is one or more remotes whose tokens couldn't be refreshed!!!"
    exit 1
fi