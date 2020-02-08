#!/usr/bin/env bash

# Source backup directory  - with slash at the end!
BACKUPS_DATA_DIRECTORY="./test/one/"
# Destination backup directory  - no slash at the end!
BACKUPS_BACKUP_DIRECTORY="./test/two"
# Report content template
BACKUPS_TEMPLATE="${SIMPLE_REPORT_TEMPLATE}"
# Report header template
BACKUPS_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}"

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
function ssr::backups {
  local changes_count
  local rsync_result
  local text

  if [[ ! -d "${BACKUPS_DATA_DIRECTORY}" ]]; then
    text="Backups report error: Source directory ${BACKUPS_DATA_DIRECTORY} "
    text+="doesn't exist"
    ssr::print_error "${text}"
    return 1
  fi

  if [[ ! -d "${BACKUPS_BACKUP_DIRECTORY}" ]]; then
    text="Backups report error: Destination directory "
    text+="${BACKUPS_BACKUP_DIRECTORY} doesn't exist"
    ssr::print_error "${text}"
    return 1
  fi

  rsync_result=$(
    rsync -anz --delete --out-format="%o:%f" "${BACKUPS_DATA_DIRECTORY}" \
      "${BACKUPS_BACKUP_DIRECTORY}"
  )

  # Check the exit code of default command
  if [[ $? -gt 0 ]]; then
    ssr::print_error "Backups report error: rsync command ended with error!"
    return 1
  fi

  # remove leading whitespaces on MacOS
  changes_count=$(
    echo "${rsync_result}" \
      | sed '/^\s*$/d' \
      | wc -l \
      | sed -e 's/^[[:space:]]*//'
  )

  if [[ "${changes_count}" != "0" ]]; then
    text="${changes_count} files are not synchronized to backup!"
  else
    text="Backups are synchronized"
  fi

  printf "${BACKUPS_HEADER_TEMPLATE}" "Backups"
  printf "${BACKUPS_TEMPLATE}" "${text}"
}