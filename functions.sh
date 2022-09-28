#!/usr/bin/env bash
#
# Functions

# Writes given message to STDERR
# Globals:
#   None
# Arguments:
#   Error message(s)
# Returns:
#   Error message to STDERR
function ssr::print_error {
  echo "$@" >&2
}

# Throws configuration error code in case any of given variables are empty
# empty or not defined
# Globals:
#   EXIT_CODE_CONFIG_ERROR Exit code for configuration error
# Arguments:
#   Names of variables to be checked
# Returns:
#   None
function ssr::check_required_variables {
  local variable_names

  variable_names=( $( ssr::filter_empty_variable_names "$@" ) )

  if [[ "${#variable_names[@]}" -eq 0 ]]; then
    return
  fi

  variable_names=$( ssr::join_by ", " "${variable_names[@]}" )

  ssr::throw_error "${EXIT_CODE_CONFIG_ERROR}" \
    "Missing required configuration variables: ${variable_names}"
}

# Calls exit with given exit code. Prints given message to STDERR
# Globals:
#   None
# Arguments:
#   Exit code
#   Error message(s)
# Returns:
#   Error message to STDERR
function ssr::throw_error {
  local exit_code="${1}"

  shift
  ssr::print_error "$@"
  exit "${exit_code}"
}

# Filters given variable names and returns variable names of variables which are
# empty or not defined
# Globals:
#   None
# Arguments:
#   Names of variables to be checked
# Returns:
#   Names of variables which are empty or not defined
function ssr::filter_empty_variable_names {
  local config_var_name
  local missing_items

  missing_items=()
  for config_var_name in "$@"
  do
    if [[ -z "${!config_var_name}" ]]; then
        missing_items+=( "${config_var_name}" )
    fi
  done

  echo "${missing_items[@]}"
}

# Encodes UTF8 text in email header to base64
# Globals:
#   None
# Arguments:
#   Text to be used in email header
# Returns:
#   Encoded text suitable for mail header
function ssr::encode_mail_header_string {
  echo -n "${1}" \
    | base64 \
    | xargs printf "=?UTF-8?B?%s?="
}

# Returns length of longest line (count of characters) in text with new lines
# Globals:
#   None
# Arguments:
#   Text to analyze
# Returns:
#   Length
function ssr::get_report_width {
  local IFS
  local report_lines
  local max_line_length
  local line_ength

  IFS=$'\n'
  report_lines=( $1 )
  max_line_length=0
  for i in "${!report_lines[@]}"
  do
    :
    line_ength=$(
      echo "${report_lines[$i]}" \
        | wc -c \
        | sed -e 's/^[[:space:]]*//'
    )

    if [[ "${line_ength}" -ge "${max_line_length}" ]]; then
      max_line_length="${line_ength}"
    fi
  done

  echo -n "${max_line_length}"
}

# Create mail header with users name (optional) and his email
# Globals:
#   None
# Arguments:
#   Users email
#   Users name (optional)
# Returns:
#   Header with encoded users name, i.e.: JohnDoe<john@doe.com>
function ssr::create_mail_header_content {
  local header_text

  if [[ -z "${2}" ]]; then
    echo -n "${1}"
  else
    header_text=$( ssr::encode_mail_header_string "${2}" )
    echo  -n "${header_text}<${1}>"
  fi
}

