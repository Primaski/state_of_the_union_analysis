# Takes a clean file or directory, then tokenizes and lemmatizes it
import spacy, sys, os

script_name = os.path.basename(__file__)

if(len(sys.argv) != 3):
    print(f"[{script_name}]: Did not receive a working input directory and output directory as arguments. Terminating. ")
    sys.exit(1)

DIR_input = sys.argv[1]
DIR_output = sys.argv[2]
input_files = []

try:
    for file_name in os.listdir(DIR_input):
        if file_name.endswith('.txt'):
            input_files.append(DIR_input + "/" + file_name)
    if len(input_files) == 0:
        print(f"[{script_name}]: Input directory must have at least one text file to be processed.")
except Exception as e:
    print(f"[{script_name}]: {e}")
    sys.exit(1)

if os.path.isdir(DIR_output):
    if any(filename.endswith(".txt") for filename in os.listdir(DIR_output)):
        response = input("Files already exist in the lemma directory. Regenerate files? (y/n)")
        if response != "y" and response != "Y":
            sys.exit(0)
else:
    os.makedirs(DIR_output)

nlp = spacy.load("en_core_web_sm")

print(f"[{script_name}]: Working...")
for i, file in enumerate(input_files):
    if not i % 20: print(f"[{script_name}]: Still working... currently on {os.path.basename(file)}")
    try:
        with open(file, 'r', encoding='windows-1252') as f:
            text = f.read()
        doc = nlp(text)
        lemmas = [token.lemma_ for token in doc]
        output = ' '.join(lemmas)

        output_filepath = DIR_output + "/" + os.path.basename(file)
        with open(output_filepath, 'w') as out:
            out.write(output)
    except Exception as e:
        print(f"[{script_name}]: Issue with {os.path.basename(file)}... {e}")


