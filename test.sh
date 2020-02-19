#!/usr/bin/env bash
# Exit code for configuration error
readonly EXIT_CODE_CONFIG_ERROR=2
readonly SOME_CONST="heloj"

source functions.sh




function some_func {
  ssr::validate_config "SOME_CONSTX"

  echo "nice report"
}

output=$( some_func )
result="$?"

echo "RES: ${result}"
echo "OUT: ${output}"

if [[ "${result}" -eq 2 ]]; then
  exit EXIT_CODE_CONFIG_ERROR
  echo "you should not see this"
elif [[ "${result}" -eq 0 ]]; then
  echo "using this out: ${output}"
else
  echo "some other error"
fi
