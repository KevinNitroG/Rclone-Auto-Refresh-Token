# ✨ RCLONE AUTO REFRESH TOKEN ![Refresh Token Status](../../actions/workflows/Refresh_Token.yml/badge.svg?branch=main)

-   This repo will help to check your remotes' storage / list album of GGPhotos to refresh the tokens
-   When you don't use your remote for a time, its token is expired itself
-   This repo keeps your remotes' tokens alive, not to be expired
-   Automatically run using Github Action on Cron Schedule
    > Default: Runs at 00:00 GMT

---

# TABLE OF CONTENTS

-   [✨ RCLONE AUTO REFRESH TOKEN ](#-rclone-auto-refresh-token-)
-   [TABLE OF CONTENTS](#table-of-contents)
-   [📝 NOTES](#-notes)
-   [📃 HOW TO USE](#-how-to-use)
    -   [1️⃣ HAVE YOUR OWN REPO](#1️⃣-have-your-own-repo)
    -   [2️⃣ CREATE RCLONE.CONF](#2️⃣-create-rcloneconf)
        -   [OPTION 1: Edit directly](#option-1-edit-directly)
        -   [OPTION 2: Use secret](#option-2-use-secret)
    -   [3️⃣ SELECT REMOTES TO REFRESH TOKENS](#3️⃣-select-remotes-to-refresh-tokens)
        -   [OPTION 1: Edit directly](#option-1-edit-directly-1)
        -   [OPTION 2: Use either Secret or Variable](#option-2-use-either-secret-or-variable)
    -   [4️⃣ SET FEATURE ON / OFF _(optional)_](#4️⃣-set-feature-on--off-optional)
    -   [5️⃣ SETUP SEND LOG TO TELEGRAM _(optional)_](#5️⃣-setup-send-log-to-telegram-optional)
-   [🏃‍♂️ RUN](#️-run)

---

# 📝 NOTES

-   The old workflows runs will be deleted after 10080 minutes _(7 days)_
    > Run by [`Delete old workflows runs.yml`](.github/workflows/Delete%20old%20workflows%20runs.yml)
-   This repo will cache the Rclone, save up time to setup Rclone
    > If you face any error or want to update newer Rclone version, delete the old cache `cache-rclone` in Actions tab → Management → Caches
-   I've just tested `GoogleDrive`, `OneDrive`, `Mega`, `Dropbox`, `GGPhotos`. Others I haven't tested yet.
-   Not support `Shared Google Drive` and `Combine`
-   If you face any error, create an issue and type in the full log of the failed step
    > Don't forget to censore your personal information in the log

---

# 📃 HOW TO USE

## 1️⃣ HAVE YOUR OWN REPO

-   Fork this repo
-   If you want to make your repo private, then choose **Use this template** to **Create a new repository**

## 2️⃣ CREATE RCLONE.CONF

### OPTION 1: Edit directly

> Should use only for private repo

-   Create a file name `rclone.conf`
-   Fill in [`rclone.conf`][rclone.conf] which you created in the previous step

### OPTION 2: Use secret

-   Create action secret
-   **Name**: `RCLONE_CONFIG_FILE`<br>**Value**: Fill in the raw link of `rlcone.conf` file
    > You can make the raw link from gist

## 3️⃣ SELECT REMOTES TO REFRESH TOKENS

If you don't do this step, it will automatically extract all your remotes _(Yes including combine, shared drive which may cause the job to fail)_. Skip this step if you ensure that all of your remotes are suppported by the script.

<Details>
<summary>

Ex of `rclone.conf`

</summary>

```rclone.conf
[Gugu drai] <-- Take note of this remote name
type = drive
scope = drive
token = {...}
...
```

</Details>

<Details>
<summary>
Content format:
</summary>

```REMOTES.txt
Gugu drai
1Drai
...
GGPhotosMain
Oops
```

</Details>

> **Note:** Don't keep any line break, don't keep space at the end of each line 🥴

### OPTION 1: Edit directly

-   Create a file name `REMOTES.txt`
-   Enter the content in the file [`REMOTES.txt`][REMOTES.txt] you created in the previous step

### OPTION 2: Use either Secret or Variable

-   Create action secret/variable
-   **Name**: `REMOTES`<br>**Value**: Fill in either the content or raw link
    > If you fill in both, secret will rewrite variable

## 4️⃣ SET FEATURE ON / OFF _(optional)_

Go to your [`Refresh Token.yml`][Refresh Token.yml] file and edit lines in `env:`

| NAME OF VARIABLE | DESCRIPTION                                                                  | HOW TO USE                                                                         | DEFAULT VALUE |
| ---------------- | ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- | ------------- |
| PRINT_LOG        | After the running the script, it will print out the log to Github Action log | Set value in [`Refresh Token.yml`](.github/workflows/Refresh%20Token.yml#L15) file | `false`       |
| TELEGRAM         | Send the log as message to your Telegram                                     | Set value in [`Refresh Token.yml`](.github/workflows/Refresh%20Token.yml#L16) file | `false`       |

## 5️⃣ SETUP SEND LOG TO TELEGRAM _(optional)_

-   Ensure that you have set `TELEGRAM` in [`Refresh Token.yml`][Refresh Token.yml] to `True` to enable this
-   Create 2 secrets:
    -   **Name**: `TELGRAM_TO`<br>**Value**: The id of your group or user
    -   **Name**: `TELGRAM_TOKEN`<br>**Value**: Your bot token _(take it from [Bot Father](https://t.me/BotFather))_

---

# 🏃‍♂️ RUN

The workflow will automatically run when you do either:

-   Run itself on cron schedule, you can edit it in [`Refresh Token.yml`](.github/workflows/Refresh_Token.yml#L8)
-   Trigger from action tab _(workflow dispatch)_
-   Star/Restar the repo ⭐

<!-- Foot Notes -->

[rclone.conf]: rclone.conf
[REMOTES.txt]: REMOTES.txt
[Refresh Token.yml]: .github/workflows/Refresh_Token.yml
