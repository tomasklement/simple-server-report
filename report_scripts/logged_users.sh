#!/usr/bin/env bash
#
# Logged users report function. Prints users currently logged-in

# Report header template (inherited)
LOGGED_USERS_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}"
# Report table template (inherited)
LOGGED_USERS_TABLE_TEMPLATE="${TABULAR_REPORT_TEMPLATE}"
# Report message template (inherited)
LOGGED_USERS_MESSAGE_TEMPLATE="${SIMPLE_REPORT_TEMPLATE}"

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
#   LOGGED_USERS_MESSAGE_TEMPLATE          Report message template for case no
#                                          users logged-in
#   LOGGED_USERS_TABLE_TEMPLATE            Report table template
#   LOGGED_USERS_TABLE_ROW_DATA_TEMPLATE   Report table row data (TDs) template
#   LOGGED_USERS_TABLE_ROW_HEADER_TEMPLATE Report table row data (THs) template
# Arguments:
#   None
# Returns:
#   Report html
function ssr::logged_users {
  local logged_users_report
  local lines_count

  logged_users_report=$( who -H -u 2> /dev/null )

  # Check the exit code
  if [[ $? -gt 0 ]]; then
    ssr::print_error \
      "Logged users report error: \"who\" command ended with error!"
    return 1
  fi

  printf "${LOGGED_USERS_HEADER_TEMPLATE}" "Logged users"

  lines_count=$(
    echo "${logged_users_report}" \
      | wc -l
  )

  if [[ "${lines_count}" -le 1 ]]; then
    # No users logged-in - only header line was printed
    printf "${LOGGED_USERS_MESSAGE_TEMPLATE}" "No users are logged-in"
  else
    ssr::render_table "${logged_users_report}" \
      "${LOGGED_USERS_TABLE_TEMPLATE}" \
      "${LOGGED_USERS_TABLE_ROW_HEADER_TEMPLATE}" \
      "${LOGGED_USERS_TABLE_ROW_DATA_TEMPLATE}"
  fi
}