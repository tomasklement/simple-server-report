#!/usr/bin/env bash
#
# Disks health report function.

# Disks to be checked
DISKS_HEALTH_DISKS=( "/dev/sda" )

# S.M.A.R.T. parameters which should have zero values
DISKS_HEALTH_CHECK_ZERO_VALUES=(
  "Current_Pending_Sector"
  "Reallocated_Sector_Ct"
)

# Labels in rows of smartctl report which are followed by important value.
# Parses value after particular label followed by ": ". It can contain regular
# expression control characters
DISKS_HEALTH_IMPORTANT_VALUES=(
  "ATA Error Count"
  "SMART overall-health self-assessment test result"
)

# Report header template (inherited)
DISKS_HEALTH_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}"

# Template for subheader with disk path
DISKS_HEALTH_SUBHEADER_TEMPLATE="<h3>%s</h3>"

# Report table template (inherited)
DISKS_HEALTH_TABLE_TEMPLATE="${TABULAR_REPORT_TEMPLATE}"

# Report important values table - header row template
read -d '' DISKS_HEALTH_IMPORTANT_VALUES_TABLE_ROW_HEADER_TEMPLATE  << _EOF_
<tr>
  <th style="text-align: left">%s</th>
  <th style="text-align: right">%s</th>
</tr>
_EOF_

# Report important values table - data row template
read -d '' DISKS_HEALTH_IMPORTANT_VALUES_TABLE_ROW_DATA_TEMPLATE  << _EOF_
<tr>
  <td style="text-align: left">%s</td>
  <td style="text-align: right">%s</td>
</tr>
_EOF_

# Report SMART values table - header row template
read -d '' DISKS_HEALTH_SMART_TABLE_ROW_HEADER_TEMPLATE  << _EOF_
<tr>
  <th style="text-align: left">%s</th>
  <th style="text-align: right">%s</th>
  <th style="text-align: right">%s</th>
</tr>
_EOF_

# Report SMART values table - data row template
read -d '' DISKS_HEALTH_SMART_TABLE_ROW_DATA_TEMPLATE  << _EOF_
<tr>
  <td style="text-align: left">%s</td>
  <td style="text-align: right">%s</td>
  <td style="text-align: right; color: %s;">%s</td>
</tr>
_EOF_


# Parses values from S.M.A.R.T. report table (values which should be 0)
# Globals:
#   None
# Arguments:
#   Result of smartctl command
#   Name of S.M.A.R.T. parameter
# Returns:
#   Values for disk health report table row or error message to STDERR
function ssr::disks_health_zero_row_values {
  local result_line
  local value
  local value_status
  local value_status_color
  local row_values

  result_line=$( printf "$1" | grep "${2}" )

  if [[ -z "${result_line}" ]]; then
    ssr::throw_error 22 "Didn't find param \"${2}\""
  fi

  value=$( printf "${result_line}" | sed -E "s/.*([0-9]+)$/\1/" )

  if ! [[ "$value" =~ ^[0-9]+$ ]]; then
    ssr::throw_error 22 "Cannot parse value of \"${2}\""
  fi

  if ! [[ "$value" -gt 0 ]]; then
    value_status="OK"
    value_status_color="green"
  else
    value_status="Should be zero"
    value_status_color="red"
  fi

  row_values=( "${2}" "${value}" "${value_status_color}" "${value_status}" )

  ssr::join_by $'\n' "${row_values[@]}"
}

# Parses value from S.M.A.R.T. report which is preceded with given label
# Globals:
#   None
# Arguments:
#   Result of smartctl command
#   Label which precedes requested value
# Returns:
#   Value of the report
function ssr::disks_health_get_row_value {
  local value

  value=$( printf "$1" | grep "${2}" )
  value=$( printf "${value}" | sed -E "s/${2}: *([^ ]+).*/\1/" )
  echo "${value}"
}

# Prints disks health report table with SMART values which should be 0
# Globals:
#   DISKS_HEALTH_SMART_TABLE_ROW_HEADER_TEMPLATE Template for SMART report table
#                                                header row
#   DISKS_HEALTH_CHECK_ZERO_VALUES               S.M.A.R.T. params which should
#                                                have zero values to be checked
#   DISKS_HEALTH_SMART_TABLE_ROW_DATA_TEMPLATE   Template for report table data
#                                                row
#   DISKS_HEALTH_TABLE_TEMPLATE                  Templ. for SMART report table
# Arguments:
#   Result of smartctl command
# Returns:
#   Report html table
function ssr::disks_health_smart_values_table {
  local table
  local columns

  table=$(
    printf "${DISKS_HEALTH_SMART_TABLE_ROW_HEADER_TEMPLATE}" \
    "S.M.A.R.T. param" "Value" "Status"
  )

  for i in "${!DISKS_HEALTH_CHECK_ZERO_VALUES[@]}"
  do
    :
    columns=(
      $( ssr::disks_health_zero_row_values "${command_result}" \
          "${DISKS_HEALTH_CHECK_ZERO_VALUES[i]}" )
    )

    table+=$(
      printf "${DISKS_HEALTH_SMART_TABLE_ROW_DATA_TEMPLATE}" \
      "${columns[@]}"
    )
  done

  printf "${DISKS_HEALTH_TABLE_TEMPLATE}" "${table}"
}

