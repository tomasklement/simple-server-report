#!/bin/bash

# Prints packages which should be updated (only UBUNTU)
# -----------------------------------------------------
function updates {
    local command="/usr/lib/update-notifier/apt-check"
    
    if ! command -v /usr/lib/update-notifier/apt-check &> /dev/null; then
        return
    fi

    $command --human-readable
}

heading="Updates"
disableHeader=true