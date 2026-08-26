# antonyms-cxg
Supporting code and data for MPhil Linguistics dissertation on Antonyms in Constructions

---

To (re)generate the selected core pairs (./data/selected-pairs.csv) from the candidate pairs (./data/candidate-pairs.csv): 

`%run ./src/anttoken.py`

This checks for tokenisation and adds some WordNet columns.

---

To (re)generate the list of sample WordNet antonyms for test:

`%run ./src/antPOSlist.py`

This processes the adjective, noun and verb pairs that were accessed from: 

https://www.ims.uni-stuttgart.de/en/research/resources/experiment-data/antonym-synonym-dataset/ 

Pairs are filtered to include antonyms only, checked for PLM tokenisation, de-duped within and across files, and also de-duped w.r.t. the core pair set. Note: this results in 548 WordNet direct antonym pairs whereas 549 were included in the selected-pairs file - the additional pair is *beginning/end*, which WordNet records as a direct antonym in one direction only but made it into the sample set anyway.

---
