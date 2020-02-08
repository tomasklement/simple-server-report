#!/usr/bin/env bash

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
function updates {
  local commandResult
  local errorText

  commandResult=$(
    /usr/lib/update-notifier/apt-check --human-readable 2> /dev/null
  )

  if [ $? -gt 0 ]; then
    errorText="Updates report error: \"apt-check\" is not supported in current "
    errorText+="system!"
    printError "${errorText}"
    return 1
  fi

  printf "${UPDATES_HEADER_TEMPLATE}" "Updates"
  printf "${UPDATES_TEMPLATE}" "${commandResult}"
}