# Prints disks health report table with important values
# Globals:
#   DISKS_HEALTH_TABLE_TEMPLATE   Templ. for SMART report table
#   DISKS_HEALTH_IMPORTANT_VALUES Important values to be parsed
#
#   DISKS_HEALTH_IMPORTANT_VALUES_TABLE_ROW_HEADER_TEMPLATE Template for
#                                                           important values
#                                                           table header row
#   DISKS_HEALTH_IMPORTANT_VALUES_TABLE_ROW_DATA_TEMPLATE   Template for
#                                                           important values
#                                                           table data row
# Arguments:
#   Result of smartctl command
# Returns:
#   Report html table
function ssr::disks_health_important_values_table {
  local table
  local value

  table=$(
    printf "${DISKS_HEALTH_IMPORTANT_VALUES_TABLE_ROW_HEADER_TEMPLATE}" \
    "Parameter" "Value"
  )

  for i in "${!DISKS_HEALTH_IMPORTANT_VALUES[@]}"
  do
    :
    value=$( ssr::disks_health_get_row_value "${command_result}" \
      "${DISKS_HEALTH_IMPORTANT_VALUES[i]}" )

    if [[ -z "${value}" ]]; then
      value="N/A"
    fi

    table+=$(
      printf "${DISKS_HEALTH_IMPORTANT_VALUES_TABLE_ROW_DATA_TEMPLATE}" \
        "${DISKS_HEALTH_IMPORTANT_VALUES[i]}" "${value}"
    )
  done

  printf "${DISKS_HEALTH_TABLE_TEMPLATE}" "${table}"
}

# Prints disks health report
# Globals:
#   DISKS_HEALTH_DISKS                           Array with paths to disks to be
#                                                checked
#   DISKS_HEALTH_SUBHEADER_TEMPLATE              Template for subheader with
#                                                disk path
#   DISKS_HEALTH_SMART_TABLE_ROW_HEADER_TEMPLATE Template for SMART report table
#                                                header row
#   DISKS_HEALTH_CHECK_ZERO_VALUES               S.M.A.R.T. params which should
#                                                have zero values to be checked
#   DISKS_HEALTH_SMART_TABLE_ROW_DATA_TEMPLATE   Template for report table data
#                                                row
#   DISKS_HEALTH_TABLE_TEMPLATE                  Templ. for SMART report table
#   DISKS_HEALTH_HEADER_TEMPLATE                 Main header template
#   EXIT_CODE_UNSUPPORTED_ERROR                  Error code for unsupported
#                                                command
#   DISKS_HEALTH_IMPORTANT_VALUES                Important values to be parsed
#
#   DISKS_HEALTH_IMPORTANT_VALUES_TABLE_ROW_HEADER_TEMPLATE Template for
#                                                           important values
#                                                           table header row
#   DISKS_HEALTH_IMPORTANT_VALUES_TABLE_ROW_DATA_TEMPLATE   Template for
#                                                           important values
#                                                           table data row
# Arguments:
#   None
# Returns:
#   Report html to STDOUT or error message to STDERR
function ssr::disks_health {
  local i
  local command_result
  local command_exit_code
  local result
  local IFS

  ssr::check_required_variables "DISKS_HEALTH_DISKS" \
    "DISKS_HEALTH_SUBHEADER_TEMPLATE" \
    "DISKS_HEALTH_SMART_TABLE_ROW_HEADER_TEMPLATE" \
    "DISKS_HEALTH_CHECK_ZERO_VALUES" \
    "DISKS_HEALTH_SMART_TABLE_ROW_DATA_TEMPLATE" "DISKS_HEALTH_TABLE_TEMPLATE" \
    "DISKS_HEALTH_HEADER_TEMPLATE" "EXIT_CODE_UNSUPPORTED_ERROR" \
    "DISKS_HEALTH_IMPORTANT_VALUES" \
    "DISKS_HEALTH_IMPORTANT_VALUES_TABLE_ROW_HEADER_TEMPLATE" \
    "DISKS_HEALTH_IMPORTANT_VALUES_TABLE_ROW_DATA_TEMPLATE"

  IFS=$'\n'

  for i in "${!DISKS_HEALTH_DISKS[@]}"
  do
    :
    command_result=$( smartctl -a "${DISKS_HEALTH_DISKS[i]}" 2>&1 )
    command_exit_code="$?"

    # Check the exit code of smartctl command (1-7 means overall failure)
    # Error codes greater than 7 means specific problems with disk
    if [[ "${command_exit_code}" -gt 0 ]] && \
        [[ "${command_exit_code}" -lt 8 ]]; then
      ssr::throw_error "${EXIT_CODE_UNSUPPORTED_ERROR}" \
        "Error while running smartctl: ${command_result}"
    fi

    result+=$(
      printf "${DISKS_HEALTH_SUBHEADER_TEMPLATE}" \
      "Disk: ${DISKS_HEALTH_DISKS[i]}"
    )

    result+=$( ssr::disks_health_smart_values_table "${command_result}" )
    result+=$( ssr::disks_health_important_values_table "${command_result}" )
  done

  printf "${DISKS_HEALTH_HEADER_TEMPLATE}" "Disks health"
  printf "${result}"
}