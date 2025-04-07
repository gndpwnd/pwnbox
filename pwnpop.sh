#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'
CYAN='\033[0;36m'

unset GREP_OPTIONS

script_date=$(date +"%D")
PWNBOX_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # the directory of where the script is being run, reference to copy notes from
