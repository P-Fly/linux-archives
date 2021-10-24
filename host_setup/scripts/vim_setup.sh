#!/bin/bash

if [ -z "${log_file}" ]
then
    log_file="setup.log"
fi

echo "Installing vim plugins:"
