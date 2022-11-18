#!/usr/bin/env bash
#
# Disks space report function. Prints table with disks utilization

# Filter displayed disks by this regular expression. I.e.: "^\/dev\/sd[bc]" will
# match "/dev/sdb" and "/dev/sdc" disks (empty string = no filtering)
DISKS_SPACE_FILTER_REGEXP="^\/dev"
# Report header template (inherited)
DISKS_SPACE_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}"
# Report table template (inherited)
DISKS_SPACE_TABLE_TEMPLATE="${TABULAR_REPORT_TEMPLATE}"

# Report data row content template
read -d '' DISKS_SPACE_TABLE_ROW_DATA_TEMPLATE << _EOF_
<tr>
  <td style="text-align: left">%s</td>
  <td style="text-align: right">%s</td>
  <td style="text-align: right">%s</td>
  <td style="text-align: right">%s</td>
</tr>
_EOF_

# Report header row content template
read -d '' DISKS_SPACE_TABLE_ROW_HEADER_TEMPLATE << _EOF_
<tr>
  <th style="text-align: left">%s</th>
  <th style="text-align: right">%s</th>
  <th style="text-align: right">%s</th>
  <th style="text-align: right">%s</th>
</tr>
_EOF_

# Removes lines with disk stats which doesn't match given regular expression
# Globals:
#   None
# Arguments:
#   Result of df command
#   Regular expression to filter disks
# Returns:
#   Result of df command with filtered disks
function ssr::filter_disks_by_regexp {
  local command_result_lines
  local i
  local filtered_lines
  local IFS

  filtered_lines=()
  IFS=$'\n'

  command_result_lines=( $1 )

  for i in "${!command_result_lines[@]}"
  do
    :
    # Save header line
    if [[ $i -eq 0 ]]; then
      filtered_lines+=("${command_result_lines[$i]}")
      continue
    fi

    # Save "disk" report lines which matches regex
    if [[ -z "${2}" || "${command_result_lines[$i]}" =~ $2 ]]; then
      filtered_lines+=("${command_result_lines[$i]}")
    fi
  done

  arr::join $'\n' "${filtered_lines[@]}"
}

# Prints disks utilization report
# Globals:
#   DISKS_SPACE_FILTER_REGEXP             Filter displayed disks by this regular
#                                         expression (empty string = no filtering)
#   DISKS_SPACE_HEADER_TEMPLATE           Report header template
#   DISKS_SPACE_TABLE_TEMPLATE            Report table template
#   DISKS_SPACE_TABLE_ROW_DATA_TEMPLATE   Report table row data (TDs) template
#   DISKS_SPACE_TABLE_ROW_HEADER_TEMPLATE Report table row data (THs) template
# Arguments:
#   None
# Returns:
#   Report html
function ssr::disks_space {
  local command_result
  local lines_count
  local command_exit_code
  local error_text

  val::check_required_variables "DISKS_SPACE_FILTER_REGEXP" \
    "DISKS_SPACE_HEADER_TEMPLATE" "DISKS_SPACE_TABLE_TEMPLATE" \
    "DISKS_SPACE_TABLE_ROW_DATA_TEMPLATE" \
    "DISKS_SPACE_TABLE_ROW_HEADER_TEMPLATE"

  command_result=$( df -h --output=source,used,avail,pcent 2>&1 )

  # Was the command successful? Maybe parameters are not supported - fallback to
  # command without params
  if [[ $? -gt 0 ]]; then
    command_result=$( df -h 2>&1 )
    command_exit_code="$?"

    # Check the exit code of default command
    if [[ "${command_exit_code}" -gt 0 ]]; then
      error_text="Error while getting disks space: ${command_result}"
      err::throw "${command_exit_code}" "${error_text}"
    fi
  fi

  command_result=$(
    ssr::filter_disks_by_regexp "${command_result}" \
    "${DISKS_SPACE_FILTER_REGEXP}"
  )

  lines_count=$( echo "${command_result}" | wc -l )

  if [[ "${lines_count}" -le 1 ]]; then
    err::throw "${EXIT_CODE_CONFIG_ERROR}" "No disks found"
  fi

  printf "${DISKS_SPACE_HEADER_TEMPLATE}" "Disks"
  ssr::render_table "${command_result}" "${DISKS_SPACE_TABLE_TEMPLATE}" \
    "${DISKS_SPACE_TABLE_ROW_HEADER_TEMPLATE}" \
    "${DISKS_SPACE_TABLE_ROW_DATA_TEMPLATE}"
}