#!/usr/bin/env bash
# Exit code for configuration error
readonly EXIT_CODE_CONFIG_ERROR=2
readonly SOME_CONST="heloj"

source functions.sh

source report_scripts/backups.sh

BACKUPS_BACKUP_DIRECTORY=""
BACKUPS_DATA_DIRECTORY=""

ssr::backups_validate_configuration

