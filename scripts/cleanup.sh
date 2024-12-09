#!/bin/bash
#! cleanup.sh
#! The purpose of this script is to preprocess the raw data. It will require the transcripts/years/ directory to be populated.

# Modify below as needed
chars_to_remove="!\"\\#%&'()[]*+,:;./=?-_\`|~°¸‑–—‘’“”…$£бЅјў�"
# I used `egrep -o "[^A-Za-z0-9]' SOTUT.csv | sort | uniq` to determine all non alphabetic and numerical characters used in the speech.
STOP=1 # for testing purposes, only does it on the first file. 


# Do not modify beyond here

# Ensuring we have the files to work with
if [ ! -d "${1}/years" ]; then
	echo "[$(basename "$0")]: Fatal error: Did not receive a working directory as an argument. Make sure to pass in the path to the transcripts directory, and that there is a years subdirectory."
	exit 1
fi

# Grab the text files, ensure they exist

DIR_transcripts=$1
DIR_years="${DIR_transcripts}/years"
year_files=(${DIR_years}/*.txt)

if [ "${year_files[0]}" == "${DIR_years}/*.txt" ]; then
	# If equal, there was no glob expansion (no text files), and the string literal is preserved.
	echo "[$(basename "$0")]: Fatal error: The years directory must contain at least one text file."
	exit 1
fi

for file in $year_files; do
	echo "Working on file $(basename "$file")"
	sed 's/${chars_to_remove}//g' "$file" > "$DIR_years/$(basename "$file" .txt)_clean.txt"
	if [[ STOP -eq 1 ]]; then
		break
	fi
done


# echo "[$(basename "$0")]: No errors."


