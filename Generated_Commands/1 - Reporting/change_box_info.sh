#!/bin/bash

# Variables for user inputs
box_host=""
box_ip=""
inf=""
PARENT_DIR="BOXLOCATION"

# Usage instructions
usage() {
    echo -e "
    usage: $0 [-i] [-n] [-d]

    OPTIONS:
    -h                 Show this help menu
    -i                 Change IP address
    -n                 Change hostname.tld
    -d                 Change network interface
    "
}

# Parse command-line options
while getopts ":hind" OPTION; do
    case $OPTION in
        h)
            usage
            exit 0
            ;;
        i)
            box_ip=$OPTARG
            ;;
        n)
            box_host=$OPTARG
            ;;
        d)
            inf=$OPTARG
            ;;
        ?)
            usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

# Function to find relevant files
find_files() {
    find ${PARENT_DIR} -type f \( -name "*.md" -o -name "*.sh" \)
}

# Function to replace IP address
change_IP() {
    read -p "Enter the old IP to be replaced: " old_ip
    read -p "Enter the new IP to replace it with: " new_ip
    find_files | while read -r file; do
        sed -i "s/$old_ip/$new_ip/g" "$file"
    done
    echo "IP address changed from $old_ip to $new_ip in all files in directory ${PARENT_DIR}"
}

# Function to replace hostname
change_HOST() {
    read -p "Enter the old hostname to be replaced: " old_host
    read -p "Enter the new hostname to replace it with: " new_host
    find_files | while read -r file; do
        sed -i "s/$old_host/$new_host/g" "$file"
    done
    echo "Hostname changed from $old_host to $new_host in all files in directory ${PARENT_DIR}"
}

# Function to replace network interface
change_INTERFACE() {
    read -p "Enter the old network interface to be replaced: " old_inf
    read -p "Enter the new network interface to replace it with: " new_inf
    find_files | while read -r file; do
        sed -i "s/$old_inf/$new_inf/g" "$file"
    done
    echo "Network interface changed from $old_inf to $new_inf in all files in directory ${PARENT_DIR}"
}

main() {
    if [ ! -z "${box_ip}" ]; then
        change_IP
    fi
    if [ ! -z "${box_host}" ]; then
        change_HOST
    fi
    if [ ! -z "${inf}" ]; then
        change_INTERFACE
    fi

    if [ -z "${box_ip}" ] && [ -z "${box_host}" ] && [ -z "${inf}" ]; then
        usage
    fi
}

main