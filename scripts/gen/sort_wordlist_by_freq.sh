#!/bin/bash
# sort_wordlist_by_freq.sh

# Optional file to modify a wordlist to be sorted by frequency instead of alphabetically. Requires an existing master wordlist (due to time constraints on this project)
# Argument 1: Wordlist TSV input
# Argument 2: Output directory

loading_updates=300 # after how many OPERATIONS have been processed do we report to the console. make sure this number is huge, or else prepare for the great flood
output_filename="master_wordlist_by_frequency.tsv"

# ----------------
script_name=$(basename "$0")

# Ensuring we have the files to work with - dir should have been created by genyearfiles.sh
if [ ! -f "${1}" ] || [ ! $# -ne 3 ]; then
	echo "[${script_name}]: Did not receive a working input file and output directory as arguments. Terminating."
	exit 1
fi

# Grab the text files, ensure they exist

input=$1
DIR_output=$2

if [ "${freq_files[0]}" == "${DIR_input}/*.tsv" ]; then
	# If equal, there was no glob expansion (no text files), and the string literal is preserved.
	echo "[${script_name}]: The freq directory must contain at least one text file. Terminating."
	exit 1
fi

[[ -d "$DIR_output" ]] || mkdir -p "$DIR_output"

if find "$DIR_output" -maxdepth 1 -name "${output_filename}" | grep -q .; then
	echo "[${script_name}]: A master wordlist sorted by frequency already exists in this directory. Regenerate? (y/n)"
	read response
	if [[ "$response" != "y" && "$response" != "Y" ]]; then
		exit 0
	else
		rm "${DIR_output}/${output_filename}" # won't be overwritten
	fi
fi

echo "[${script_name}]: Working..."

sort -t $'\t' -k2 -n -r "$input" > "${DIR_output}/${output_filename}"
