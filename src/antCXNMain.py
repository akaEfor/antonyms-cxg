import pandas as pd

from antinit import *   # init plm / tokeniser, home dir
from antCXN import *

inputFile = HOME_DIR + "/data/selected-pairs.csv"
outputFile = HOME_DIR + "/data/cxns-plus-pairs.csv"

cxns = [('alike','j-coordinated'),
         ('whether','j-coordinated'),
         ('either','j-coordinated'),
         ('neither','j-coordinated'),
         ('both','j-coordinated'),
         ('aswellas','j-coordinated'),
         ('or','j-coordinated'),
         ('and','j-coordinated'),
         ('XnotY','j-negated'),
         ('XcommanotY','j-negated'),
         ('notXbutY','j-negated'),
         ('notXcommaY','j-negated'),
         ('XandnotY','j-negated'),
         ('insteadof','j-negated'),
         ('opposedto','j-negated'),
         ('XbutnotY','restrictive'),
         ('notXbutnotY','negatedX2'),
         ('notonlyXbutY','additive'),
         ('notXbutjustY','restrictive'),
         ('morethan','j-comparative'),
         ('ratherthan','j-comparative'),
         ('between','j-distinguished'),
         ('fromto','j-transitional'),
         ('question','j-interrogative'),
         ('XbutY','contrastive'),
         ('XyetY','contrastive'), 
         ('versus','j-residual')         
        ]
#cxns = [('alike','j-coordinated')]

stripTrailingSpace = True

unmasker, model, tokeniser = initUnmasker()

pairs = readPairs(inputFile)
results = runTemplatesForAll(model, tokeniser, unmasker, cxns, pairs, stripTrailingSpace)
df = pd.DataFrame(results)
df.to_csv(outputFile, index_label= 'idx')
