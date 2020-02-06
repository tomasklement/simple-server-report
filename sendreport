#!/usr/bin/env bash

# ------------
# Script start
# ------------

# Change working directory to place where this script is saved (useful when running from CRON)
cd "$(dirname "$0")"

source functions.sh
source base_config.sh


if [[ -f "${CUSTOM_CONFIG_FILE_NAME}" ]]; then
	source "${CUSTOM_CONFIG_FILE_NAME}"
fi

validateConfiguration

# Get output type from script options, perform validation of script options
outputType=$( getOutputTypeFromScriptOptions "$@" )
if [ -z "${outputType}" ]; then
    exit 1
fi

# Get the text of the report
reportsContent=""

for i in "${!REPORTS[@]}"
do
    :
    # Load particular report
    source "${REPORT_SCRIPTS_DIRECTORY}/${REPORTS[$i]}.sh"

    # Load custom config again after loading particular report (to enable overwriting its configuration)
    if [[ -f "${CUSTOM_CONFIG_FILE_NAME}" ]]; then
        source "${CUSTOM_CONFIG_FILE_NAME}"
    fi

    # Function with the same name as report is called
    reportContent=$( "${REPORTS[$i]}" )

    # In case the report ended with error exit status, show warning message
    if [ $? -gt 0 ]; then
        reportContent=$( printf "${REPORT_ERROR_TEMPLATE}" "${REPORTS[$i]}" )
    fi

    reportsContent="${reportsContent}${reportContent}"
done

mailHeaders=$( createMailHeaders )
mailHtml=$( printf "${MAIN_TEMPLATE}" "${EMAIL_SUBJECT}" "${reportsContent}" )
mailBody=$( printf "${MAIL_BODY_TEMPLATE}" "${mailHeaders}" "${mailHtml}" )

# Send email
case ${outputType} in
    "html" )
        echo -n "${mailHtml}"
    ;;
    "eml" )
        echo -n "${mailBody}"
    ;;
    "sendmail" )
        echo "${mailBody}" | sendmail "${EMAIL_RECIPIENT}"
        echo "Report sent to ${EMAIL_RECIPIENT}"
    ;;
esac