#!/bin/bash

sed -i -e 's/\s*$//' -e '/^$/d' -e 's/\r//g' REMOTES.txt
IFS=$'\n'
fail=0

# DELETE OLD REFRESH_TOKEN_LOG.TXT IF NEED
rm -rf refresh_token_log.txt
# REDIRECT THE LOG INTO REFRESH_TOKEN_LOG.TXT
exec >> refresh_token_log.txt 2>&1

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

# TITLE FOR REFRESH_TOKEN_LOG.TXT
echo "--- Log of Rclone Auto Refresh Token ---" >> refresh_token_log.txt
echo >> refresh_token_log.txt

# READ THE REMOTES.TXT AND RUN REFRESH TOKEN
while IFS= read -r i
do
    echo --------- "$i" ---------
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
            echo "$i's token may be expired or revoked."
            echo "Please renew the token by using rclone config reconnect $i:, edit rclone.conf and try again"
            fail=1
            ;;
        *"maybe token expired?"*)
            echo "****** !!! FAIL !!! ******"
            echo "$i's token may be expired."
            echo "Please renew the token by using rclone config reconnect $i:, edit rclone.conf and try again"
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
