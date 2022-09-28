#!/usr/bin/env bash
#
# Synchronize report function. Prints count of differences between two
# directories

# Source directory  - with slash at the end!
SYNC_SOURCE_DIRECTORY="./test/one/"
# Destination directory  - no slash at the end!
SYNC_DEST_DIRECTORY="./test/two"
# Report content template
SYNC_TEMPLATE="${SIMPLE_REPORT_TEMPLATE}"
# Report header template
SYNC_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}"

# Prints backups report
# Globals:
#   SYNC_SOURCE_DIRECTORY Path to directory  with data
#   SYNC_DEST_DIRECTORY   Path to directory  where backup should be saved
#   SYNC_TEMPLATE         Template for report content
#   SYNC_HEADER_TEMPLATE  Template for report header
# Arguments:
#   None
# Returns:
#   Report html to STDOUT or error message to STDERR
function ssr::sync {
  local changes_count
  local rsync_result
  local rsync_exit_code
  local text

  ssr::sync_validate_configuration

  rsync_result=$(
    rsync -anz --delete --out-format="%o:%f" "${SYNC_SOURCE_DIRECTORY}" \
      "${SYNC_DEST_DIRECTORY}" 2>&1
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

  # decrease by one line which is always present
  changes_count=$((changes_count-1))

  if [[ "${changes_count}" != "0" ]]; then
    text="${changes_count} files are not synchronized!"
  else
    text="Directories are synchronized"
  fi

  printf "${SYNC_HEADER_TEMPLATE}" "Folders difference"
  printf "${SYNC_TEMPLATE}" "${text}"
}

# Validates all configured values. Checks existence of direcoties. Calls exit in
# case error is found
# Globals:
#   SYNC_SOURCE_DIRECTORY   Path to directory  with data
#   SYNC_DEST_DIRECTORY Path to directory  where backup should be saved
#   SYNC_TEMPLATE         Template for report content
#   SYNC_HEADER_TEMPLATE  Template for report header
#   EXIT_CODE_CONFIG_ERROR   Exit code for configuration error
# Arguments:
#   None
# Returns:
#   Error messages to STDERR
function ssr::sync_validate_configuration {
  local text
  local empty_config_var_names
  local errors

  ssr::check_required_variables "SYNC_SOURCE_DIRECTORY" "SYNC_DEST_DIRECTORY" \
    "SYNC_TEMPLATE" "SYNC_HEADER_TEMPLATE"

  errors=()

  if [[ ! -d "${SYNC_SOURCE_DIRECTORY}" ]] && \
      [[ ! -r "${SYNC_SOURCE_DIRECTORY}" ]]; then
    text="Source directory \"${SYNC_SOURCE_DIRECTORY}\" defined in "
    text+="configuration variable SYNC_SOURCE_DIRECTORY is not accessible"
    errors+=( "${text}" )
  fi

  if [[ ! -d "${SYNC_DEST_DIRECTORY}" ]] && \
      [[ ! -w "${SYNC_DEST_DIRECTORY}" ]]; then
    text="Destination directory \"${SYNC_DEST_DIRECTORY}\" defined in "
    text+="configuration variable SYNC_DEST_DIRECTORY is not accessible"
    errors+=( "${text}" )
  fi

  text=$( ssr::join_by $'\n' "${errors[@]}" )

  if [[ -n "${text}" ]]; then
    ssr::throw_error "${EXIT_CODE_CONFIG_ERROR}" "${text}"
  fi
}