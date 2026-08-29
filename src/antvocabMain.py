import csv
import torch

from antinit import *   # init plm, tokeniser, home dir
from antvocab import *


unmasker, model, tokeniser = initUnmasker(1)

###### run for a single mask
cxn = "whetherY"
vocab = getVocab(tokeniser, cxn) 
path = f"{HOME_DIR}/data/antos-{cxn}.csv"
runVocabMaskTests(unmasker, cxn, vocab, path)

###### run for a pair of masks (for the X and Y positions)
#cxn1 = "whetherX"
#cxn2 = "whetherY"
#vocab = getVocab(tokeniser, cxn1) # will assume same exclude list for both cxns
#path = f"{HOME_DIR}/data/antos-{cxn1}-{cxn2}.csv"
#runPairedVocabTests(unmasker, cxn1, cxn2, vocab, path)


###### update one file with pair data from another, where pairs are found to match
#fileToUpdate = "antdata/antos-aswellasX-aswellasY.csv"
#updateFrom = "antdata/master-cxn-pair-files/antos-whetherX-whetherY-master.csv"
#resultPath = "antdata/antos-aswellasX-aswellasY-updated.csv"

##updateAntos(fileToUpdate, updateFrom, resultPath, False)
#updateAntosCxnPairs(fileToUpdate, updateFrom, resultPath)

#dedupPairs(fileToUpdate, resultPath)
