#!/bin/bash
# wordfreq.sh

# The purpose of this script is to take preprocessed files, and generate a word frequency count.
# Argument 1 should be the input filepath or directory path.
# Argument 2 should be the output directory path.
# Argument 3 (optional) should be the sorting order, "ABC" or "FREQ". If blank, sorts by frequency.
# Argument 4 (optional) should be the stopwords file path, if you wish to omit stopwords from the output. If blank, does not filter any words out.

# do not modify
sort_alphabetically=0
script_name=$(basename "$0")
input_filepath=""
DIR_input=""
DIR_output=""
stop_words_filepath=""

# --------- check and assign arguments ----------

if [[ $# -lt 2 ]]; then
	echo "[${script_name}]: Insufficient number of arguments provided. Needs at least an input directory and an output directory."
	exit 1
fi

if [[ -f "$1" ]]; then
	input_filepath="$1"
elif [[ -d "$1" ]]; then
	DIR_input="$1"
else
	echo "[${script_name}]: Did not receive a working input directory or file as the first argument."
	exit 1
fi

# Create output directory if does not exist
DIR_output=$2
[[ -d "$DIR_output" ]] || mkdir -p "$DIR_output"

if find "$DIR_output" -maxdepth 1 -name "*.tsv" | grep -q .; then
	echo "[${script_name}]: Files already exist in the freq directory. Regenerate files? Note that this will take a very long time to generate. (y/n)"
	read response
	if [[ "$response" != "y" && "$response" != "Y" ]]; then
		exit 0
	fi
fi

if [[ $# -gt 2 ]]; then
	if [[ "$3" == "ABC" ]] || [[ "$3" =~ "alphabet" ]]; then
		sort_alphabetically=1
	elif [[ "$3" != "FREQ" ]] && [[ ! "$3" =~ "freq" ]]; then
		echo "${script_name}]: $3 is not a valid sorting order."
		exit 1
	fi
	if [[ -n "$4" ]]; then
		if [[ -f "$4" ]]; then
			stop_words_filepath="$4"
		else
			echo "[${script_name}]:$4 is not a valid filepath to a stop words file. Terminating."
		exit 1
		fi
	fi
fi


# ---------- begin the process ------------

# Arg 1: input filepath, Arg 2: output dir, Arg 3: stopwords filepath (optional), output: list of words in file + frequencies
_wordfreq_of_file (){
	local input_filepath="$1"
	local output_filepath="$2/$(basename "$1" .txt).tsv"
	local stoplist="$3"

	# echo -e "Input file was $input.\n Output file will be $output.\n Stop list is $stoplist"

	# translate all non A-z 0-9 and ' chars to \n
	output=$(egrep -o "[a-z]+['-]?[a-z]+" < "$input_filepath" | sort | \
		uniq -c | sort -nr | awk '{print $2 "\t" $1}')
	if [[ $sort_alphabetically -eq 1 ]]; then
		output_temp=$(echo "$output" | sort)
		output=$(echo "$output_temp")
	fi

	# filter stop words if necessary
	if [[ $stop_words_filepath != "" ]]; then
		#echo "entered stopwords if"
		old_freq_list=$output
		output=""

		while IFS= read -r curr_line; do
			# filter out frequency, extract word to check
			curr_word=$(echo "$curr_line" | cut -d $'\t' -f 1)
			
			if [[ ! $(grep -w "$curr_word" "$stop_words_filepath") ]]; then
				# the word was not in the stopwords list, so it can appear in the output
				output+="$curr_line"$'\n'
			fi

		done < <(echo -e "$old_freq_list")
	fi

	echo -e "$output" > "$output_filepath"
	return	
}

if [[ ! -z "$input_filepath" ]]; then
	# then it's a single file
	_wordfreq_of_file "$input_filepath" "$DIR_output" "$stop_words_filepath"
else
	echo "[${script_name}]: Working... this will take a very long time. Sorry!"
	count=0
	for file in $DIR_input/*.txt; do
		(( count % 2 == 0 )) && echo "[${script_name}]: Currently on $(basename "$file")..." 
		(( count++ ))
		_wordfreq_of_file "$file" "$DIR_output" "$stop_words_filepath"	
	done
fi
