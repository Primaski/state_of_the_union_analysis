#!/bin/bash
# wordfreq.sh

# The purpose of this script is to take preprocessed files, and generate a word frequency count.
# Argument 1 should be a filepath or a directory path. Argument 2 should be a boolean on whether to OMIT stop words (like 'the', 'of') in the final list.

# Do not modify
is_directory=0
omit_stop_words=0
filepath=""

if [[ -f "$1" ]]; then
	filepath=$1
elif [[ -d "$1" ]]; then
	is_directory=1
else
	echo "[$(basename "$0")]: Fatal error: Did not receive a working directory or file as an argument."
	exit 1
fi

case "$2" in
	1|true|True|TRUE)
		omit_stop_words=1
		;;
	0|false|False|FALSE)
		:
		;;
	*)
		echo "FAIL"
		exit 1
		;;
esac

echo "[$(basename "$0")]: No issues."
# From here, create a function that processes one file at a time and outputs into freq directory
