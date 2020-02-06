#!/usr/bin/env bash
#
# Base configuration file

# !!! IMPORTANT !!!
# To create your own configuration, create "config.sh" and define any of
# following configuration variables - they will override this default
# configuration.
#
# Do not change this file - you will prevent loosing your configuration when
# updating this app

EMAIL_SENDER="" # Sender email (required), i.e.: "john.doe@gmail.com"
EMAIL_RECIPIENT="" # Recipient of the report (required), i.e.: "doe@gmail.com"
EMAIL_SUBJECT="Server Report" # Email subject (optional)
EMAIL_RECIPIENT_NAME="" # (optional) Name of report recipient, i.e.: "John Doe"
EMAIL_SENDER_NAME="" # (optional) Sender name, i.e.: "John Doe"
EMAIL_REPLY_TO="" # (optional) Reply-to email, i.e.: "john.doe@gmail.com"
EMAIL_REPLY_TO_NAME="" # (optional) Reply-to name, i.e.: "John Doe"

# Reports to be used (corresponds with names of scripts in directory  configured
# by REPORTS_DIRECTORY)
REPORTS=(
  "disks_health" "disks_space" "logged_users" "processes" "sync" "updates"
)

# Template used for mail body, parameters: headers, content
MAIL_BODY_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}email.eml" )

# Template used for html mail body, parameters: main header, content
MAIN_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}main.html" )

# Template for particular report header, parameters: text
REPORT_HEADER_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}report_header.html" )

# Simple report template with nothing special - just styled text container,
# parameters: text
SIMPLE_REPORT_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}simple_report.html" )

# Template for report with preformatted text, parameters: width (px), text
PREFORMATTED_REPORT_TEMPLATE=$(
  cat "${TEMPLATES_DIRECTORY}preformatted_report.html"
)

# Template for tabular report, parameters: table content
TABULAR_REPORT_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}tabular_report.html" )