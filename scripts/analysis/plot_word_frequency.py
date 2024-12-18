#!/usr/bin/env python
# coding: utf-8

# In[63]:


# Python 3 Kernel


# <h2>Set-up</h2>

# <h5>Click [here](#findings) to scroll down and see the results.</h5>

# In[67]:


# Let's try finding what countries have been mentioned. List of countries is a modified Gist 
# forked from kalinchernev at the following link: https://gist.github.com/kalinchernev/486393efcca01623b18d

#!pip install numpy==1.26.4
import os
from pprint import pprint
import pandas as panda # for TSV processing later
import matplotlib.pyplot as matplot

DIR = r"D:\xprim\Documents\Projects\MSU_TAT\text_tools_project"
DIR_findings = os.path.join(DIR,"findings")
DIR_resources = os.path.join(DIR,"resources")
DIR_findings_img = os.path.join(DIR_findings, "images")

master_wordlist_fp = os.path.join(DIR_findings, "master_wordlist_alphabetized.tsv")
#master_wordlist_freq_fp = os.path.join(DIR_findings, "master_wordlist_by_frequency.tsv")
wordfreq_chart_fp = os.path.join(DIR_findings, "wordfreq_chart.tsv")


# Load the word frequency chart
df = panda.read_csv(wordfreq_chart_fp, sep='\t', index_col=0, low_memory=False)


# In[73]:


# HELPER FUNCTIONS
'''
Helper function to group (sum) every N elements in the array, 
to shrink it down for data representation. For example:
[ 1, 5, 4, 3, 6, 2 ]
when N = 2 (so we're summming groups of 2):
[ 6 (=1+5), 7, 8 ]
'''
def _condense_array(array, group_size):
    if(group_size > len(array)):
        print("The group size cannot be larger than the length of the array")
        return

    array_of_groups = []
    for i in range(0, len(array), group_size):
        group_sum = array[i:i+group_size].sum()
        array_of_groups.append(group_sum)

    return array_of_groups

# Look up an individual word and see how it's trended over time!
# First argument is the word, second argument is how many years should be grouped in the output
# Outputs a line graph
def _plot_word_freq_over_time(word, group_size, save):
    word = word.lower()
    if word not in df.index:
        print("Word not found")
        return False

    # create the frequency array
    word_freq = df.loc[word].astype(int)
    word_freq_condensed = _condense_array(word_freq, group_size)

    # create the label array (aligns with freq)
    labels = []
    for i in range(0, len(word_freq), group_size):
        labels.append(word_freq.index[i].replace('.tsv',''))
    
    figure = matplot.figure(figsize=(10,6))
    matplot.plot(labels, word_freq_condensed)
    matplot.title(f"Frequency of the Word \"{word.capitalize()}\" Over Time")
    matplot.xlabel("Years")
    matplot.xticks(fontsize=8, rotation=45)
    matplot.ylabel("Frequency")
    #matplot.ylim(top=30)
    matplot.grid(True)
    matplot.show()
    if(save):
        figure.savefig(os.path.join(DIR_findings, "images", f"wordfreq_{word}_{group_size}.png"))
    return True

word=""
group_size=0
print(f"\nLine graphs will be automatically generated based on your prompt and exported to {DIR_findings_img}")
while True:
    if group_size == 0:
        response = input("How many years should be grouped at each point in the output? The recommendation is 10 (for aesthetics), or 7 (for divisibility).\n")
        try:
            group_size = int(response)
            if group_size < 1:
                print("Please provide a valid positive integer")
                continue
        except:
            print("Value must be an integer")
            continue    
    word = input("Which word should I plot? Type quit to quit.\n")
    if word == "quit":
        exit(0)
    success = _plot_word_freq_over_time(word,group_size,True)
    if(success):
        print(f"Outputted image to {os.path.join(DIR_findings_img, f"wordfreq_{word}_{group_size}.png")}")
