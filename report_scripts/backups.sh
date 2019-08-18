#!/bin/bash

DATA_FOLDER="./test/one/" # Source backup folder - with slash at end!
BACKUP_FOLDER="./test/two" # Destination backup folder - no slash at end!

# Prints out current status of backups
# ------------------------------------
function backups {
    local changesCount

    if [[ ! -d "${DATA_FOLDER}" ]]; then
        echo "Backups source folder ${DATA_FOLDER} doesn't exist"
        return
    fi

    if [[ ! -d "${BACKUP_FOLDER}" ]]; then
        echo "Backups destination folder ${BACKUP_FOLDER} doesn't exist"
        return
    fi

    changesCount=$( rsync -anz --delete --out-format="%o:%f" "${DATA_FOLDER}" "${BACKUP_FOLDER}" | wc -l )
    changesCount=$( echo "${changesCount}" | sed -e 's/^[[:space:]]*//') # remove leading whitespaces on MacOS

    if [ "${changesCount}" != "0" ]; then
        echo "${changesCount} files are not synchronized to backup!"
    else
        echo "Backups are synchronized"
    fi
}

heading="Backups"
disableHeader=true