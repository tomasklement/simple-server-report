#!/usr/bin/env bash

DISKS_FILTER_REGEXP="dev" # Filter displayed disks by this regular expression (empty string = no filtering)
DISKS_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}" # Report header template (inherited)
DISKS_TABLE_TEMPLATE="${TABULAR_REPORT_TEMPLATE}" # Report table template (inherited)

# Report data row content template
read -d '' DISKS_TABLE_ROW_DATA_TEMPLATE << _EOF_
<tr>
    <td style="text-align: left">%s</td>
    <td style="text-align: right">%s</td>
    <td style="text-align: right">%s</td>
    <td style="text-align: right">%s</td>
</tr>
_EOF_

# Report header row content template
read -d '' DISKS_TABLE_ROW_HEADER_TEMPLATE << _EOF_
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
function filterDisksByRegExp {
    local commandResultLines
    local i
    local filteredLines=()
    local IFS=$'\n'

    commandResultLines=( $1 )

    for i in "${!commandResultLines[@]}"
    do
        :
        # Save header line
        if [ $i -eq 0 ]; then
            filteredLines+=("${commandResultLines[$i]}")
            continue
        fi

        # Save "disk" report lines which matches regex
        if [[ -z "${2}" || "${commandResultLines[$i]}" =~ $2 ]]; then
            filteredLines+=("${commandResultLines[$i]}")
        fi
    done

    joinBy $'\n' "${filteredLines[@]}"
}

# Prints disks utilization report
# Globals:
#   DISKS_FILTER_REGEXP             Filter displayed disks by this regular expression (empty string = no filtering)
#   DISKS_HEADER_TEMPLATE           Report header template
#   DISKS_TABLE_TEMPLATE            Report table template
#   DISKS_TABLE_ROW_DATA_TEMPLATE   Report table row data (TDs) template
#   DISKS_TABLE_ROW_HEADER_TEMPLATE Report table row data (THs) template
# Arguments:
#   None
# Returns:
#   Report html
function disks {
    local commandResult

    commandResult=$( df -h --output=source,used,avail,pcent 2> /dev/null )

    # Was the command successful? Maybe parameters are not supported - fallback to command without params
    if [ $? -gt 0 ]; then
        commandResult=$( df -h 2> /dev/null )

        # Check the exit code of default command
        if [ $? -gt 0 ]; then
            >&2 echo "Disks report error: df command ended with error!"
            return 1
        fi
    fi

    commandResult=$( filterDisksByRegExp "${commandResult}" "${DISKS_FILTER_REGEXP}" )

    if [ $( echo "${commandResult}" | wc -l ) -le 1 ]; then
        >&2 echo "Disks report error: no disks found!"
        return 1
    fi

    printf "${DISKS_HEADER_TEMPLATE}" "Disks"
    renderTable "${commandResult}" "${DISKS_TABLE_TEMPLATE}" "${DISKS_TABLE_ROW_HEADER_TEMPLATE}" "${DISKS_TABLE_ROW_DATA_TEMPLATE}"
}