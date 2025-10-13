#!/bin/bash

# This script is used to edit the .Renviron file to add the ICRN kernel path
# It is used to add the ICRN kernel path to the .Renviron file

# Get the ICRN kernel path from the command line - this is passed from the calling method
# usage therefore is: ./update_r_libs.sh target_renviron_path target_kernel_name

target_Renviron_file=$1
target_kernel_path=$2
target_overlay_path=$3

if [ -z "$target_Renviron_file" ]; then
    echo "ERROR: no target Renviron file specified."
    exit 1
fi

# Validate target file path
target_dir=$(dirname "$target_Renviron_file")
if [ ! -d "$target_dir" ]; then
    echo "ERROR: target directory does not exist: $target_dir"
    exit 1
fi

# Check if we can write to the target directory
if [ ! -w "$target_dir" ]; then
    echo "ERROR: no write permission for target directory: $target_dir"
    exit 1
fi

# for dev: set the ICRN kernel base path; this should be done inside of the dockerfile in prod
# export ICRN_KERNEL_BASE=${HOME}/.icrn/icrn_kernels
# TODO: ./icrn_manager init needs to write its various config - even on the user side, to the manager config
# then, this script needs to read from that config.
icrn_base=".icrn"
icrn_kernels="icrn_kernels"
ICRN_BASE=${ICRN_BASE:-${HOME}/${icrn_base}}
ICRN_KERNEL_BASE=${ICRN_KERNEL_BASE:-${ICRN_BASE}/${icrn_kernels}}
ICRN_USER_CATALOG=${ICRN_USER_CATALOG:-${ICRN_KERNEL_BASE}/user_catalog.json}
ICRN_KERNEL_REPOSITORY="/u/hdpriest/icrn_temp_repository"
ICRN_R_KERNELS=${ICRN_KERNEL_REPOSITORY}"/r_kernels/"
ICRN_KERNEL_CATALOG=${ICRN_KERNEL_REPOSITORY}"/icrn_kernel_catalog.json"

update_r_libs_path()
{
    target_r_environ_file=$1
    ICRN_kernel_path=$2
    USER_overlay_path=$3
    # icrn_kernel_name=$2
    # ICRN_kernel_path=${ICRN_KERNEL_BASE}/${icrn_kernel_name}
    
    # Ensure the target file can be written to
    if [ -f "$target_r_environ_file" ] && [ ! -w "$target_r_environ_file" ]; then
        echo "ERROR: no write permission for target file: $target_r_environ_file"
        return 1
    fi
    
    echo "# ICRN ADDITIONS - do not edit this line or below" >> "$target_r_environ_file"
    if [ -z "$ICRN_kernel_path" ]; then
        echo "Unsetting R_libs..."
        echo "R_LIBS="'${R_LIBS:-}' >> "$target_r_environ_file"
    else
        echo "Using ${ICRN_kernel_path} within R..."
        echo "Using ${USER_overlay_path} for new R package installs..."
        echo "R_LIBS="${USER_overlay_path}':'${ICRN_kernel_path}':${R_LIBS:-}' >> "$target_r_environ_file"
    fi
}

if [ ! -z "$target_Renviron_file" ]; then
    if [ -e "$target_Renviron_file" ]; then
        if [ ! -z "$(grep "# ICRN ADDITIONS - do not edit this line or below" "$target_Renviron_file" 2>/dev/null)" ]; then
            sed -i '/^# ICRN ADDITIONS - do not edit this line or below$/,$d' "$target_Renviron_file" 
        fi
    fi
    update_r_libs_path "$target_Renviron_file" "$target_kernel_path" "$target_overlay_path"
fi
