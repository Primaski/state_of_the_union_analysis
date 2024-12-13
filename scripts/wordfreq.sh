#!/bin/bash
# wordfreq.sh

# The purpose of this script is to take preprocessed files, and generate a word frequency count.
# Argument 1 should be the input filepath or directory path.
# Argument 2 should be the output directory path.
# Argument 3 (optional) should be the stopwords file path, if you wish to omit stopwords from the output.

# WORK IN PROGRESS, NOT DONE

# Do not modify
input_filepath=""
DIR_input=""
DIR_output=""
stop_words_filepath=""

if [[ -f "$1" ]]; then
	input_filepath="$1"
elif [[ -d "$1" ]]; then
	DIR_input="$1"
else
	echo "[$(basename "$0")]: Fatal error: Did not receive a working input directory or file as the first argument."
	exit 1
fi

if [[ ! -d "$2" ]]; then
	echo "[$(basename "$0")]: Fatal error: Did not receive a working output directory as the second argument."
else
	DIR_output="$2"
fi


if [[ $# -gt 2 ]]; then
	if [[ -f "$3" ]]; then
		stop_words_filepath="$3"
	else
		echo "[$(basename "$0")]: Fatal error: $3 is not a valid filepath to a stop words file."
		exit 1
	fi
fi

# Arg 1: input filepath, Arg 2: output dir, Arg 3: stopwords filepath (optional), output: list of words in file + frequencies
_wordfreq_of_file (){
	local input="$1"
	local output="$2/$(basename "$1" .txt).csv"
	local stoplist="$3"

	echo -e "Input file was $input.\n Output file will be $output.\n Stop list is $stoplist"

	# translate all non A-z 0-9 and ' chars to \n
	echo "input file: $input"
	egrep -o "[a-z]+['-]?[a-z]+" < "$input" | sort | uniq -c | sort -nr | \
		awk '{print $2 "\t" $1}'
}

#if [[ ! -z "$input_filepath" ]]; then
	# then it's a single file
	#_wordfreq_of_file "$input_filepath" "$DIR_output" "$stop_words_filepath"
#else
	#for file in $DIR_input/*.txt; do
		#_wordfreq_of_file "$file" "$DIR_output" "$stop_words_filepath"	
		#break #temporary for testing purpose
	#done
#fi
