#!/bin/bash

if [ -z "${log_file}" ]
then
    log_file="setup.log"
fi

echo "Create symbolic links determining default commands:"

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

    if [ "${line:0:1}" = "[" -a "${line: -1}" = "]" ]
    then
        line=`echo ${line%]*}`
        line=`echo ${line##*[}`
        link="${line}"

        echo "********************************************************************" >>${log_file}
        echo "* Create symbolic links ${link}:"                                     >>${log_file}
        echo "********************************************************************" >>${log_file}
        continue
    fi

    if [ -z "${link}" ]
    then
        continue
    fi

    name=`echo $line | awk '{print $1}'`
    path=`echo $line | awk '{print $2}'`
    priority=`echo $line | awk '{print $3}'`

    update-alternatives --install ${link} ${name} ${path} ${priority} >>${log_file} 2>&1
    if [ "$?" = "0" ]
    then
        echo -e "${path} [\033[32mPass\033[0m]" | awk '{printf "%-50s %-30s\n", $1, $2}'
    else
        echo -e "${path} [\033[31mFailed\033[0m]" | awk '{printf "%-50s %-30s\n", $1, $2}'
        exit 1
    fi
done < alternatives.conf
