#!/usr/bin/env python
# coding: utf-8

# This is a modified executable code from a Jupyter Notebook. Please ensure you run pip install for matplotlib and pandas, if you do not have them already.

# Let's try finding what countries have been mentioned. List of countries is a modified Gist 
# forked from kalinchernev at the following link: https://gist.github.com/kalinchernev/486393efcca01623b18d

#!pip install numpy==1.26.4
import os
from pprint import pprint
import matplotlib.pyplot as mp_plot
import matplotlib.image as mp_img

DIR = r"D:\xprim\Documents\Projects\MSU_TAT\text_tools_project"
DIR_findings = os.path.join(DIR,"findings")
DIR_resources = os.path.join(DIR,"resources")

master_wordlist_fp = os.path.join(DIR_findings, "master_wordlist_alphabetized.tsv")
countries_fp = os.path.join(DIR_resources, "countries")


# In[119]:


# Populate master wordlist here (I'm going to use a dictionary)
master_wordlist = {}

with open(master_wordlist_fp, 'r') as f:
    for line in f:
        curr = line.strip().split('\t')
        word = curr[0]
        freq = curr[1]
        master_wordlist[word] = int(freq)
  
# <a id='findings'></a>
# <h2>Findings</h2>

# <h3>How often different countries were mentioned</h3>

# In[125]:


print("By name:")
by_freq = []
with open(countries_fp, 'r') as f:
    for word in f:
        word = word.strip().lower()
        if word in master_wordlist:
            by_freq.append((word, master_wordlist[word]))
            print(f"{word} -- APPEARS ({master_wordlist[word]} times)")
        else:
            print(f"{word} -- no")

print("\n______________\n")
print("By frequency:")
by_freq = sorted(by_freq, key=lambda x: x[1], reverse=True)
pprint(by_freq)
print("\n______________\n")
# In[126]:

img_fp=os.path.join(DIR_findings,"images","countries_mentioned_in_SOTU.png")
try:
    mp_plot.imshow(mp_img.imread(img_fp))
    mp_plot.show()
except Exception as e:
    print(e)
    
print(f"Image should have displayed. It was not auto-generated. It can be found at {str(img_fp)}")
input("Press ENTER to exit")

# Notes for the map:
# - United Kingdom = "Britain", "United Kingdom", "England"
# - Russia = "Russia", "Soviet", "Russian (Federation)"
# - Iran = "Iran", "Persia"
# - Myanmar = "Myanmar", "Burma"
# - Cambodia = "Kampuchea", "Cambodia"
# - Thailand = "Thailand", "Siam"
# - Zimbabwe = "Zimbabwe", "Rhodesia"
# - Malaysia = "Mayasia", "Malaya"
# - Sri Lanka = "Sri", "Ceylon"
# 
# - I combined Czechia and Slovakia for results of Czechoslovakia
# - South Africa was discovered by manual search
# - Georgia had to be manually filtered out using `egrep -o ".{0,50}Georgia.{0,50}"`. 
# There were no instances of the country of Georgia.
# - There was no trace of UAE after using Emirates either.
# - I couldn't find the Central African Republic in the data
# - Greenland was combined with Denmark

# <h3>Word frequencies over time</h3>


