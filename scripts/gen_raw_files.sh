#!/bin/bash
# gen_raw_files.sh
# This script receives the path to the transcripts directory as an argument.
# This script will utilize a raw CSV file containing all of the State of the Union addresses, and organizes them into a directory. Each address will be saved in a separate file, named by the year of the address, and populated with its respective transcript. The intent is to make the process of working on the data cleaner and more streamlined.

# Modify as needed
loading_updates=50 # after how many files have been processed should an update be sent to the console
regex="^(.+),(.+),.*,\"\[(.*)\]\""

# ----------------
script_name=$(basename "$0")
# Ensuring we have the files to work with
if [ ! -f "$1" ] || [ $# -ne 2 ]; then
	echo "[${script_name}]: Did not receive a working input file and an output directory as arguments. Terminating."
	exit 1
fi

input="$1"
DIR_output="$2"

if [ ! -f "${input}" ]; then
	echo "[${script_name}]: Transcript CSV file not found. Terminating."
	exit 1
fi

first_year=0
curr_year=0

# Create output directory if does not exist
[[ -d "${DIR_output}" ]] || mkdir -p "${DIR_output}"

if find "${DIR_output}" -maxdepth 1 -name "*.txt" | grep -q .; then
	echo "[${script_name}]: Files already exist in the raw directory. Regenerate files? (y/n)"
	read response
	if [[ "$response" != "y" && "$response" != "Y" ]]; then
		exit 0
	fi
fi


#------------------------

echo "[${script_name}]: Working..."
# Each year's transcript is printed on a distinct line. We will first ensure that the line conforms to the expected regex.
count=0
while IFS= read -r address; do
	if [[ ${address} =~ ${regex} ]]; then
		# If we reach here, then the regex is working on the current line. Let's divide each column. The regular expression should have three capture groups.
		president="${BASH_REMATCH[1]}"
		year="${BASH_REMATCH[2]}"
		speech="${BASH_REMATCH[3]}"

		# for reporting purposes
		curr_year=$year
		[ $first_year -eq 0 ] && first_year=$year #for end reporting	

		(( count % loading_updates == 0 )) && echo "[${script_name}]: Still working... currently on $curr_year"
		(( count++ )) 	
		echo -e "<<$president>>\n${speech}" > ${DIR_output}/${year}.txt
	else
		echo "[${script_name}]: Address beginning with \"${address:0:100}...\" had an unexpected format. Terminating."
		exit 1
	fi
done < <(tail -n +2 $input)

echo "[${script_name}]: Successfully generated raw transcript files for years ${first_year} through ${curr_year}."

