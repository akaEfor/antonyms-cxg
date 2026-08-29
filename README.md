# antonyms-cxg
Supporting code and data for MPhil Linguistics dissertation on Antonyms in Constructions

---

To (re)generate the selected core pairs (./data/selected-pairs.csv) from the candidate pairs (./data/candidate-pairs.csv): 

`%run ./src/anttokenMain.py`

This checks for tokenisation and adds some WordNet columns.

---

To (re)generate the list of sample WordNet antonyms for test:

`%run ./src/antPOSMain.py`

This processes the adjective, noun and verb pairs that were accessed from: 

https://www.ims.uni-stuttgart.de/en/research/resources/experiment-data/antonym-synonym-dataset/ 

Pairs are filtered to include antonyms only, checked for PLM tokenisation, de-duped within and across files, and also de-duped w.r.t. the core pair set. Note: this results in 548 WordNet direct antonym pairs whereas 549 were included in the selected-pairs file - the additional pair is *beginning/end*, which WordNet records as a direct antonym in one direction only but made it into the sample set anyway.

---

To run construction mask tests for all core and WordNet pairs:

`%run ./src/antCXNMain.py`

Runs each pair through four different mask configuration for each construction, recording the top 5 mask predictions in each configuration, along with the probability of retrieving the other member of the pair being tested. Modify the cxns array to run this for a subset of constructions (default list includes 27 different constructions, more than analysed in the final dissertation).

---

To run full vocabulary tests for a construction:

`%run ./src/antvocabMain.py`

Modify the file to update the construction to test. Use `runVocabMaskTests` for testing a single construction mask template; use `runPairedVocabTests` to run paired vocabulary based tests - intended for testing a construction with masks in both the X and Y positions. See the `./src/antvocab.py` file for the list of construction templates; the `cxn` variable expects a string defined in this file e.g. `whetherX` which corresponds to the template `whether X or <mask>` where X is a token from the vocabulary under test. 
The `updateAntosCxnPairs` function also referenced in this file is used for updating one set of paired construction results from another (used when the first set of results has been hand-annotated and we want to update a second set of results with that annotation information, where there are pairs found in common).

---
