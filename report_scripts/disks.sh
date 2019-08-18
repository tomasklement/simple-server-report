#!/bin/bash

DISKS_FILTER_REGEXP="dev" # Filter displayed disks by this regular expression (empty string = no filtering)

# Prints out available/occupied space on disks
# --------------------------------------------
function disks {
    local changesCount
    local dfReport
    local dfReportLines
    local ifsBackup
    local dfLinesCount
    local reportContent=""
    local nl=$'\n'
    local resultDisksCount=0

    # Check if df is in version which supports --output param
    if df --output &> /dev/null ; then
        dfReport=$( df -h --output=source,used,avail,pcent )
    else
        dfReport=$( df -h )
    fi

    ifsBackup=$IFS # save current IFS
    IFS=$'\n'
    dfReportLines=( $dfReport )
    IFS=$ifsBackup # restore IFS

    for i in "${!dfReportLines[@]}"
    do
        :
        # Print header line
        if [ $i -eq 0 ]; then
            reportContent="${reportContent}${dfReportLines[$i]}${nl}"
        fi

        # Print lines which matches regExp
        if [[ -z "${DISKS_FILTER_REGEXP}" || "${dfReportLines[$i]}" =~ $DISKS_FILTER_REGEXP ]]; then
            reportContent="${reportContent}${dfReportLines[$i]}${nl}"
            resultDisksCount=$(( resultDisksCount + 1 ))
        fi
    done

    echo "${reportContent}"

    if [ 0 -eq $resultDisksCount ]; then
        echo "No disks found"
    fi
}

heading="Disks"