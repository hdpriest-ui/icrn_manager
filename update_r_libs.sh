#!/bin/bash

# This script is used to edit the .Renviron file to add the ICRN library path
# It is used to add the ICRN library path to the .Renviron file

# Get the ICRN library path from the command line - this is passed from the calling method
# usage therefore is: ./update_r_libs.sh target_renviron_path target_library_name

target_Renviron_file=$1
target_library_name=$2

if [ -z "$target_Renviron_file" ]; then
    echo "no target Renviron file specified."
    exit 1
fi

# for dev: set the ICRN library base path; this should be done inside of the dockerfile in prod
# export ICRN_LIBRARY_BASE=${HOME}/.icrn/icrn_libraries
# TODO: ./icrn_manager init needs to write its various config - even on the user side, to the manager config
# then, this script needs to read from that config.
icrn_base=".icrn"
icrn_libs="icrn_libraries"
ICRN_BASE=${ICRN_BASE:-${HOME}/${icrn_base}}
ICRN_LIBRARY_BASE=${ICRN_LIBRARY_BASE:-${ICRN_BASE}/${icrn_libs}}
ICRN_USER_CATALOG=${ICRN_USER_CATALOG:-${ICRN_LIBRARY_BASE}/user_catalog.json}
ICRN_LIBRARY_REPOSITORY="/u/hdpriest/icrn_temp_repository"
ICRN_LIBRARIES=${ICRN_LIBRARY_REPOSITORY}"/r_libraries/"
ICRN_LIBRARY_CATALOG=${ICRN_LIBRARIES}"/icrn_catalogue.json"

update_r_libs_path()
{
    target_r_environ_file=$1
    icrn_library_name=$2
    ICRN_library_path=${ICRN_LIBRARY_BASE}/${icrn_library_name}
    echo "# ICRN ADDITIONS - do not edit this line or below" >> $target_r_environ_file
    if [ -z "$icrn_library_name" ]; then
        echo "Unsetting R_libs..."
        echo "R_LIBS="'${R_LIBS:-}' >> $target_r_environ_file
    else
        echo "Using ${ICRN_library_path} within R..."
        echo "R_LIBS="${ICRN_library_path}':${R_LIBS:-}' >> $target_r_environ_file
    fi
}

if [ ! -z $target_Renviron_file ]; then
    if [ -e $target_Renviron_file ]; then
        if [ ! -z "$(grep "# ICRN ADDITIONS - do not edit this line or below" $target_Renviron_file)" ]; then
            sed -i '/^# ICRN ADDITIONS - do not edit this line or below$/,$d' $target_Renviron_file 
        fi
    fi
    update_r_libs_path $target_Renviron_file $target_library_name
fi
