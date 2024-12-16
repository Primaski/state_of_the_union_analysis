#!/bin/bash
#! cleanup.sh
#! The purpose of this script is to preprocess the raw data. It will require the transcripts/years/ directory to be populated.

# Modify as needed
STOP=0 # for testing purposes, only does it on the first file. 
loading_updates=50 # after how many files have been processed do we report to the console

# ----------------
script_name=$(basename "$0")

# Ensuring we have the files to work with - dir should have been created by genyearfiles.sh
if [ ! -d "${1}" ] || [ ! $# -ne 3 ]; then
	echo "[${script_name}]: Did not receive a working input directory and output directory as arguments. Terminating."
	exit 1
fi

# Grab the text files, ensure they exist

DIR_input=$1
DIR_output=$2
raw_files=(${DIR_input}/*.txt)
first_year=0
curr_year=0

if [ "${raw_files[0]}" == "${DIR_input}/*.txt" ]; then
	# If equal, there was no glob expansion (no text files), and the string literal is preserved.
	echo "[${script_name}]: The years directory must contain at least one text file. Terminating."
	exit 1
fi

# Create output directory if does not exist
[[ -d "$DIR_output" ]] || mkdir -p "$DIR_output"

if find "$DIR_output" -maxdepth 1 -name "*.txt" | grep -q .; then
	echo "[${script_name}]: Files already exist in the clean directory. Regenerate files? (y/n)"
	read response
	if [[ "$response" != "y" && "$response" != "Y" ]]; then
		exit 0
	fi
fi

echo "[${script_name}]: Working..."

count=0
for file in "${raw_files[@]}"; do
	if [[ ! "$file" =~ [0-9]{4}-?[0-9]?\.txt ]]; then
		continue
       fi
       filename=$(basename "$file" .txt)
       [ $first_year == 0 ] && first_year=$filename
       curr_year=$filename
       (( count % loading_updates == 0 )) && echo "[${script_name}]: Still working... currently on $curr_year"
		(( count++ )) 
       # The following command translates all characters to lowercase, and then removes extraneous characters. We preserve apostrophes and dashes, but only when they appear intraword. 
       # Since sed does not support negative lookahead or lookbehind, I simply converted acceptable characters to placeholders, then deleted all unacceptable ones, then switched the placeholders back.
       # Note: Many pairs of words had unnecessary hyphens in them due to imperfect data (for example: need-to, look-away). They will simply be separated with spaces. There were also many unreadable characters, so I narrowed it down to ASCII.
       tr 'A-Z' 'a-z' < "$file" | \
	       tr -s " " | \
	       sed 's/<<[^>]*>>//g' | \
	       sed -E "s/([A-Za-z])—([A-Za-z])/\1 \2/g" | \
	       sed -E "s/([A-Za-z])-([A-Za-z])/\1 \2/g" | \
	       sed -E "s/([A-Za-z])—([A-Za-z])/\1 \2/g" | \
	       sed 's/[][,#+-—:—;\/\?\‑\‘\’\“\”\°\`\|\~\£\$\&\"\.\(\)\*\%]//g' | \
	       sed -E "s/([A-Za-z])'([A-Za-z])/\1,\2/g" | 
	       sed "s/'//g" | \
	       sed "s/,/'/g" | \
	       sed "s/[^[:print:][:space:]]//g" \
	       > "${DIR_output}/${filename}.txt"

	if [[ STOP -eq 1 ]]; then
		break
	fi
done

echo "[${script_name}]: Successfully preprocessed transcripts for years ${first_year} through ${curr_year}."

# for testing purposes, move to relevant section and uncomment
#tr 'A-Z' 'a-z' < "$HOME/project/resources/stop_char_tester" | sed "s/[][,#+=:;\/\?\‑\–\—\‘\’\“\”\°\`\|\~\£\$\&\"\.\(\)\*\%\-]//g" > "$HOME/project/.temp/stop_char_out"
