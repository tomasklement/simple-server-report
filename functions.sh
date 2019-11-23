#!/usr/bin/env bash

# Encodes UTF8 text in email header to base64
# Globals:
#   None
# Arguments:
#   Text to be used in email header
# Returns:
#   Encoded text suitable for mail header
function encodeHeaderText {
    echo -n "${1}" | base64 | xargs printf "=?UTF-8?B?%s?="
}

# Returns length of longest line (count of characters) in text with new lines
# Globals:
#   None
# Arguments:
#   Text to analyze
# Returns:
#   Length
function getReportWidth {
    local IFS=$'\n'
    local reportLines=( $1 )
    local maxLineLength
    local lineLength

    maxLineLength=0
    for i in "${!reportLines[@]}"
    do
        :
        lineLength=$( echo "${reportLines[$i]}" | wc -c | sed -e 's/^[[:space:]]*//' )
        if [ "${lineLength}" -ge "${maxLineLength}" ]; then
            maxLineLength=$lineLength
        fi
    done

    echo -n "${maxLineLength}"
}

# Create mail header with users name (optional) and his email
# Globals:
#   None
# Arguments:
#   Users email
#   Users name (optional)
# Returns:
#   Header with encoded users name, i.e.: JohnDoe<john@doe.com>
function createMailHeaderContent {
    local headerContent
    local headerText

    if [ -z "${2}" ]; then
        echo -n "${1}"
    else
        headerText=$( encodeHeaderText "${2}" )
        echo  -n "${headerText}<${1}>"
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
function createMailHeaders {
    local nl=$'\n'
    local to=$( createMailHeaderContent "${EMAIL_RECIPIENT}" "${EMAIL_RECIPIENT_NAME}" )
    local from=$( createMailHeaderContent "${EMAIL_SENDER}" "${EMAIL_SENDER_NAME}" )
    local header
    local headers="From: ${from}${nl}To: ${to}${nl}"

    if [[ ! -z "${EMAIL_SUBJECT}" ]]; then
        header=$( encodeHeaderText "${EMAIL_SUBJECT}" )
        headers="${headers}Subject: ${header}${nl}"
    fi

    if [[ ! -z "${EMAIL_REPLY_TO}" ]]; then
        header=$( createMailHeaderContent "${EMAIL_REPLY_TO}" "${EMAIL_REPLY_TO_NAME}" )
        headers="${headers}Reply-To: ${header}${nl}"
    fi

    echo "${headers}"
}

# Checks all required configuration is set up. If not, it exits
# Globals:
#   EMAIL_RECIPIENT Recipient name
#   EMAIL_SENDER    Sender email
# Arguments:
#   None
# Returns:
#   None
function validateConfiguration {
    if [ -z "${EMAIL_RECIPIENT}" ]; then
        echo "Missing configuration EMAIL_RECIPIENT"
		exit 1
    fi

    if [ -z "${EMAIL_SENDER}" ]; then
        echo "Missing configuration EMAIL_SENDER"
		exit 1
    fi
}

# Detect position of spaces which are common for all lines of multi-line string
# Globals:
#   None
# Arguments:
#   Text
# Returns:
#   Array of positions (string indexes)
function detectSpacesPositions {
    local reportLine
    local charPos
    local lineNum
    local IFS=$'\n'
    local reportLines=( $1 )
    local spacesPositions=()
    local filteredSpacesPositions=()

    for lineNum in "${!reportLines[@]}"
    do
        reportLine="${reportLines[$lineNum]}"
        filteredSpacesPositions=()

        # Find spaces positions in current line
        for charPos in $(seq 1 ${#reportLine})
        do
            if [ "${reportLine:charPos-1:1}" == " " ] ; then
                # For first line just save all detected space positions
                if [ $lineNum -eq 0 ] ; then
                    spacesPositions+=($charPos)
                else
                    # For lines no. > 0 save only spaces positions which were also detected in previous lines
                    if isNumberInArray $charPos "${spacesPositions[*]}"; then
                        filteredSpacesPositions+=($charPos)
                    fi
                fi
            fi
        done

        # For lines no. > 0 always save actually filtered array of spaces positions
        if [ $lineNum -gt 0 ] ; then
            spacesPositions=( "${filteredSpacesPositions[@]}" )
        fi
    done

    echo "${spacesPositions[@]}"
}

# Checks if numeric value is in array
# Globals:
#   None
# Arguments:
#   Number
#   Array of nubers
# Returns:
#   True or false
function isNumberInArray {
    local value
    local values=( `echo "${2}"` )

    for value in "${values[@]}"
    do
        if [ "${1}" -eq "${value}" ]; then
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
function isStringInArray {
    local needle="${1}"
    local haystack
    local string

    shift

    haystack=("$@")

    for string in "${haystack[@]}"
        do
            if [ "${needle}" == "${string}" ]; then
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
#   Separator
#   Array of values
# Returns:
#   Joined string
function joinBy {
    local IFS="$1"
    shift
    echo "$*"
}
# Get count of substrings in given string
# Globals:
#   None
# Arguments:
#   String (haystack)
#   Substring (needle)
# Returns:
#   Count of occurences
function getStringsCount {
    echo "${1}" | tr " " "\n" | grep -c "${2}"
}

# Splits report row to array of cell values using common spaces positions array
# Globals:
#   None
# Arguments:
#   Report line
#   Array of spaces positions
# Returns:
#   Array of cell values
function parseRow {
    local charPos
    local char
    local cellContent
    local previous="space"
    local cells=()
    local spacesPositions=( `echo "${2}"` )

    for charPos in $(seq 1 ${#1})
    do
        char="${1:charPos-1:1}"
        if isNumberInArray $charPos "${spacesPositions[*]}"; then
            if [ "${previous}" == "cell" ]; then
                cells+=( "${cellContent}" )
            fi
            previous="space"
        else
            if [ "${previous}" == "space" ]; then
                cellContent="${char}"
            else
                cellContent="${cellContent}${char}"
            fi
            previous="cell"
        fi
    done

    if [ "${previous}" == "cell" ]; then
        cells+=( "${cellContent}" )
    fi

    joinBy $'\n' "${cells[@]}"
}

# Parses textual report result and renders the data to html table
# Globals:
#   None
# Arguments:
#   Textual report result
#   Table template with %s placeholder which will be replaced by table rows
#   Table header row template with %s placeholders which will be replaced by first row cells data
#   Table data row template with %s placeholders which will be replaced by row cells data
# Returns:
#   Report formatted as html table
function renderTable {
    local rowCells
    local rowIndex
    local rowTemplate
    local rowHtml
    local placeholdersCount
    local tableHtml=""
    local spacesPositions=( `detectSpacesPositions "${1}"` )
    local IFS=$'\n'
    local reportRows=( $1 )

    for rowIndex in "${!reportRows[@]}"
    do
        rowCells=$( parseRow "${reportRows[$rowIndex]}" "${spacesPositions[*]}" )
        rowCells=( $rowCells )

        if [ "${rowIndex}" -eq 0 ]; then
            rowTemplate="${3}"
        else
            rowTemplate="${4}"
        fi

        # Slice cells which doesn't fit into template (count of %s placeholders)
        placeholdersCount=$( getStringsCount "${rowTemplate}" "%s" )
        rowHtml=$( printf "${rowTemplate}" "${rowCells[@]:0:$placeholdersCount}" )
        tableHtml="${tableHtml}${rowHtml}"
    done

    printf "${2}" "${tableHtml}"
}

# Prints given text and script common help
# Globals:
#   None
# Arguments:
#   Text
# Returns:
#   Given text with common help text
function printTextWithHelp {
    printf "${1} \n\n"
    printHelp
}

# Prints script usage help
# Globals:
#   None
# Arguments:
#   Text
# Returns:
#   Help text
function printHelp {
    echo "Usage: -o=<type>"
    echo "Possible output types:"
    echo "   eml      Prints report in eml format to stdout"
    echo "   html     Prints report in html format to stdout"
    echo "   sendmail Creates report in eml format and sends directly by sendmail (does not print anything to stdout)"
}

# Gets argument of script option "-o"
# Prints help messages to stderr in case it cannot find the "-o" option or its argument
# Globals:
#   None
# Arguments:
#   All script options ($@)
# Returns:
#   Output type or empty string in case the output type wasn't found
function getOutputTypeFromScriptOptions {
    local option
    local outputType
    local validOutputType
    local validOutputTypes=( "html" "eml" "sendmail")

    # Case when no options provided - just print help to stderr
    if [ -z "$@" ]; then
        >&2 printHelp
        return
    fi

    # Check options and try to find -o option
    while getopts ":o:" option; do
        case ${option} in
            o )
                outputType="${OPTARG//=}"
            ;;
            \? )
                >&2 printTextWithHelp "Invalid option: \"$OPTARG\""
                return
            ;;
            : )
                >&2 printTextWithHelp "Invalid option: \"${OPTARG}\" requires an argument (type)"
                return
            ;;
        esac
    done

    if ! isStringInArray "${outputType}" "${validOutputTypes[@]}"; then
        >&2 printTextWithHelp "Invalid option: -o unsupported output type \"${outputType}\""
        return
    fi

    echo "${outputType}"
}