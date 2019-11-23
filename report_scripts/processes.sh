#!/usr/bin/env bash

PROCESSES_COUNT="5" # count of most demanding processes displayed in the list
PROCESSES_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}" # Report header template (inherited)
PROCESSES_TABLE_TEMPLATE="${TABULAR_REPORT_TEMPLATE}" # Report table template (inherited)

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
#   PROCESSES_COUNT                     Count of most demanding processes displayed in the list
#   PROCESSES_HEADER_TEMPLATE           Report header template
#   PROCESSES_TABLE_TEMPLATE            Report table template
#   PROCESSES_TABLE_ROW_DATA_TEMPLATE   Report table row data (TDs) template
#   PROCESSES_TABLE_ROW_HEADER_TEMPLATE Report table row data (THs) template
# Arguments:
#   None
# Returns:
#   Report html
function processes {
    local processesReport
    local count=$((PROCESSES_COUNT+1)) # First line is header

    processesReport=$( ps -e -o user,%cpu,%mem,comm --sort -%cpu 2> /dev/null )

    # Check if command fails on unsupported params and fallback to less sophisticated command
    if [ $? -gt 0 ]; then
        processesReport=$( ps -e -r -o user,%cpu,%mem,comm 2> /dev/null )

        # Check the exit code of default command
        if [ $? -gt 0 ]; then
            >&2 echo "Processes report error: ps command ended with error!"
            return 1
        fi
    fi

    # Limit count of report lines
    processesReport=$( echo "${processesReport}" | head -"${count}" )

    printf "${PROCESSES_HEADER_TEMPLATE}" "Processes"
    renderTable "${processesReport}" "${PROCESSES_TABLE_TEMPLATE}" "${PROCESSES_TABLE_ROW_HEADER_TEMPLATE}" "${PROCESSES_TABLE_ROW_DATA_TEMPLATE}"
}