#!/bin/bash

PROCESSES_COUNT="5" # count of most demanding processes displayed in the list

# Prints out CPU utilization and most demanding processes
# -------------------------------------------------------
function processes {
    local processesReport
    local count=$((PROCESSES_COUNT+1)) # First line is header
    # Check if df is in version which supports --output param
    if ps --sort -%cpu &> /dev/null ; then
        processesReport=$( ps -e -o user,%cpu,%mem,comm --sort -%cpu | head -"${count}" )
    else
        processesReport=$( ps -e -r -o user,%cpu,%mem,comm | head -"${count}" )
    fi

    echo "${processesReport}"
}

heading="Processes"