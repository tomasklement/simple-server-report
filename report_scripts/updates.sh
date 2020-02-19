#!/usr/bin/env bash
#
# Updates report function. Prints count of available updates

# Report header template (inherited)
UPDATES_HEADER_TEMPLATE="${REPORT_HEADER_TEMPLATE}"
# Report content template (inherited)
UPDATES_TEMPLATE="${SIMPLE_REPORT_TEMPLATE}"

# Prints packages which should be updated (only UBUNTU)
# Globals:
#   UPDATES_HEADER_TEMPLATE Report header template
#   UPDATES_TEMPLATE        Report content template
# Arguments:
#   None
# Returns:
#   Report html
function ssr::updates {
  local command_result
  local error_text

  command_result=$(
    /usr/lib/update-notifier/apt-check --human-readable 2> /dev/null
  )

  if [[ $? -gt 0 ]]; then
    error_text="Updates report error: \"apt-check\" is not supported in current"
    error_text+=" system!"
    ssr::print_error "${error_text}"
    return 1
  fi

  printf "${UPDATES_HEADER_TEMPLATE}" "Updates"
  printf "${UPDATES_TEMPLATE}" "${command_result}"
}