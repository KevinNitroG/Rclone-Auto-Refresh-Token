#!/bin/bash

# SETUP BEFORE SCRIPT
sed -i -e 's/\s*$//' -e '/^$/d' -e 's/\r//g' REMOTES.txt
IFS=$'\n'
number_of_remotes=0
rm -rf refresh_token_log.txt failed_remote_indexes.txt
rm -rf logs_folder
mkdir logs_folder
touch failed_remote_indexes.txt

# IF REMOTES.TXT IS EMPTY, EXTRACT ALL REMOTES INTO REMOTES.TXT
if [ ! -s "REMOTES.txt" ]; then
  while read line; do
    # Check if line contains a string enclosed in square brackets
    if [[ $line =~ \[([^][]+)\] ]]; then
      # Print the string enclosed in square brackets
      echo "${BASH_REMATCH[1]}" >>REMOTES.txt
    fi
  done <rclone.conf
fi

# TITLE FOR REFRESH_TOKEN_LOG.TXT
echo "--- Log of Rclone Auto Refresh Token ---" >>refresh_token_log.txt
echo >>refresh_token_log.txt

# READ THE REMOTES.TXT AND RUN REFRESH TOKEN
while IFS= read -r i; do
  ((number_of_remotes += 1))
  (
    exec >>logs_folder/refresh_token_log_"$number_of_remotes".txt 2>&1
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
        current_fail=1
        ;;
      *"invalid_access_token"*)
        echo "****** !!! FAIL !!! ******"
        echo "$i's token may be expired or revoked."
        echo "Please renew the token by using rclone config reconnect $i:, edit rclone.conf and try again"
        current_fail=1
        ;;
      *"maybe token expired?"*)
        echo "****** !!! FAIL !!! ******"
        echo "$i's token may be expired."
        echo "Please renew the token by using rclone config reconnect $i:, edit rclone.conf and try again"
        current_fail=1
        ;;
      *"didn't find section in config file")
        echo "****** !!! FAIL !!! ******"
        echo "$i is not in your rclone.conf. Check it again if it is either correctly typed or exist"
        current_fail=1
        ;;
      *)
        echo "****** !!! FAIL !!! ******"
        echo "Sorry $i is not a supported remote"
        echo "Please create an issue about your unsupported remote in https://github.com/KevinNitroG/Rclone-Auto-Refresh-Token"
        current_fail=1
        ;;
    esac
    echo ------
    echo
    if [[ $current_fail == 1 ]]; then
      echo "$number_of_remotes" >>failed_remote_indexes.txt
    fi
  ) &
done < <(grep -v '^ *#' <REMOTES.txt)
wait

# Exit & logging to main terminal
exec 1>&2

# MERGE LOGS INTO MAIN REFRESH_TOKEN_LOG.TXT
cat logs_folder/*.txt >>refresh_token_log.txt

# CHECK FAIL
if [ -s failed_remote_indexes.txt ]; then
  echo "There is one or more remotes whose tokens couldn't be refreshed!!!"
  echo "If it failed because unsupported remote, then create an issue in https://github.com/KevinNitroG/Rclone-Auto-Refresh-Token/issues"
  echo "Here is the list of failed remotes"
  echo
  while read -r i; do
    cat "logs_folder/refresh_token_log_$i.txt"
  done < <(grep -v '^ *#' <failed_remote_indexes.txt)
  exit 1
else
  echo "Successfully refresh all tokens ^^"
fi

# REMOVE ALL UNUSED FILES / FOLDER
rm -rf logs_folder
rm failed_remote_indexes.txt
