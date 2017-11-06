#!/usr/bin/env bash

########################################################################
# Archives downloader for the pipermail based mailing lists
# Author: Oleg Mitrofanov © 2014-2015
########################################################################

# Usage example:
# ./get-pipermail-archives.sh -s 2003 -u https://lists.fedorahosted.org/pipermail/firewalld-users/
# Giving end year with -e flag is optional; defaults to current year

# Parse arguments
while [[ $# > 0 ]]
do
    key="$1"

    case $key in
        -s)
            start_year="$2"
            shift
        ;;
        -e)
            end_year="$2"
            shift
        ;;
        -u)
            url="$2"
            shift
        ;;
        -d)
            output_dir="$2"
            shift
        ;;
        -v)
            verbose=true
        ;;
        *)
            printf "Error: Unknown option \'"$1"\'.\n"
            exit 1
        ;;
    esac

    shift
done


# Sanitize input 
if [ -z "$start_year" ]; then
    printf "Error: start year must be supplied.\n"
    exit 1
elif [ -z "$url" ]; then
    printf "Error: url must be supplied.\n"
    exit 1
fi

if [ -z "$end_year" ]; then
    end_year=$(date +%Y)
fi

if [ -z "$output_dir" ]; then
    output_dir=$(basename $url)
fi

if [ $start_year -gt $end_year ]; then
    printf  "Error: The start year cannot be greater than the end year\n"
    exit 1
elif [ $start_year -eq $end_year ]; then
    down_status_title="Downloading archives for the $start_year year"
else
    down_status_title="Downloading archives for the $start_year-$end_year year range"
fi


# Vebose mode; output argumets
if [ "$verbose" = true ]; then
    printf "Start year:\t\t$start_year\n"
    printf "End year:\t\t$end_year\n"
    printf "Url:\t\t\t$url\n"
    printf "Output directory:\t$output_dir\n"
fi


# Create if needed and change to the output directory
mkdir -p "$output_dir"
cd "$output_dir"


months=$(printf "January February March April May June July August September October November December" | tr " " "\n")

for year in $(seq $start_year $end_year) 
do
    for month in $months
    do
        # Show status
        printf "\r\033[K$down_status_title: $year, $month"

        month_url="$url/$year-$month.txt.gz"

        # Getting http responses: 404, 200 or whatever
        http_code=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "$month_url")
        
        # Download only if http response is equal to 200
        if [ $http_code -eq 200 ]; then
            curl -O "$month_url" &>/dev/null
            continue
        else
            # Sometimes archives are in .txt format. But only check
            # this assumption if .gz file is not available
            month_url="$url/$year-$month.txt"

            http_code=$(curl -o /dev/null --silent --head --write-out '%{http_code}' "$month_url")
         
            if [ $http_code -eq 200 ]; then
                curl -O "$month_url" &>/dev/null
            fi
        fi
    done
done    
printf "\r\033[KDone downloading archives.\n"

for archive in $(ls -1 | grep .gz$) 
do
    printf "\r\033[KUnarchiving: $archive"
    gunzip -f "$archive"
done
printf "\r\033[KDone unarchving.\n"
