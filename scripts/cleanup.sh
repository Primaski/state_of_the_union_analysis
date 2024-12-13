#!/bin/bash
#! cleanup.sh
#! The purpose of this script is to preprocess the raw data. It will require the transcripts/years/ directory to be populated.

# Modify as needed
STOP=0 # for testing purposes, only does it on the first file. 

# Do not modify beyond here

# Ensuring we have the files to work with - dir should have been created by genyearfiles.sh
if [ ! -d "${1}/raw" ]; then
	echo "[$(basename "$0")]: Fatal error: Did not receive a working directory as an argument. Make sure to pass in the path to the transcripts directory, and that there is a years subdirectory."
	exit 1
fi

# Grab the text files, ensure they exist

DIR_transcripts=$1
DIR_raw="${DIR_transcripts}/raw"
raw_files=(${DIR_raw}/*.txt)
first_year=0
curr_year=0

if [ "${raw_files[0]}" == "${DIR_raw}/*.txt" ]; then
	# If equal, there was no glob expansion (no text files), and the string literal is preserved.
	echo "[$(basename "$0")]: Fatal error: The years directory must contain at least one text file."
	exit 1
fi

# Create output directory if does not exist
[[ -d "${DIR_transcripts}/clean" ]] || mkdir -p "${DIR_transcripts}/clean"

if find "${DIR_transcripts}/clean" -maxdepth 1 -name "*.txt" | grep -q .; then
	echo "[$(basename "$0")]: Files already exist in the clean directory. Regenerate files? (y/n)"
	read response
	if [[ "$response" != "y" && "$response" != "Y" ]]; then
		exit 0
	fi
fi

echo "[$(basename "$0")]: Working..."

for file in "${raw_files[@]}"; do
	if [[ ! "$file" =~ [0-9]{4}\.txt ]]; then
		continue
       fi
       filename=$(basename "$file" .txt)
       [ $first_year -eq 0 ] && first_year=$filename
       curr_year=$filename
       # The following command translates all characters to lowercase, and then removes extraneous characters. We preserve apostrophes and dashes, but only when they appear intraword. Since sed does not support negative lookahead or lookbehind, I simply converted acceptable characters to placeholders, then deleted all unacceptable ones, then switched the placeholders back.
       tr 'A-Z' 'a-z' < "$file" | \
	       sed 's/[][,#+=:;\/\?\‑\‘\’\“\”\°\`\|\~\£\$\&\"\.\(\)\*\%]//g' | \
	       sed -E "s/([A-Za-z])'([A-Za-z])/\1,\2/g" | \
	       sed -E "s/([A-Za-z])-([A-Za-z])/\1_\2/g" | \
	       sed "s/'//g" | \
	       sed "s/-//g" | \
	       sed "s/~/'/g" | \
	       sed "s/_/-/g" \
	       > "${DIR_transcripts}/clean/${filename}.txt"

	if [[ STOP -eq 1 ]]; then
		break
	fi
done

echo "[$(basename "$0")]: Successfully preprocessed transcripts for years ${first_year} through ${curr_year}."

# for testing purposes, move to relevant section and uncomment
#tr 'A-Z' 'a-z' < "$HOME/project/resources/stop_char_tester" | sed "s/[][,#+=:;\/\?\‑\–\—\‘\’\“\”\°\`\|\~\£\$\&\"\.\(\)\*\%\-]//g" > "$HOME/project/.temp/stop_char_out"
