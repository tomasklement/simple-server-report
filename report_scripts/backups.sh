#!/usr/bin/env bash

BACKUPS_DATA_DIRECTORY="./test/one/" # Source backup directory  - with slash at the end!
BACKUPS_BACKUP_DIRECTORY="./test/two" # Destination backup directory  - no slash at the end!
BACKUPS_TEMPLATE="${SIMPLE_REPORT_TEMPLATE}" # Report content template
BACKUPS_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}" # Report header template

# Prints backups report
# Globals:
#   BACKUPS_DATA_DIRECTORY   Path to directory  with data
#   BACKUPS_BACKUP_DIRECTORY Path to directory  where backup should be saved
#   BACKUPS_TEMPLATE         Template for report content
#   BACKUPS_HEADER_TEMPLATE  Template for report header
# Arguments:
#   None
# Returns:
#   Report html
function backups {
    local changesCount
    local rsyncResult
    local text

    if [[ ! -d "${BACKUPS_DATA_DIRECTORY}" ]]; then
        >&2 echo "Backups report error: Source directory  ${BACKUPS_DATA_DIRECTORY} doesn't exist"
        return 1
    fi

    if [[ ! -d "${BACKUPS_BACKUP_DIRECTORY}" ]]; then
        >&2 echo "Backups report error: Destination directory  ${BACKUPS_BACKUP_DIRECTORY} doesn't exist"
        return 1
    fi

    rsyncResult=$( rsync -anz --delete --out-format="%o:%f" "${BACKUPS_DATA_DIRECTORY}" "${BACKUPS_BACKUP_DIRECTORY}" )

    # Check the exit code of default command
    if [ $? -gt 0 ]; then
        >&2 echo "Backups report error: rsync command ended with error!"
        return 1
    fi

    changesCount=$( echo "${rsyncResult}" | sed '/^\s*$/d' | wc -l | sed -e 's/^[[:space:]]*//' ) # remove leading whitespaces on MacOS

    if [ "${changesCount}" != "0" ]; then
        text="${changesCount} files are not synchronized to backup!"
    else
        text="Backups are synchronized"
    fi

    printf "${BACKUPS_HEADER_TEMPLATE}" "Backups"
    printf "${BACKUPS_TEMPLATE}" "${text}"
}