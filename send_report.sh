#!/bin/bash

# Encodes UTF8 text in email header to base64
# -------------------------------------------
function encodeHeaderText {
    echo -n "${1}" | base64 | xargs printf "=?UTF-8?B?%s?="
}

# Accepts report (string/lines) and finds longest row and returns its length
# --------------------------------------------------------------------------
function getReportWidth {
    local reportLines
    local ifsBackup
    local maxLineLength
    local lineLength

    ifsBackup=$IFS # save current IFS
    IFS=$'\n'
    reportLines=( $1 )
    IFS=$ifsBackup # restore IFS

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

# Create mail header content, params: recipient email, recipient name
# -------------------------------------------------------------------
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
# ----------------------------------------------
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

# Checks all required configuration is set up
# -------------------------------------------
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

# ------------
# Script start
# ------------

# Change working directory to place where this script is saved (useful when running from CRON)
cd "$(dirname "$0")"

source base_config.sh

if [[ -f "${CUSTOM_CONFIG_FILE_NAME}" ]]; then
	source "${CUSTOM_CONFIG_FILE_NAME}"
fi

validateConfiguration

# Get the text of the report
reportsContent=""

for i in "${!REPORTS[@]}"
do
    :
    disableHeader=false

    # load particular report
    source "${REPORT_SCRIPTS_FOLDER}/${REPORTS[$i]}.sh"

    # load custom config again after loading particular report (to enable overwriting its configuration)
    if [[ -f "${CUSTOM_CONFIG_FILE_NAME}" ]]; then
        source "${CUSTOM_CONFIG_FILE_NAME}"
    fi

    # function with the same name as report is called
    content=$( "${REPORTS[$i]}" )

    reportWidth=$( getReportWidth "${content}" )
    reportWidth=$(( $REPORT_LETTER_WIDTH*$reportWidth ))

    # Skip report when content is empty
    if [ -z "${content}" ]; then
        continue
    fi

    if [ "$disableHeader" = true ] ; then
        tmpContent=$( printf "${REPORT_TEMPLATE}" "${heading}" "${reportWidth}" "" "${content}" )
    else
        header=$( echo -n  "${content}" | head -n 1 )
        content=$( echo -n  "${content}" | tail -n +2 )
        header=$( printf "${REPORT_TEMPLATE_HEADER}"  "${header}" )
        tmpContent=$( printf "${REPORT_TEMPLATE}" "${heading}" "${reportWidth}" "${header}" "${content}" )
    fi

    reportsContent="${reportsContent}${tmpContent}"
done

mailHeaders=$( createMailHeaders )
mailHtml=$( printf "${MAIN_TEMPLATE}" "${EMAIL_SUBJECT}" "${reportsContent}" )
mailBody=$( printf "${MAIL_BODY_TEMPLATE}" "${mailHeaders}" "${mailHtml}" )

# Uncomment for debugging
#echo "${mailBody}"
#echo -n "${mailBody}" > message.eml
#echo -n "${mailHtml}" > message.html

echo "${mailBody}" | sendmail "${EMAIL_RECIPIENT}"
echo "Report sent to ${EMAIL_RECIPIENT}"