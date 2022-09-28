#!/usr/bin/env bash
#
# Processes report function. Prints running processes with highest cpu
# utilization

# count of most demanding processes displayed in the list
PROCESSES_COUNT="5"
# Report header template (inherited)
PROCESSES_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}"
# Report table template (inherited)
PROCESSES_TABLE_TEMPLATE="${TABULAR_REPORT_TEMPLATE}"

# Report header row content template
read -d '' PROCESSES_TABLE_ROW_HEADER_TEMPLATE  << _EOF_
<tr>
  <th style="text-align: left">%s</th>
  <th style="text-align: right">%s</th>
  <th style="text-align: right">%s</th>
  <th style="text-align: left">%s</th>
</tr>
_EOF_

# Report data row content template
read -d '' PROCESSES_TABLE_ROW_DATA_TEMPLATE  << _EOF_
<tr>
  <td style="text-align: left">%s</td>
  <td style="text-align: right">%s</td>
  <td style="text-align: right">%s</td>
  <td style="text-align: left">%s</td>
</tr>
_EOF_

# Prints CPU utilization and most demanding processes
# Globals:
#   PROCESSES_COUNT                     Count of most demanding processes
#                                       displayed in the list
#   PROCESSES_HEADER_TEMPLATE           Report header template
#   PROCESSES_TABLE_TEMPLATE            Report table template
#   PROCESSES_TABLE_ROW_DATA_TEMPLATE   Report table row data (TDs) template
#   PROCESSES_TABLE_ROW_HEADER_TEMPLATE Report table row data (THs) template
# Arguments:
#   None
# Returns:
#   Report html
function ssr::processes {
  local processes_report
  local count
  local ps_exit_code

  ssr::check_required_variables "PROCESSES_COUNT" "PROCESSES_HEADER_TEMPLATE" \
    "PROCESSES_TABLE_TEMPLATE" "PROCESSES_TABLE_ROW_HEADER_TEMPLATE" \
    "PROCESSES_TABLE_ROW_DATA_TEMPLATE"

  count=$((PROCESSES_COUNT+1)) # First line is header
  processes_report=$( ps -e -o user,%cpu,%mem,comm --sort -%cpu 2>&1 )

  # Check if command fails on unsupported params and fallback to less
  # sophisticated command
  if [[ $? -gt 0 ]]; then
    processes_report=$( ps -e -r -o user,%cpu,%mem,comm 2>&1 )

    # Check the exit code of default command
    ps_exit_code="$?"
    if [[ "${ps_exit_code}" -gt 0 ]]; then
      ssr::throw_error "${ps_exit_code}" "${processes_report}"
    fi
  fi

  # Limit count of report lines
  processes_report=$(
    echo "${processes_report}" \
      | head -"${count}"
  )

  printf "${PROCESSES_HEADER_TEMPLATE}" "Processes"
  ssr::render_table "${processes_report}" "${PROCESSES_TABLE_TEMPLATE}" \
    "${PROCESSES_TABLE_ROW_HEADER_TEMPLATE}" \
    "${PROCESSES_TABLE_ROW_DATA_TEMPLATE}"
}