# Create mail headers according to configuration
# Globals:
#   EMAIL_RECIPIENT      Recipient name
#   EMAIL_RECIPIENT_NAME Recipient email
#   EMAIL_SENDER         Sender email
#   EMAIL_SENDER_NAME    Sender name
#   EMAIL_SUBJECT        Email subject
#   EMAIL_REPLY_TO       Reply-to email
#   EMAIL_REPLY_TO_NAME  Reply-to name
# Arguments:
#   None
# Returns:
#   Headers suitable for email body
function ssr::create_mail_headers {
  local nl
  local to
  local from
  local header
  local headers

  ssr::check_required_variables "EMAIL_RECIPIENT" "EMAIL_RECIPIENT_NAME" \
    "EMAIL_SENDER" "EMAIL_SENDER_NAME"

  nl=$'\n'
  to=$( ssr::create_mail_header_content "${EMAIL_RECIPIENT}" \
    "${EMAIL_RECIPIENT_NAME}" )
  from=$( ssr::create_mail_header_content "${EMAIL_SENDER}" \
    "${EMAIL_SENDER_NAME}" )
  headers="From: ${from}${nl}To: ${to}${nl}"

  if [[ -n "${EMAIL_SUBJECT}" ]]; then
    header=$( ssr::encode_mail_header_string "${EMAIL_SUBJECT}" )
    headers="${headers}Subject: ${header}${nl}"
  fi

  if [[ -n "${EMAIL_REPLY_TO}" ]]; then
    header=$( ssr::create_mail_header_content "${EMAIL_REPLY_TO}" \
      "${EMAIL_REPLY_TO_NAME}" )
    headers="${headers}Reply-To: ${header}${nl}"
  fi

  echo "${headers}"
}

