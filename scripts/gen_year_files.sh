#!/bin/bash
# gen_year_files.sh
# This script receives the path to the transcripts directory as an argument.
# This script will utilize a raw CSV file containing all of the State of the Union addresses, and organizes them into a directory. Each address will be saved in a separate file, named by the year of the address, and populated with its respective transcript. The intent is to make the process of working on the data cleaner and more streamlined.

# DOES NOT CURRENTLY WORK, NEED TO FIX THE REGEX OR SED. FILE IS NOT OUTPUTTED CLEAN

# Modify as needed
STOP=0 # if 1, generates only the first file - for testing purposes
regex="^(.+),(.+),.*,\"\[(.*)\]\""


# Ensuring we have the files to work with
if [ ! -d "$1" ]; then
	echo "[$(basename "$0")]: Fatal error: Did not receive a working directory as an argument."
	exit 1
fi

if [ ! -f "$1/SOTUT.csv" ]; then
	echo "[$(basename "$0")]: Fatal error: Transcript CSV file not found."
	exit 1
fi

DIR_transcripts="$1"
FP_csv="${DIR_transcripts}/SOTUT.csv"
first_year=0
curr_year=0

if find "${DIR_transcripts}/years" -maxdepth 1 -name "*.txt" | grep -q .; then
	echo "[$(basename "$0")]: Files already exist in the years directory. Regenerate files? (y/n)"
	read response
	if [[ "$response" != "y" && "$response" != "Y" ]]; then
		exit 0
	fi
fi

#------------------------

echo "[$(basename "$0")]: Working..."
# Each year's transcript is printed on a distinct line. We will first ensure that the line conforms to the expected regex.
while IFS= read -r address; do
	if [[ ${address} =~ ${regex} ]]; then
		# If we reach here, then the regex is working on the current line. Let's divide each column. The regular expression should have three capture groups.
		president="${BASH_REMATCH[1]}"
		year="${BASH_REMATCH[2]}"
		speech="${BASH_REMATCH[3]}"
		curr_year=$year #for end reporting
		[ $first_year -eq 0 ] && first_year=$year #for end reporting	
		
		#The file will be named with the year, and the contents will have the name of the president, followed by a new line with the raw transcript.
		echo -e "<<$president>>\n${speech}" > "$DIR_transcripts/years/${year}.txt"
	else
		echo "[$(basename "$0")]: Fatal error: Address beginning with \"${address:0:100}...\" had an unexpected format."
		exit 1
	fi
	if [[ STOP -eq 1 ]]; then
		break
	fi
done < <(tail -n +2 $FP_csv)

echo "[$(basename "$0")]: Successfully generated raw transcript files for years ${first_year} through ${curr_year}."

