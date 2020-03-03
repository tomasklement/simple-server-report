#!/usr/bin/env bash
#
# Backups report function. Prints count of differences between two directories

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
#   Report html to STDOUT or error message to STDERR
function ssr::backups {
  local changes_count
  local rsync_result
  local rsync_exit_code
  local text

  ssr::backups_validate_configuration

  rsync_result=$(
    rsync -anz --delete --out-format="%o:%f" "${BACKUPS_DATA_DIRECTORY}" \
      "${BACKUPS_BACKUP_DIRECTORY}" 2>&1
  )

  rsync_exit_code="$?"

  # Check the exit code of default command
  if [[ "${rsync_exit_code}" -gt 0 ]]; then
    ssr::throw_error "${rsync_exit_code}" "RSync error: ${rsync_result}"
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

# Validates all configured values. Checks existence of direcoties. Calls exit in
# case error is found
# Globals:
#   BACKUPS_DATA_DIRECTORY   Path to directory  with data
#   BACKUPS_BACKUP_DIRECTORY Path to directory  where backup should be saved
#   BACKUPS_TEMPLATE         Template for report content
#   BACKUPS_HEADER_TEMPLATE  Template for report header
#   EXIT_CODE_CONFIG_ERROR   Exit code for configuration error
# Arguments:
#   None
# Returns:
#   Error messages to STDERR
function ssr::backups_validate_configuration {
  local text
  local empty_config_var_names
  local errors

  empty_config_var_names=( $( ssr::filter_empty_variable_names \
    "BACKUPS_DATA_DIRECTORY" "BACKUPS_BACKUP_DIRECTORY" "BACKUPS_TEMPLATE" \
    "BACKUPS_HEADER_TEMPLATE") )

  # TODO show missing error

  if ! ssr::is_string_in_array "${BACKUPS_DATA_DIRECTORY}" \
      "${empty_config_var_names[@]}" && \
      [[ ! -d "${BACKUPS_DATA_DIRECTORY}" ]] && \
      [[ ! -r "${BACKUPS_DATA_DIRECTORY}" ]]; then
    text="Source directory \"${BACKUPS_DATA_DIRECTORY}\" defined in "
    text+="configuration variable BACKUPS_DATA_DIRECTORY is not accessible"
    errors+=( "${text}" )
  fi

  if ! ssr::is_string_in_array "${BACKUPS_BACKUP_DIRECTORY}" \
      "${empty_config_var_names[@]}" && \
      [[ ! -d "${BACKUPS_BACKUP_DIRECTORY}" ]] && \
      [[ ! -w "${BACKUPS_BACKUP_DIRECTORY}" ]]; then
    text="Destination directory \"${BACKUPS_BACKUP_DIRECTORY}\" defined in "
    text+="configuration variable BACKUPS_BACKUP_DIRECTORY is not accessible"
    errors+=( "${text}" )
  fi

  text=$( ssr::join_by $'\n' "${errors[@]}" )

  if [[ ! -z "${text}" ]]; then
    ssr::throw_error "${EXIT_CODE_CONFIG_ERROR}" "${text}"
  fi
}