#!/usr/bin/env bash

LOGGED_USERS_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}" # Report header template (inherited)
LOGGED_USERS_TABLE_TEMPLATE="${TABULAR_REPORT_TEMPLATE}" # Report table template (inherited)
LOGGED_USERS_MESSAGE_TEMPLATE="${SIMPLE_REPORT_TEMPLATE}" # Report message template (inherited)

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

# Prints all logged users with details
# Globals:
#   LOGGED_USERS_HEADER_TEMPLATE           Report header template
#   LOGGED_USERS_MESSAGE_TEMPLATE          Report message template for case no users logged-in
#   LOGGED_USERS_TABLE_TEMPLATE            Report table template
#   LOGGED_USERS_TABLE_ROW_DATA_TEMPLATE   Report table row data (TDs) template
#   LOGGED_USERS_TABLE_ROW_HEADER_TEMPLATE Report table row data (THs) template
# Arguments:
#   None
# Returns:
#   Report html
function logged_users {
    local processesReport

    loggedUsersReport=$( who -H -u 2> /dev/null )

    # Check the exit code
    if [ $? -gt 0 ]; then
        >&2 echo "Logged users report error: \"who\" command ended with error!"
        return 1
    fi

    printf "${LOGGED_USERS_HEADER_TEMPLATE}" "Logged users"

    if [ $( echo "${loggedUsersReport}" | wc -l ) -le 1 ]; then
        # No users logged-in - only header line was printed
        printf "${LOGGED_USERS_MESSAGE_TEMPLATE}" "No users are logged-in"
    else
        renderTable "${loggedUsersReport}" "${LOGGED_USERS_TABLE_TEMPLATE}" "${LOGGED_USERS_TABLE_ROW_HEADER_TEMPLATE}" "${LOGGED_USERS_TABLE_ROW_DATA_TEMPLATE}"
    fi
}