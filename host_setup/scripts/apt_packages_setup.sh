#!/bin/bash

if [ -z "${log_file}" ]
then
    log_file="setup.log"
fi

echo "Installing apt packages:"

while read line
do
    # Remove extra whitespace from an ASCII line
    line=`echo "${line}" | sed -e 's/^[ ]*//g' | sed -e 's/[ ]*$//g'`

    # Ignore comments and blank line
    m=`echo "${line}" | grep -v ^#`
    if [ ! "${m}" ]
    then
        continue
    fi

    # Ignore the already installed software
    echo "********************************************************************" >>${log_file}
    echo "* Search ${line} in the repositories:"                                >>${log_file}
    echo "********************************************************************" >>${log_file}
    dpkg -s "${line}" >>${log_file} 2>&1
    if [ "$?" = "0" ]
    then
        echo -e "${line} [\033[32mInstalled\033[0m]" | awk '{printf "%-50s %-30s\n", $1, $2}'
        continue
    fi

    echo "********************************************************************" >>${log_file}
    echo "* Install ${line}:"                                                   >>${log_file}
    echo "********************************************************************" >>${log_file}
    apt-get --yes install "${line}" >>${log_file} 2>&1
    if [ "$?" = "0" ]
    then
        echo -e "${line} [\033[32mPass\033[0m]" | awk '{printf "%-50s %-30s\n", $1, $2}'
    else
        echo -e "${line} [\033[31mFailed\033[0m]" | awk '{printf "%-50s %-30s\n", $1, $2}'
        exit 1
    fi
done < apt_packages.lst
