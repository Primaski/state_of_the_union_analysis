#!/bin/bash
# main.sh
# This file is the entry point of the program. It is used to execute the scripts in /scripts/ sequentially.

# Modify as needed
DIR=$(cd "$(dirname "$0")" && pwd) #get current directory

# Execute scripts sequentially
${DIR}/scripts/gen_year_files.sh $DIR/transcripts
${DIR}/scripts/cleanup.sh $DIR/transcripts


