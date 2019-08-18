#!/bin/bash

# !!! IMPORTANT !!!
# To create your own configuration, create "config.sh" and define some of following configuration vartiables - they will override this default configuration. Do not change this file - you will prevent loosing your when you update this script

EMAIL_SUBJECT="Server Report" # Email subject (optional)
EMAIL_RECIPIENT="" # Recipient of the report (required), i.e.: "john.doe@gmail.com"
EMAIL_RECIPIENT_NAME="" # (optional) Name of report recipient, i.e.: "John Doe"
EMAIL_SENDER="" # Sender email (required), i.e.: "john.doe@gmail.com"
EMAIL_SENDER_NAME="" # (optional) Sender name, i.e.: "John Doe"
EMAIL_REPLY_TO="" # (optional) Reply-to email, i.e.: "john.doe@gmail.com"
EMAIL_REPLY_TO_NAME="" # (optional) Reply-to name, i.e.: "John Doe"

REPORT_SCRIPTS_FOLDER="report_scripts" # Folder with sub-reports scripts
REPORTS=( "updates" "disks" "processes" "backups" ) # Reports to be used (corresponds with names of scripts in folder configured by REPORT_SCRIPTS_FOLDER)

REPORT_LETTER_WIDTH=8 # Real width of one letter in reports in px (used to set css width of the report)

CUSTOM_CONFIG_FILE_NAME="config.sh" # Name of custom config file

# Template used for mail body, parameters: headers, content
read -d '' MAIL_BODY_TEMPLATE << _EOF_
Content-Type: text/html; charset=UTF-8
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
%s
%s
_EOF_

# Template used for html mail body, parameters: main header, content
read -d '' MAIN_TEMPLATE << _EOF_
<!doctype html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html charset=UTF-8" />
    <style>
        body {
            font-family: Helvetica, Arial, sans-serif;
        }
    </style>
</head>
<body>
    <h1>%s</h1>
    %s
</body>

</html>
_EOF_

# Partial html template for one report, parameters: heading, width (px), header, content
read -d '' REPORT_TEMPLATE << _EOF_
<h2>%s</h2>
<div style="width: %spx; font-size: 12px; border: 1px solid rgb(221, 221, 221); background-color: rgb(238, 238, 238);">
    %s
    <div style="padding: 10px;">
        <pre style="margin: 0;">%s</pre>
	</div>
</div>
_EOF_

# Partial html template for report header parameters: header content
read -d '' REPORT_TEMPLATE_HEADER << _EOF_
<div style="padding: 10px; background-color: rgb(221, 221, 221); font-weight: bold;">
    <pre style="margin: 0;">%s</pre>
</div>
_EOF_