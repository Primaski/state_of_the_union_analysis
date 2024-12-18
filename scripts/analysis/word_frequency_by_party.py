#!/usr/bin/env python
# coding: utf-8

# This is a modified executable code from a Jupyter Notebook. Please ensure you run pip install for matplotlib and pandas, if you do not have them already.

# Let's try finding what countries have been mentioned. List of countries is a modified Gist 
# forked from kalinchernev at the following link: https://gist.github.com/kalinchernev/486393efcca01623b18d

#!pip install numpy==1.26.4
import os
from pprint import pprint
import pandas as panda # for TSV processing later

DIR = r"D:\xprim\Documents\Projects\MSU_TAT\text_tools_project"
DIR_findings = os.path.join(DIR,"findings")
DIR_resources = os.path.join(DIR,"resources")

master_wordlist_fp = os.path.join(DIR_findings, "master_wordlist_alphabetized.tsv")
#master_wordlist_freq_fp = os.path.join(DIR_findings, "master_wordlist_by_frequency.tsv")
wordfreq_chart_fp = os.path.join(DIR_findings, "wordfreq_chart.tsv")

#resources
countries_fp = os.path.join(DIR_resources, "countries")


# In[5]:


# Populate master wordlist here (I'm going to use a dictionary)
master_wordlist = {}

with open(master_wordlist_fp, 'r') as f:
    for line in f:
        curr = line.strip().split('\t')
        word = curr[0]
        freq = curr[1]
        master_wordlist[word] = int(freq)


# In[7]:


# Load the word frequency chart
df = panda.read_csv(wordfreq_chart_fp, sep='\t', index_col=0, low_memory=False)


def word_freq_by_party(word, start_year=1790, end_year=2024):
    president_party_row_number = 0
    party_row = df.iloc[president_party_row_number]
    word_row = -1
    try:
        word_row = df.iloc[df.index.get_loc(word)]
    except:
        print("Word not found")
        return
    
    # we're going to put this in a dictionary where the key is the party, and the value is the word count
    occurrences_by_party = {}
    
    for address in df.columns:
        curr_year = int(address.replace('-2','').replace('.tsv',''))
        if curr_year < start_year:
            continue
        if curr_year > end_year:
            break
        party = party_row[address]
        freq = word_row[address]
        
        if party not in occurrences_by_party:
            occurrences_by_party[party] = int(freq)
        else:
            occurrences_by_party[party] += int(freq)

    pprint(sorted(occurrences_by_party.items(), key=lambda x: x[1], reverse=True))
    #pprint(occurrences_by_party)


while(True):
    print("\nThis will output an array.")
    response = input("What should be the starting year of these results? The default is 1790, the first year with transcripts.\n")
    start_year = 1790
    try:
        if(response == ""):
            response = 1790
        start_year = int(response)
    except Exception as e:
        print(e)
        continue
    
    response = input("What should be the end year of these results? The default is 2024, the last year with transcripts.\n")
    end_year = 2024
    try:
        if(response == ""):
            response = 2024
        end_year = int(response)
    except Exception as e:
        print(e)
        continue
    
    response = input("Which word should we plot out?")
    if(response == ""):
        print("Please try again. We need a word to plot out.")
        continue
    word_freq_by_party(response,start_year,end_year)





