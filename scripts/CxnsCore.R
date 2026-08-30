source("CxnsCoreMatchFns.R")

# combine the core and wordnet pair data with the results of running construction mask tests

antpairs <- read.csv('../data/selected-pairs.csv')
cxnpairs <- read.csv('../data/cxns-plus-pairs.csv')

totalPairs <- nrow(antpairs)
cxnpairs <- prepCxnPairs(cxnpairs)

antpairSrc <- antpairs  %>%          
  dplyr::select(pairid, Canonical, Ant.Type, Jones2002, Jones2012, Paradis2009Judge, Paradis2009Elicit, deWeijer2012, 
                CorePair, WordNet, LowFreq, POS)

cxnpairSrc <- cxnpairs %>% dplyr::full_join(antpairSrc, by = "pairid")

# restricts mask test data to the 13 constructions analysed in part 1 of the dissertation results
cxnpairSrc13 <- filterCxns(cxnpairSrc, 5)
