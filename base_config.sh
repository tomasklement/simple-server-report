#!/usr/bin/env bash

# !!! IMPORTANT !!!
# To create your own configuration, create "config.sh" and define any of following configuration variables - they will override this default configuration.
# Do not change this file - you will prevent loosing your configuration when updating this script

EMAIL_SUBJECT="Server Report" # Email subject (optional)
EMAIL_RECIPIENT="" # Recipient of the report (required), i.e.: "john.doe@gmail.com"
EMAIL_RECIPIENT_NAME="" # (optional) Name of report recipient, i.e.: "John Doe"
EMAIL_SENDER="" # Sender email (required), i.e.: "john.doe@gmail.com"
EMAIL_SENDER_NAME="" # (optional) Sender name, i.e.: "John Doe"
EMAIL_REPLY_TO="" # (optional) Reply-to email, i.e.: "john.doe@gmail.com"
EMAIL_REPLY_TO_NAME="" # (optional) Reply-to name, i.e.: "John Doe"

REPORT_SCRIPTS_DIRECTORY="report_scripts" # Folder with sub-reports scripts
REPORTS=( "updates" "disks" "processes" "backups" ) # Reports to be used (corresponds with names of scripts in directory  configured by REPORT_SCRIPTS_DIRECTORY)

CUSTOM_CONFIG_FILE_NAME="config.sh" # Name of custom config file
TEMPLATES_DIRECTORY="templates/" # Folder where html templates are stored with slash at the end

# Template used for mail body, parameters: headers, content
MAIL_BODY_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}email.eml" )

# Template used for html mail body, parameters: main header, content
MAIN_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}main.html" )

# Template for particular report header, parameters: text
REPORT_HEADER_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}report_header.html" )

# Simple report template with nothing special - just styled text container, parameters: text
SIMPLE_REPORT_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}simple_report.html" )

# Template for report with preformatted text, parameters: width (px), text
PREFORMATTED_REPORT_LETTER_WIDTH=8 # Real width of one letter in preformatted reports in px
PREFORMATTED_REPORT_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}preformatted_report.html" )

# Template for tabular report, parameters: table content
TABULAR_REPORT_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}tabular_report.html" )

# Template for error in report, parameters: report name
REPORT_ERROR_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}report_error.html" )