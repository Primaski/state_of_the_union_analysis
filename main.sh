#!/bin/bash
# main.sh
# This file is the entry point of the program. It is used to execute the scripts in /scripts/ sequentially.

# Modify as needed
DIR=$(cd "$(dirname "$0")" && pwd) #get current directory
pip3 install nltk > /dev/null #if not already installed

#----------- Execute scripts sequentially ------------

# Currently unrunnable because I changed the argument structure of the scripts. Will be fixed by next commit.

# Step 1 - Split the document containing all the transcripts into year-by-year text files
${DIR}/scripts/gen_raw_files.sh "${DIR}/transcripts" "${DIR}/raw"
# Step 2 - Preprocess all the files in the directory
${DIR}/scripts/cleanup.sh "${DIR}/transcripts" "${DIR}/clean"
# Step 3 - Lemmatize the preprocessed files
python3 ${DIR}/scripts/lemmatize.py # not finished
# Step 4 - Create a CSV table that describes lemma frequencies 
[[ -d "${DIR}/transcripts/freq" ]] || mkdir -p "${DIR}/transcripts/freq"
${DIR}/scripts/wordfreq.sh "${DIR}/transcripts/lemma" "${DIR}/transcripts/freq" "${DIR}/resources/stopwords" #not finished
