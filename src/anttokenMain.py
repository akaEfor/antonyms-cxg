from antinit import *   # init plm / tokeniser, home dir
from anttoken import *

tokeniser = initTokeniser()

corePairCandidates = HOME_DIR + "/data/candidate-pairs.csv"
corePairSelected = HOME_DIR + "/data/selected-pairs.csv"

nyms = readNyms(corePairCandidates)

# checks a set of antonym pairs:
# removes any pairs with a word that is more than a single mid-sentence token
# adds columns that indicate WordNet antonyms for both words in the pair and the number of WordNet synsets in which they are found (if any) 
checkOOVList(tokeniser, nyms, corePairSelected)
