#!/usr/bin/env bash
#
# Sample configuration file
#
# To create your own configuration copy this file to "config.sh" and change
# configration variables you want
#
# Do not change this file - you will prevent loosing your configuration when
# updating this script by pulling from GIT or copying
#
# Configuration of particular reports is at the bottom of this file

# Email subject
readonly EMAIL_SUBJECT="Server Report"

# Recipient of the report
readonly EMAIL_RECIPIENT="john.doe@gmail.com"

# Name of report recipient
readonly EMAIL_RECIPIENT_NAME="John Doe"

# Sender email
readonly EMAIL_SENDER="jack.smith@gmail.com"

# Sender name
readonly EMAIL_SENDER_NAME="Jack Smith"

# Reply-to email
readonly EMAIL_REPLY_TO="will.black@gmail.com"

# Reply-to name
readonly EMAIL_REPLY_TO_NAME="Will Black"

# Folder with sub-reports scripts
readonly REPORT_SCRIPTS_DIRECTORY="report_scripts"

# Reports to be used (corresponds with names of scripts in directory configured
# by REPORT_SCRIPTS_DIRECTORY)
readonly REPORTS=( "updates" "disks" "processes" "backups" "logged_users" )

# Folder where html templates are stored with slash at the end
readonly TEMPLATES_DIRECTORY="templates/"

# Template for error in report
readonly REPORT_ERROR_TEMPLATE=$(
  cat "${TEMPLATES_DIRECTORY}report_error.html"
)

# Template used for mail body
readonly MAIL_BODY_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}email.eml" )

# Template used for html mail body
readonly MAIN_TEMPLATE=$( cat "${TEMPLATES_DIRECTORY}main.html" )

# Template for particular report header
readonly REPORT_HEADER_TEMPLATE=$(
  cat "${TEMPLATES_DIRECTORY}report_header.html"
)

# Simple report template with nothing special - just styled text container
readonly SIMPLE_REPORT_TEMPLATE=$(
  cat "${TEMPLATES_DIRECTORY}simple_report.html"
)

# Real width of one letter in preformatted reports in px
readonly PREFORMATTED_REPORT_LETTER_WIDTH="8"

# Template for report with preformatted text
readonly PREFORMATTED_REPORT_TEMPLATE=$(
  cat "${TEMPLATES_DIRECTORY}preformatted_report.html"
)

# Template for tabular report, parameters: table content
readonly TABULAR_REPORT_TEMPLATE=$(
  cat "${TEMPLATES_DIRECTORY}tabular_report.html"
)

################################################################################
#                       Backups report configuration                           #
################################################################################

# Source backup directory  - with slash at the end!
readonly BACKUPS_DATA_DIRECTORY="./test/one/"

# Destination backup directory  - no slash at the end!
readonly BACKUPS_BACKUP_DIRECTORY="./test/two"

# Report content template
readonly BACKUPS_TEMPLATE="${SIMPLE_REPORT_TEMPLATE}"

# Report header template
readonly BACKUPS_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}"

################################################################################
#                         Disks report configuration                           #
################################################################################

# Filter displayed disks by this regular expression
# (empty string = no filtering)
readonly DISKS_FILTER_REGEXP="dev"

# Report header template
readonly DISKS_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}"

# Report table template
readonly DISKS_TABLE_TEMPLATE="${TABULAR_REPORT_TEMPLATE}"

# Report data row content template
read -d '' DISKS_TABLE_ROW_DATA_TEMPLATE << _EOF_
<tr>
  <td style="text-align: left">%s</td>
  <td style="text-align: right">%s</td>
  <td style="text-align: right">%s</td>
  <td style="text-align: right">%s</td>
</tr>
_EOF_
readonly DISKS_TABLE_ROW_DATA_TEMPLATE

# Report header row content template
read -d '' DISKS_TABLE_ROW_HEADER_TEMPLATE << _EOF_
<tr>
  <th style="text-align: left">%s</th>
  <th style="text-align: right">%s</th>
  <th style="text-align: right">%s</th>
  <th style="text-align: right">%s</th>
</tr>
_EOF_
readonly DISKS_TABLE_ROW_HEADER_TEMPLATE

################################################################################
#                       Logged users report configuration                      #
################################################################################

# Report header template
readonly LOGGED_USERS_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}"

# Report table template
readonly LOGGED_USERS_TABLE_TEMPLATE="${TABULAR_REPORT_TEMPLATE}"

# Report message template
readonly LOGGED_USERS_MESSAGE_TEMPLATE="${SIMPLE_REPORT_TEMPLATE}"

# Report header row content template
read -d '' LOGGED_USERS_TABLE_ROW_HEADER_TEMPLATE  << _EOF_
<tr>
  <th style="text-align: left">%s</th>
  <th style="text-align: left">%s</th>
  <th style="text-align: left">%s</th>
  <th style="text-align: left">%s</th>
  <th style="text-align: left">%s</th>
  <th style="text-align: left">%s</th>
</tr>
_EOF_
readonly LOGGED_USERS_TABLE_ROW_HEADER_TEMPLATE

# Report data row content template
read -d '' LOGGED_USERS_TABLE_ROW_DATA_TEMPLATE  << _EOF_
<tr>
  <td style="text-align: left">%s</td>
  <td style="text-align: left">%s</td>
  <td style="text-align: left">%s</td>
  <td style="text-align: left">%s</td>
  <td style="text-align: left">%s</td>
  <td style="text-align: left">%s</td>
</tr>
_EOF_
readonly LOGGED_USERS_TABLE_ROW_DATA_TEMPLATE

################################################################################
#                        Processes report configuration                        #
################################################################################

# count of most demanding processes displayed in the list
readonly PROCESSES_COUNT="5"

# Report header template
readonly PROCESSES_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}"

# Report table template
readonly PROCESSES_TABLE_TEMPLATE="${TABULAR_REPORT_TEMPLATE}"

# Report header row content template
read -d '' PROCESSES_TABLE_ROW_HEADER_TEMPLATE  << _EOF_
<tr>
  <th style="text-align: left">%s</th>
  <th style="text-align: right">%s</th>
  <th style="text-align: right">%s</th>
  <th style="text-align: left">%s</th>
</tr>
_EOF_
readonly PROCESSES_TABLE_ROW_HEADER_TEMPLATE

# Report data row content template
read -d '' PROCESSES_TABLE_ROW_DATA_TEMPLATE  << _EOF_
<tr>
  <td style="text-align: left">%s</td>
  <td style="text-align: right">%s</td>
  <td style="text-align: right">%s</td>
  <td style="text-align: left">%s</td>
</tr>
_EOF_
readonly PROCESSES_TABLE_ROW_DATA_TEMPLATE

################################################################################
#                         Updates report configuration                         #
################################################################################

# Report header template
readonly UPDATES_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}"

# Report content template
readonly UPDATES_TEMPLATE="${SIMPLE_REPORT_TEMPLATE}"
