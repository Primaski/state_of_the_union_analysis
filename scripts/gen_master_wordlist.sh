#!/bin/bash
# gen_master_wordlist.sh

# Generates a list of ALL of the words used in ALL of the transcripts. This will ultimately be used to make the final TSV file. Given that we already have frequencies, I decided I may as well use awk to get the grand total sum of each word's frequency in all of the State of the Union addresses.

# Argument 1: Directory full of frequency lists
# Argument 2: Output destination for the wordlist (one file)
# Argument 3 (not implemented yet): Sorting order. ABC to sort alphabetically, FREQ to do so by frequency.

loading_updates=300 # after how many OPERATIONS have been processed do we report to the console. make sure this number is huge, or else prepare for the great flood
output_filename="master_wordlist_alphabetized.tsv"

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
freq_files=(${DIR_input}/*.tsv)

if [ "${freq_files[0]}" == "${DIR_input}/*.tsv" ]; then
	# If equal, there was no glob expansion (no text files), and the string literal is preserved.
	echo "[${script_name}]: The freq directory must contain at least one text file. Terminating."
	exit 1
fi

[[ -d "$DIR_output" ]] || mkdir -p "$DIR_output"

if [[ -f "${DIR_output}/${output_filename}" ]]; then
	echo "[${script_name}]: Master wordlist already exists in this directory. Regenerate? This will take a long time, really! (y/n)"
	read response
	if [[ "$response" != "y" && "$response" != "Y" ]]; then
		exit 0
	else
		mv --backup=t "${DIR_output}/${output_filename}" "${DIR_output}/${output_filename}_old" # won't be overwritten
	fi
fi

echo "[${script_name}]: Working..."
master_wordlist=""

# -----------------------------

# Okay, so first: before we collapse everything and count frequencies, let's just get a master list, and sort it.
for file in "${freq_files[@]}"; do
	master_wordlist+=$(cat "$file")
	master_wordlist+=$'\n'
done
master_wordlist=$(echo -e "$master_wordlist" | sort)

# So now we have a sorted list of words with their frequencies, but they have not been merged yet... so for example "man 5\n man 3\n man 6\n mat 2" etc. We're going to want to sum up all the frequencies and collapse the words into one.

prev_word=""
sum=0
count=0

while read -r line; do
	(( count ++ ))
	(( count % loading_updates == 0 )) && echo "[${script_name}]: Still working... currently on the word: $curr_word."
 
	curr_word=$(echo "$line" | awk '{print $1}')
	freq=$(echo "$line" | awk '{print int($2)}')
	
	#debugging
	#echo "curr word is $curr_word. curr freq is $freq. curr sum is $sum."
	#sleep 0.5

	if [[ "$curr_word" == "$prev_word" ]]; then
		sum=$(( sum + freq ))
	else
		# new word, time to export the previous word and the count... just decided to write to the file instead of storing in a variable
		echo -e "$prev_word\t$sum" >> "${DIR_output}/${output_filename}"
		prev_word=$curr_word
		sum=$freq
	fi

done < <(echo -e "$master_wordlist")

#echo -e "$master_wordlist" | sort | uniq | head -50
