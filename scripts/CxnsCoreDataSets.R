source("CxnsCore.R")

######################################################################################################

# filter raw data for various pair subsets

# synonyms
cpSyn <- cxnpairSrc13 %>% dplyr::filter(Ant.Type == "syn" & CorePair == "y")
# unrelated pairs
cpUnrelated <- cxnpairSrc13 %>% dplyr::filter(Ant.Type == "none")
# canonical pairs
cpCanonical <- cxnpairSrc13 %>% dplyr::filter(Canonical == "y")
# all core pairs
cpCore <- cxnpairSrc13 %>% dplyr::filter(CorePair == "y" & Canonical != "u")
# low frequency pairs
cpLowFreq <- cxnpairSrc13 %>% dplyr::filter(LowFreq == "y" & CorePair == "y")
# core pairs excluding canonical / low freq pairs
cpCoreNoCanonNoLowFreq <- cxnpairSrc13 %>% dplyr::filter(CorePair == "y" & Canonical == "n" & LowFreq == "n")
# wordnet-only pairs
cpWordNetOnly <- cxnpairSrc13 %>% dplyr::filter(WordNet == "y" & CorePair == "n")
# all antonyms (excludes synonyms / unrelated pairs)
cpAllAnts <- cxnpairSrc13 %>% dplyr::filter(Canonical != "u")


######################################################################################################

# shows unrelated pairs with a reciprocal match
cxnUnrelatedHasMatch <- cpUnrelated %>% dplyr::filter(numReciprocals != 0)

# shows synonym pairs with a reciprocal match
cxnSynonymHasMatch <- cpSyn %>% dplyr::filter(numReciprocals != 0)

# summarises word matches as a percentage of total matches found when the seed word 
# is in the X position for the given pair set / construction
matchesXPos <- matchesForCxnWordInXPos(cpAllAnts, "morethan", 5)
# and likewise for the Y position
matchesYPos <- matchesForCxnWordInYPos(cpAllAnts, "morethan", 5)


######################################################################################################

# prep dataset for use with mixed-effects modelling

cxnpairMM <- cxnpairSrc13 %>%
  dplyr::mutate(pair_id = pairid, 
                pair = paste0(word1,"-",word2), 
                pair_set = if_else(Canonical == "y", "canonical",
                                   if_else(LowFreq == "y" & CorePair == "y", "lowfreq",
                                           if_else(CorePair == "y" & Canonical == "n" & LowFreq == "n", "othercore",
                                                   if_else(Ant.Type == "none", "unrelated",
                                                           if_else(Ant.Type == "syn" & CorePair == "y", "synonym",
                                                                   if_else(WordNet == "y" & CorePair == "n", "wordnet", "unclassified"
                                                                   ))))))) %>%
  dplyr::select(cxn, pair_id, word1, word2, pair_set, POS, 
                w1XprobY, w1YprobX, w2XprobY,w2YprobX,
                w1XtopY, w1YtopX, w2XtopY,w2YtopX,
                w1XtopYprob, w1YtopXprob, w2XtopYprob, w2YtopXprob,
                w1XYexpected, w1YXexpected, w2XYexpected, w2YXexpected
  ) %>%
  dplyr::filter(pair_set != "unclassified") %>%
  droplevels()


cxnpairW1XY <- cxnpairMM %>%
  dplyr::select(cxn, pair_id, word1, word2, pair_set, POS, w1XprobY, w1XtopY, w1XtopYprob, w1XYexpected
  ) %>%
  dplyr::mutate(seed_position = "X", seed_word = "word1", expected_word = "word2", 
                expected_prob = w1XprobY,
                top_choice_token = w1XtopY, 
                top_choice_prob = w1XtopYprob, 
                is_reciprocal = w1XYexpected           
  ) %>%
  dplyr::select(-w1XprobY, -w1XtopY, -w1XtopYprob, -w1XYexpected) %>% droplevels()

cxnpairW1YX <- cxnpairMM %>%
  dplyr::select(cxn, pair_id, word1, word2, pair_set, POS, w1YprobX, w1YtopX, w1YtopXprob, w1YXexpected
  ) %>%
  dplyr::mutate(seed_position = "Y", seed_word = "word1", expected_word = "word2",
                expected_prob = w1YprobX,
                top_choice_token = w1YtopX, 
                top_choice_prob = w1YtopXprob, 
                is_reciprocal = w1YXexpected
  ) %>%
  dplyr::select(-w1YprobX, -w1YtopX, -w1YtopXprob, -w1YXexpected) %>% droplevels()

cxnpairW2XY <- cxnpairMM %>%
  dplyr::select(cxn, pair_id, word1, word2, pair_set, POS, w2XprobY, w2XtopY, w2XtopYprob, w2XYexpected
  ) %>%
  dplyr::mutate(seed_position = "X", seed_word = "word2", expected_word = "word1",
                expected_prob = w2XprobY,
                top_choice_token = w2XtopY, 
                top_choice_prob = w2XtopYprob, 
                is_reciprocal = w2XYexpected
  ) %>%
  dplyr::select(-w2XprobY, -w2XtopY, -w2XtopYprob, -w2XYexpected) %>% droplevels()

cxnpairW2YX <- cxnpairMM %>%
  dplyr::select(cxn, pair_id, word1, word2, pair_set, POS, w2YprobX, w2YtopX, w2YtopXprob, w2YXexpected
  ) %>%
  dplyr::mutate(seed_position = "Y", seed_word = "word2", expected_word = "word1",
                expected_prob = w2YprobX,
                top_choice_token = w2YtopX, 
                top_choice_prob = w2YtopXprob, 
                is_reciprocal = w2YXexpected
  ) %>%
  dplyr::select(-w2YprobX, -w2YtopX, -w2YtopXprob, -w2YXexpected) %>% droplevels()

cxnpairSingleCfg <- cxnpairW1XY %>%
  dplyr::union(cxnpairW1YX) %>%
  dplyr::union(cxnpairW2XY) %>%
  dplyr::union(cxnpairW2YX) %>% 
  droplevels() %>% mutate_if(is.character,as.factor)

cxnpairSingleCfgRecip <- cxnpairSingleCfg %>% dplyr::filter(not(pair_set %in% c("unrelated","synonym"))) %>% droplevels()

#str(cxnpairSingleCfgRecip) #check datatypes and that chr fields have been converted to factors

