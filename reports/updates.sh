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
  local exit_code

  val::check_required_variables "UPDATES_HEADER_TEMPLATE" "UPDATES_TEMPLATE"

  command_result=$(
    /usr/lib/update-notifier/apt-check --human-readable | \
    grep "updates can be applied" 2>&1
  )

  exit_code="$?"

  if [[ "${exit_code}" -gt 0 ]]; then
    error_text="Command \"apt-check\" is not supported in current system"
    err::throw "${exit_code}" "${command_result}"
  fi

  printf "${UPDATES_HEADER_TEMPLATE}" "Updates"
  printf "${UPDATES_TEMPLATE}" "${command_result}"
}