# Detect position of spaces which are common for all lines of multi-line string
# Globals:
#   None
# Arguments:
#   Text
# Returns:
#   Array of positions (string indexes)
function ssr::detect_spaces_positions {
  local report_line
  local char_pos
  local line_num
  local IFS
  local report_lines
  local spaces_positions
  local filtered_spaces_positions

  IFS=$'\n'
  report_lines=( $1 )
  spaces_positions=()
  filtered_spaces_positions=()

  for line_num in "${!report_lines[@]}"
  do
    report_line="${report_lines[$line_num]}"
    filtered_spaces_positions=()

    # Find spaces positions in current line
    for char_pos in $(seq 1 ${#report_line})
    do
      if [[ "${report_line:char_pos-1:1}" == " " ]]; then
        # For first line just save all detected space positions
        if [[ $line_num -eq 0 ]]; then
          spaces_positions+=( $char_pos )
        else
          # For lines no. > 0 save only spaces positions which were also
          # detected in previous lines
          if ssr::is_number_in_array $char_pos "${spaces_positions[*]}"; then
            filtered_spaces_positions+=( $char_pos )
          fi
        fi
      fi
    done

    # For lines no. > 0 always save actually filtered array of spaces positions
    if [[ $line_num -gt 0 ]]; then
      spaces_positions=( "${filtered_spaces_positions[@]}" )
    fi
  done

  echo "${spaces_positions[@]}"
}

# Checks if numeric value is in array
# Globals:
#   None
# Arguments:
#   Number
#   Array of nubers
# Returns:
#   True or false
function ssr::is_number_in_array {
  local value
  local values

  values=( $(echo "${2}") )

  for value in "${values[@]}"
  do
    if [[ "${1}" -eq "${value}" ]]; then
      true
      return
    fi
  done

  false
}

# Checks if given string is in array
# Globals:
#   None
# Arguments:
#   String (needle)
#   Array (haystack)
# Returns:
#   Is in array
function ssr::is_string_in_array {
  local needle
  local haystack
  local string

  needle="${1}"

  shift

  haystack=( "$@" )

  for string in "${haystack[@]}"
    do
      if [[ "${needle}" == "${string}" ]]; then
        true
        return
      fi
    done

  false
}

# Joins array values to string separated by given separator
# Globals:
#   None
# Arguments:
#   Separator (one or more chars)
#   Array of values
# Returns:
#   Joined string
function ssr::join_by {
  local separator
  local item
  local result
  local add_separator

  separator="${1}"
  result=""
  add_separator=false

  shift

  for item in "$@"
  do
    if [[ "${add_separator}" = false ]]; then
      result="${item}"
      add_separator=true
    else
      result="${result}${separator}${item}"
    fi
  done

  echo -n "${result}"
}

# Get count of substrings in given string
# Globals:
#   None
# Arguments:
#   String (haystack)
#   Substring (needle)
# Returns:
#   Count of occurences
function ssr::get_strings_count {
  echo "${1}" \
    | tr " " "\n" \
    | grep -c "${2}"
}

# Splits report row to array of cell values using common spaces positions array
# Globals:
#   None
# Arguments:
#   Report line
#   Array of spaces positions
# Returns:
#   Array of cell values
function ssr::parse_row {
  local char_pos
  local char
  local cell_content
  local previous
  local cells
  local spaces_positions

  previous="space"
  cells=()
  spaces_positions=( $(echo "${2}") )

  for char_pos in $(seq 1 ${#1})
  do
    char="${1:char_pos-1:1}"
    if ssr::is_number_in_array $char_pos "${spaces_positions[*]}"; then
      if [[ "${previous}" == "cell" ]]; then
        cells+=( "${cell_content}" )
      fi
      previous="space"
    else
      if [[ "${previous}" == "space" ]]; then
        cell_content="${char}"
      else
        cell_content="${cell_content}${char}"
      fi
      previous="cell"
    fi
  done

  if [[ "${previous}" == "cell" ]]; then
    cells+=( "${cell_content}" )
  fi

  ssr::join_by $'\n' "${cells[@]}"
}

# Parses textual report result and renders the data to html table
# Globals:
#   None
# Arguments:
#   Textual report result
#   Table template with %s placeholder which will be replaced by table rows
#   Table header row template with %s placeholders which will be replaced by
#     first row cells data
#   Table data row template with %s placeholders which will be replaced by row
#     cells data
# Returns:
#   Report formatted as html table
function ssr::render_table {
  local row_cells
  local row_index
  local row_template
  local row_html
  local placeholders_count
  local table_html
  local spaces_positions
  local IFS
  local report_rows

  table_html=""
  spaces_positions=( $(ssr::detect_spaces_positions "${1}") )
  IFS=$'\n'
  report_rows=( $1 )

  for row_index in "${!report_rows[@]}"
  do
    row_cells=$(
      ssr::parse_row "${report_rows[$row_index]}" "${spaces_positions[*]}"
    )
    row_cells=( $row_cells )

    if [[ "${row_index}" -eq 0 ]]; then
      row_template="${3}"
    else
      row_template="${4}"
    fi

    # Slice cells which doesn't fit into template (count of %s placeholders)
    placeholders_count=$( ssr::get_strings_count "${row_template}" "%s" )
    row_html=$(
      printf "${row_template}" "${row_cells[@]:0:$placeholders_count}"
    )
    table_html="${table_html}${row_html}"
  done

  printf "${2}" "${table_html}"
}

# Prints arguments error message with script common help
# Globals:
#   None
# Arguments:
#   Text
# Returns:
#   Given text with common help text
function ssr::print_arguments_error {
  printf "${1} \n\n" >&2
  ssr::print_arguments_error_help
}

# Prints script usage help
# Globals:
#   None
# Arguments:
#   Text
# Returns:
#   Help text
function ssr::print_arguments_error_help {
  local text

  text=$'Usage: -o=<type>\n'
  text+=$'Possible output types:\n'
  text+=$'   eml      Prints report in eml format to stdout\n'
  text+=$'   html     Prints report in html format to stdout\n'
  text+=$'   sendmail Creates report in eml format and sends directly by '
  text+=$'sendmail (does not print anything to stdout)\n'

  echo "${text}" >&2
}

# Gets argument of script option "-o"
# Prints help messages to stderr in case it cannot find the "-o" option or its
#   argument
# Globals:
#   None
# Arguments:
#   All script options ($@)
# Returns:
#   Output type or empty string in case the output type wasn't found
function ssr::get_output_type_from_script_options {
  local option
  local output_type
  local valid_output_type
  local valid_output_types

  valid_output_types=( "html" "eml" "sendmail")

  # Case when no options provided - just print help to stderr
  if [[ -z "$@" ]]; then
    ssr::print_arguments_error_help
    return
  fi

  # Check options and try to find -o option
  while getopts ":o:" option; do
    case ${option} in
      o )
        output_type="${OPTARG//=}"
        ;;
      \? )
        ssr::print_arguments_error "Invalid option: \"$OPTARG\""
        return
        ;;
      : )
        ssr::print_arguments_error \
          "Invalid option: \"${OPTARG}\" requires an argument (type)"
        return
        ;;
    esac
  done

  if ! ssr::is_string_in_array "${output_type}" "${valid_output_types[@]}"; then
    ssr::print_arguments_error \
      "Invalid option: -o unsupported output type \"${output_type}\""
    return
  fi

  echo "${output_type}"
}