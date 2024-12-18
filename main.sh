#!/bin/bash
# main.sh
# This file is the entry point of the program. It is used to execute the scripts in /scripts/gen/ sequentially.
# NOTE: THIS IS NOT NECESSARY TO EXECUTE AS LONG AS WORDFREQ_CHART.TSV AND MASTER_WORDLIST_ALPHABETIZED.TSV ARE IN /FINDINGS/
# THESE SCRIPTS COULD TAKE HOURS TO RUN. DO NOT REGENERATE IF IT'S NOT NECESSARY.
# If you're just interested in running analysis on those files, feel free to execute individual Python scripts in /scripts/analysis. Contact me if you'd like access to the Jupyter Notebook.

# Modify as needed
DIR=$(cd "$(dirname "$0")" && pwd) #get current directory
echo "Installing spacy (if needed), please wait..."
pip3 install spacy > /dev/null
python3 -m spacy download en_core_web_sm > /dev/null

#----------- Execute scripts sequentially ------------

# Step 1 - Split the document containing all the transcripts into year-by-year text files
${DIR}/scripts/gen/gen_raw_files.sh "${DIR}/SOTUT.csv" "${DIR}/processing/raw"
# Step 2 - Preprocess all the files in the directory
${DIR}/scripts/gen/cleanup.sh "${DIR}/processing/raw" "${DIR}/processing/clean"
# Step 3 - Lemmatize the preprocessed files
python3 ${DIR}/scripts/gen/lemmatize.py "${DIR}/processing/clean" "${DIR}/processing/lemma"
# Step 4 - Create a CSV table that describes lemma frequencies 
[[ -d "${DIR}/processing/freq" ]] || mkdir -p "${DIR}/processing/freq"
${DIR}/scripts/gen/wordfreq.sh "${DIR}/processing/lemma" "${DIR}/processing/freq" ABC "${DIR}/resources/stopwords"
# Step 5 - Here's the fun part - our first finding! Let's collapse all of the frequency files into one, so that we can have a master list of every word said in every State of the Union address, along with their frequency counts.
${DIR}/scripts/gen/gen_master_wordlist.sh "${DIR}/processing/freq" "${DIR}/findings"
# Step 6 - Let's turn the entire directory of /freq/ into one big TSV files, so we can determine the counts of ALL of the words across ALL of the addresses. This script will take a very long time to finish.
${DIR}/scripts/gen/gen_wordfreq_chart.sh "${DIR}/processing/freq" "${DIR}/findings/master_wordlist_alphabetized.tsv" "${DIR}/findings"

# From here, all of the data has been rendered 

