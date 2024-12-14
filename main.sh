#!/bin/bash
# main.sh
# This file is the entry point of the program. It is used to execute the scripts in /scripts/ sequentially.

# Modify as needed
DIR=$(cd "$(dirname "$0")" && pwd) #get current directory
echo "Installing spacy (if needed), please wait..."
# pip3 install spacy > /dev/null
# python3 -m spacy download en_core_web_sm > /dev/null

#----------- Execute scripts sequentially ------------

# Step 1 - Split the document containing all the transcripts into year-by-year text files
${DIR}/scripts/gen_raw_files.sh "${DIR}/transcripts/SOTUT.csv" "${DIR}/transcripts/raw"
# Step 2 - Preprocess all the files in the directory
${DIR}/scripts/cleanup.sh "${DIR}/transcripts/raw" "${DIR}/transcripts/clean"
# Step 3 - Lemmatize the preprocessed files
python3 ${DIR}/scripts/lemmatize.py "${DIR}/transcripts/clean" "${DIR}/transcripts/lemma" # not finished
# Step 4 - Create a CSV table that describes lemma frequencies 
[[ -d "${DIR}/transcripts/freq" ]] || mkdir -p "${DIR}/transcripts/freq"
# ${DIR}/scripts/wordfreq.sh "${DIR}/transcripts/lemma" "${DIR}/transcripts/freq" "${DIR}/resources/stopwords" #not finished
