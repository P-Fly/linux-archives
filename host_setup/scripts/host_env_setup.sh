#!/bin/bash

cmd="${0}"
option=${1:-"--help"}
log_file="setup.log"
uid=`id -u`

if [ "${option}" = "--help" ]
then
    echo ""
    echo "The Script will perform initial setup of host machine (requires root privileges)."
    echo ""
    echo "usage: ${0} [[--help] [--setup]]"
    echo ""
    echo "optional arguments:"
    echo "  --help          show this help message and exit."
    echo "  --setup         check that host has all necessary dependencies installed for building."
    echo ""
    exit
fi

if [ "${option}" != "--setup" ]
then
    echo "${cmd}: unrecognized option '${option}'."
    echo "Try '${cmd} --help' for more information."
    exit
fi

# Check the bash environment
if [ -z "${BASH_VERSION}" ]
then
    echo "This script requires bash environment."
    exit
fi

# Check the root privileges
if [ "${uid}" != "0" ]
then
    echo "This script requires root privileges."
    exit
fi

# Create and clear the log file
:> "${log_file}"

source apt_packages_setup.sh

source alternatives_setup.sh

source vim_setup.sh
