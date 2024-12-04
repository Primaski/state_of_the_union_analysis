#!/bin/bash
# gen_year_files.sh
# This script takes a raw CSV file containing all of the State of the Union addresses, and organizes them into a directory. Each address will be saved in a separate file, named by the year of the address, and populated with its respective transcript.
# The intent is to make the process of working on the data cleaner and more streamlined.

DIR="$HOME/project/transcripts" # working directory
CSV_fp="$DIR/SOTUT.csv"
YEARS_dir="$DIR/years"
regex="^(.+),(.+),.*,\"\[(.*)\]\""
STOP=0

if [ -f $CSV_fp ]; then
	echo "Transcript CSV file found."
else
	echo "Transcript CSV file not found."
	echo "Attempted directory: ${CSV_fp}"
fi


while IFS= read -r address; do
	#echo "here: $address"
	if [[ ${address} =~ ${regex} ]]; then
		president="${BASH_REMATCH[1]}"
		year="${BASH_REMATCH[2]}"
		speech="${BASH_REMATCH[3]}"
		echo "year: ${year}"
		echo "president: ${president}"
		echo "speech: ${speech:0:50}"
	else
		echo "Line ${address} had unexpected format. Terminating."
		exit 1
	fi
	if [[ STOP -eq 1 ]]; then
		exit 0
	fi
done < <(tail -n +2 "$CSV_fp")

