from antinit import *   # init plm, tokeniser, home dir
from antPOS import *

WN_HOME = HOME_DIR + "/data/wordnet"
WN_SRC = WN_HOME + "/nguyen-et-al/"
WN_SG_TKN = WN_HOME + "/single-token/"

tokeniser = initTokeniser()

processNyms(tokeniser, WN_SRC + "adj-all.csv", WN_SG_TKN + "adj-wn-single-token.csv", "adj")
processNyms(tokeniser, WN_SRC + "nouns-all.csv", WN_SG_TKN + "noun-wn-single-token.csv", "noun")
processNyms(tokeniser, WN_SRC + "verbs-all.csv", WN_SG_TKN + "verb-wn-single-token.csv", "verb")

adjNyms = readNyms(WN_SG_TKN + "adj-wn-single-token.csv")
nounNyms = readNyms(WN_SG_TKN + "noun-wn-single-token.csv")
verbNyms = readNyms(WN_SG_TKN + "verb-wn-single-token.csv")
corePairs = readNyms(HOME_DIR + "/data/selected-pairs-core-only.csv")

dedupLists(adjNyms, nounNyms, verbNyms, corePairs, WN_SG_TKN + "all-wn-single-token.csv")
