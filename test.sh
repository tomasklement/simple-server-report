#!/usr/bin/env bash
# Exit code for configuration error
readonly EXIT_CODE_CONFIG_ERROR=2
readonly SOME_CONST="heloj"

source functions.sh

function child {
  echo "LV: ${locval}"
}

function parent {
  local locval

  locval="heee"

  child
}

parent