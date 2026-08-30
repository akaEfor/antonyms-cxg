source("CxnsVocabFns.R")

threshold1 = 0.65
threshold2 = 0.8

#########################################################################################################
# Read in annotated files for various constructions, applying selected filter criteria, and look 
# at the breakdown by contrast type for different constructions and at different probability thresholds


#############
# whether

# all pairs found in one or other of the whether configurations (whetherX, whetherY)
pairsWh <- readAndFiltPairs(masterFilesLoc,'antos-whetherX-whetherY-master.csv', TRUE, TRUE, FALSE, -1, '', '', FALSE, FALSE)   

# excludes invalid pairs 
pairsWhNoInvalids <- readAndFiltPairs(masterFilesLoc,'/antos-whetherX-whetherY-master.csv', FALSE, TRUE, FALSE, -1, '', '', FALSE, FALSE)   

# pairs found in the whetherX configuration
pairsWhX <- readAndFiltPairs(masterFilesLoc,'antos-whetherX-whetherY-master.csv', FALSE, TRUE, FALSE, -1, 'whetherY', '', FALSE, FALSE)               

# pairs found in the whetherY configuration
pairsWhY <- readAndFiltPairs(masterFilesLoc,'antos-whetherX-whetherY-master.csv', FALSE, TRUE, FALSE, -1, 'whetherX', '', FALSE, FALSE)   

# pairs that retrieved each other as the top choice in the whetherX configuration 
pairsWhXRecip <- readAndFiltPairs(masterFilesLoc,'antos-whetherX-whetherY-master.csv', FALSE, FALSE, FALSE, -1, 'whetherY', '', TRUE, FALSE)               

# pairs that retrieved each other as the top choice in the whetherY configuration 
pairsWhYRecip <- readAndFiltPairs(masterFilesLoc,'antos-whetherX-whetherY-master.csv', FALSE, FALSE, FALSE, -1, 'whetherX', '', FALSE, TRUE)    

# pairs that retrieved each other as the top choice in one or other of the whether configurations
pairsWhRecip <- readAndFiltPairs(masterFilesLoc,'antos-whetherX-whetherY-master.csv', FALSE, FALSE, FALSE, -1, '', '', TRUE, TRUE)    

# pairs that were found in both whether configurations
pairsWhBothOnly <- readAndFiltPairs(masterFilesLoc,'antos-whetherX-whetherY-master.csv', FALSE, FALSE, FALSE, -1, 'whetherX', 'whetherY', FALSE, FALSE)               

# the nymClasses() function shows the split of antonyms / co-hyponyms / residual and other contrasts
# in the given dataset at the 0.5, 0.65 and 0.8 probability thresholds, both in raw numbers and percentage-wise
# the various datasets below apply nymClasses() to differently filtered versions of the whether construction 
# pairs (e.g. with or without invalid pairs, proforms etc.)
classesWh <- nymClasses(pairsWh, threshold1, threshold2)
classesWhNoInvalids <- nymClasses(pairsWhNoInvalids, threshold1, threshold2)
classesWhNoInvalidsNoProform <- nymClasses(filtProform(pairsWhNoInvalids), threshold1, threshold2)
numNymsT1 <- sum(classesWhNoInvalidsNoProform$nymsT1)
numNymsT2 <- sum(classesWhNoInvalidsNoProform$nymsT2)
classesWhXNoInvalids <- nymClasses(pairsWhX, threshold1, threshold2)
classesWhYNoInvalids <- nymClasses(pairsWhY, threshold1, threshold2)

pairsWhNoProform <- filtProform(pairsWh)                   
classesWhNoProform <- nymClasses(pairsWhNoProform, threshold1, threshold2)
classesWhXNoProform <- nymClasses(pairsWhX, threshold1, threshold2)
classesWhYNoProform <- nymClasses(pairsWhY, threshold1, threshold2)
classesWhXRecip <- nymClasses(pairsWhXRecip, threshold1, threshold2)
classesWhYRecip <- nymClasses(pairsWhYRecip, threshold1, threshold2)
classesWhRecip <- nymClasses(pairsWhRecip, threshold1, threshold2)
classesWhBothNoProform <- nymClasses(pairsWhBothOnly, threshold1, threshold2)

#############
# either
pairsET <- readAndFiltPairs(masterFilesLoc,'antos-eitherX-eitherY-master.csv', TRUE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsETNoInvalids <- readAndFiltPairs(masterFilesLoc,'antos-eitherX-eitherY-master.csv', FALSE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsETRecip <- readAndFiltPairs(masterFilesLoc,'antos-eitherX-eitherY-master.csv', FALSE, FALSE, FALSE, -1, '', '', TRUE, TRUE)    

classesET <- nymClasses(pairsET, threshold1, threshold2)
classesETNoInvalids <- nymClasses(pairsETNoInvalids, threshold1, threshold2)
classesETRecip <- nymClasses(pairsETRecip, threshold1, threshold2)
classesETNoInvalids <- orderLevels(classesETNoInvalids, "both") 
classesETNoInvalidsNoProform <- nymClasses(filtProform(pairsETNoInvalids), threshold1, threshold2)
numNymsT1 <- sum(classesETNoInvalidsNoProform$nymsT1)
numNymsT2 <- sum(classesETNoInvalidsNoProform$nymsT2)
pairsETNoProform <- filtProform(pairsET)                   
classesETNoProform <- nymClasses(pairsETNoProform, threshold1, threshold2)
classesETPOS <- posClasses(filtProform(pairsETNoInvalids))
classesETPOSAnts <- posClasses(dplyr::filter(filtProform(pairsETNoInvalids), nymClass == "antonym"))

#############
# question
pairsQ <- readAndFiltPairs(masterFilesLoc,'antos-questionX-questionY-master.csv', TRUE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsQNoInvalids <- readAndFiltPairs(masterFilesLoc,'antos-questionX-questionY-master.csv', FALSE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsQRecip <- readAndFiltPairs(masterFilesLoc,'antos-questionX-questionY-master.csv', FALSE, FALSE, FALSE, -1, '', '', TRUE, TRUE)    

classesQ <- nymClasses(pairsQ, threshold1, threshold2)
classesQNoInvalids <- nymClasses(pairsQNoInvalids, threshold1, threshold2)
classesQRecip <- nymClasses(pairsQRecip, threshold1, threshold2)
classesQNoInvalids <- orderLevels(classesQNoInvalids, "both") 
classesQNoInvalidsNoProform <- nymClasses(filtProform(pairsQNoInvalids), threshold1, threshold2)
numNymsT1 <- sum(classesQNoInvalidsNoProform$nymsT1)
numNymsT2 <- sum(classesQNoInvalidsNoProform$nymsT2)
pairsQNoProform <- filtProform(pairsQ)                           
classesQNoProform <- nymClasses(pairsQNoProform, threshold1, threshold2)
classesQPOS <- posClasses(filtProform(pairsQNoInvalids))
classesQPOSAnts <- posClasses(dplyr::filter(filtProform(pairsQNoInvalids), nymClass == "antonym"))

#############
# or
pairsOr <- readAndFiltPairs(masterFilesLoc,'antos-orX-orY-master.csv', TRUE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsOrNoInvalids <- readAndFiltPairs(masterFilesLoc,'antos-orX-orY-master.csv', FALSE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsOrRecip <- readAndFiltPairs(masterFilesLoc,'antos-orX-orY-master.csv', FALSE, FALSE, FALSE, -1, '', '', TRUE, TRUE)    

classesOr <- nymClasses(pairsOr, threshold1, threshold2)
classesOrNoInvalids <- nymClasses(pairsOrNoInvalids, threshold1, threshold2)
classesOrRecip <- nymClasses(pairsOrRecip, threshold1, threshold2)
classesOrNoInvalids <- orderLevels(classesOrNoInvalids, "both") 
classesOrNoInvalidsNoProform <- nymClasses(filtProform(pairsOrNoInvalids), threshold1, threshold2)
numNymsT1 <- sum(classesOrNoInvalidsNoProform$nymsT1)
numNymsT2 <- sum(classesOrNoInvalidsNoProform$nymsT2)
pairsOrNoProform <- filtProform(pairsOr)                          
classesOrNoProform <- nymClasses(pairsOrNoProform, threshold1, threshold2)
classesOrPOS <- posClasses(filtProform(pairsOrNoInvalids))
classesOrPOSAnts <- posClasses(dplyr::filter(filtProform(pairsOrNoInvalids), nymClass == "antonym"))

#############
# alike
pairsAlike <- readAndFiltPairs(masterFilesLoc,'antos-alikeX-alikeY-master.csv', TRUE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsAlikeNoInvalids <- readAndFiltPairs(masterFilesLoc,'antos-alikeX-alikeY-master.csv', FALSE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsAlikeRecip <- readAndFiltPairs(masterFilesLoc,'antos-alikeX-alikeY-master.csv', FALSE, FALSE, FALSE, -1, '', '', TRUE, TRUE)    

classesAlike <- nymClasses(pairsAlike, threshold1, threshold2)
classesAlikeNoInvalids <- nymClasses(pairsAlikeNoInvalids, threshold1, threshold2)
classesAlikeRecip <- nymClasses(pairsAlikeRecip, threshold1, threshold2)
classesAlikeNoInvalids <- orderLevels(classesAlikeNoInvalids, "both") 
classesAlikeNoInvalidsNoProform <- nymClasses(filtProform(pairsAlikeNoInvalids), threshold1, threshold2)
pairsAlikeNoProform <- filtProform(pairsAlike)                      
classesAlikeNoProform <- nymClasses(pairsAlikeNoProform, threshold1, threshold2)
classesAlikePOS <- posClasses(filtProform(pairsAlikeNoInvalids))
classesAlikePOSAnts <- posClasses(dplyr::filter(filtProform(pairsAlikeNoInvalids), nymClass == "antonym"))

#############
# both
pairsBoth <- readAndFiltPairs(masterFilesLoc,'antos-bothX-bothY-master.csv', TRUE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsBothNoInvalids <- readAndFiltPairs(masterFilesLoc,'antos-bothX-bothY-master.csv', FALSE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsBothRecip <- readAndFiltPairs(masterFilesLoc,'antos-bothX-bothY-master.csv', FALSE, FALSE, FALSE, -1, '', '', TRUE, TRUE)    

classesBoth <- nymClasses(pairsBoth, threshold1, threshold2)
classesBothNoInvalids <- nymClasses(pairsBothNoInvalids, threshold1, threshold2)
classesBothRecip <- nymClasses(pairsBothRecip, threshold1, threshold2)
classesBothNoInvalids <- orderLevels(classesBothNoInvalids, "Y") 
classesBothNoInvalidsNoProform <- nymClasses(filtProform(pairsBothNoInvalids), threshold1, threshold2)
pairsBothNoProform <- filtProform(pairsBoth)                      
classesBothNoProform <- nymClasses(pairsBothNoProform, threshold1, threshold2)
classesBothPOS <- posClasses(filtProform(pairsBothNoInvalids))
classesBothPOSAnts <- posClasses(dplyr::filter(filtProform(pairsBothNoInvalids), nymClass == "antonym"))

#############
# neither
pairsNtr <- readAndFiltPairs(masterFilesLoc,'antos-neitherX-neitherY-master.csv', TRUE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsNtrNoInvalids <- readAndFiltPairs(masterFilesLoc,'antos-neitherX-neitherY-master.csv', FALSE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsNtrRecip <- readAndFiltPairs(masterFilesLoc,'antos-neitherX-neitherY-master.csv', FALSE, FALSE, FALSE, -1, '', '', TRUE, TRUE)    

classesNtr <- nymClasses(pairsNtr, threshold1, threshold2)
classesNtrNoInvalids <- nymClasses(pairsNtrNoInvalids, threshold1, threshold2)
classesNtrRecip <- nymClasses(pairsNtrRecip, threshold1, threshold2)
classesNtrNoInvalids <- orderLevels(classesNtrNoInvalids, "both") 
classesNtrNoInvalidsNoProform <- nymClasses(filtProform(pairsNtrNoInvalids), threshold1, threshold2)
pairsNtrNoProform <- filtProform(pairsNtr)                            
classesNtrNoProform <- nymClasses(pairsNtrNoProform, threshold1, threshold2)
classesNtrPOS <- posClasses(filtProform(pairsNtrNoInvalids))
classesNtrPOSAnts <- posClasses(dplyr::filter(filtProform(pairsNtrNoInvalids), nymClass == "antonym"))

#############
# ratherthan
pairsRather <- readAndFiltPairs(masterFilesLoc,'antos-ratherX-ratherY-master.csv', TRUE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsRatherNoInvalids <- readAndFiltPairs(masterFilesLoc,'antos-ratherX-ratherY-master.csv', FALSE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsRatherRecip <- readAndFiltPairs(masterFilesLoc,'antos-ratherX-ratherY-master.csv', FALSE, FALSE, FALSE, -1, '', '', TRUE, TRUE)    

classesRather <- nymClasses(pairsRather, threshold1, threshold2)
classesRatherNoInvalids <- nymClasses(pairsRatherNoInvalids, threshold1, threshold2)
classesRatherRecip <- nymClasses(pairsRatherRecip, threshold1, threshold2)
classesRatherNoInvalids <- orderLevels(classesRatherNoInvalids, "Y") 
classesRatherNoInvalidsNoProform <- nymClasses(filtProform(pairsRatherNoInvalids), threshold1, threshold2)
classesRatherPOS <- posClasses(filtProform(pairsRatherNoInvalids))
classesRatherPOSAnts <- posClasses(dplyr::filter(filtProform(pairsRatherNoInvalids), nymClass == "antonym"))

#############
# and
pairsAnd <- readAndFiltPairs(masterFilesLoc,'antos-X-and-mask-mask-and-X-master.csv', TRUE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsAndNoInvalids <- readAndFiltPairs(masterFilesLoc,'antos-X-and-mask-mask-and-X-master.csv', FALSE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsAndRecip <- readAndFiltPairs(masterFilesLoc,'antos-X-and-mask-mask-and-X-master.csv', FALSE, FALSE, FALSE, -1, '', '', TRUE, TRUE)    

classesAnd <- nymClasses(pairsAnd, threshold1, threshold2)
classesAndNoInvalids <- nymClasses(pairsAndNoInvalids, threshold1, threshold2)
classesAndRecip <- nymClasses(pairsAndRecip, threshold1, threshold2)
classesAndNoInvalids <- orderLevels(classesAndNoInvalids, "both") 
classesAndNoInvalidsNoProform <- nymClasses(filtProform(pairsAndNoInvalids), threshold1, threshold2)
classesAndPOS <- posClasses(filtProform(pairsAndNoInvalids))
classesAndPOSAnts <- posClasses(dplyr::filter(filtProform(pairsAndNoInvalids), nymClass == "antonym"))

classesAndAdj <- classesAndPOS %>% dplyr::filter(posClass == 'adjective') %>% dplyr::select(-posClass) %>% droplevels()
#classesAndAdj <- orderLevels(classesAndAdj, "pos") 
classesAndAdv <- classesAndPOS %>% dplyr::filter(posClass == 'adverb') %>% dplyr::select(-posClass) %>% droplevels()
#classesAndAdv <- orderLevels(classesAndAdv, "pos") 
classesAndNoun <- classesAndPOS %>% dplyr::filter(posClass == 'noun') %>% dplyr::select(-posClass) %>% droplevels()
#classesAndNoun <- orderLevels(classesWhNoun, "pos") 
classesAndVerb <- classesAndPOS %>% dplyr::filter(posClass == 'verb') %>% dplyr::select(-posClass) %>% droplevels()
#classesAndVerb <- orderLevels(classesWhVerb, "pos") 
classesAndOther <- classesAndPOS %>% dplyr::filter(posClass == 'other') %>% dplyr::select(-posClass) %>% droplevels()
#classesAndOther <- orderLevels(classesAndOther, "other") 

#############
# fromto
pairsFrom <- readAndFiltPairs(masterFilesLoc,'antos-fromX-fromY-master.csv', TRUE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsFromNoInvalids <- readAndFiltPairs(masterFilesLoc,'antos-fromX-fromY-master.csv', FALSE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsFromRecip <- readAndFiltPairs(masterFilesLoc,'antos-fromX-fromY-master.csv', FALSE, FALSE, FALSE, -1, '', '', TRUE, TRUE)    

classesFrom <- nymClasses(pairsFrom, threshold1, threshold2)
classesFromNoInvalids <- nymClasses(pairsFromNoInvalids, threshold1, threshold2)
classesFromRecip <- nymClasses(pairsFromRecip, threshold1, threshold2)
classesFromNoInvalids <- orderLevels(classesFromNoInvalids, "Y") 
classesFromNoInvalidsNoProform <- nymClasses(filtProform(pairsFromNoInvalids), threshold1, threshold2)
classesFromPOS <- posClasses(filtProform(pairsFromNoInvalids))
classesFromPOSAnts <- posClasses(dplyr::filter(filtProform(pairsFromNoInvalids), nymClass == "antonym"))

#############
# between
pairsBtwn <- readAndFiltPairs(masterFilesLoc,'antos-betweenX-betweenY-master.csv', TRUE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsBtwnNoInvalids <- readAndFiltPairs(masterFilesLoc,'antos-betweenX-betweenY-master.csv', FALSE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsBtwnRecip <- readAndFiltPairs(masterFilesLoc,'antos-betweenX-betweenY-master.csv', FALSE, FALSE, FALSE, -1, '', '', TRUE, TRUE)    

classesBtwn <- nymClasses(pairsBtwn, threshold1, threshold2)
classesBtwnNoInvalids <- nymClasses(pairsBtwnNoInvalids, threshold1, threshold2)
classesBtwnRecip <- nymClasses(pairsBtwnRecip, threshold1, threshold2)
classesBtwnNoInvalids <- orderLevels(classesBtwnNoInvalids, "Y") 
classesBtwnNoInvalidsNoProform <- nymClasses(filtProform(pairsBtwnNoInvalids), threshold1, threshold2)
classesBtwnPOS <- posClasses(filtProform(pairsBtwnNoInvalids))
classesBtwnPOSAnts <- posClasses(dplyr::filter(filtProform(pairsBtwnNoInvalids), nymClass == "antonym"))

#############
# versus
pairsVs <- readAndFiltPairs(masterFilesLoc,'antos-versusX-versusY-master.csv', TRUE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsVsNoInvalids <- readAndFiltPairs(masterFilesLoc,'antos-versusX-versusY-master.csv', FALSE, TRUE, FALSE, -1, '', '', FALSE, FALSE)               
pairsVsRecip <- readAndFiltPairs(masterFilesLoc,'antos-versusX-versusY-master.csv', FALSE, FALSE, FALSE, -1, '', '', TRUE, TRUE)    

classesVs <- nymClasses(pairsVs, threshold1, threshold2)
classesVsNoInvalids <- nymClasses(pairsVsNoInvalids, threshold1, threshold2)
classesVsRecip <- nymClasses(pairsVsRecip, threshold1, threshold2)
classesVsNoInvalids <- orderLevels(classesVsNoInvalids, "Y") 
classesVsNoInvalidsNoProform <- nymClasses(filtProform(pairsVsNoInvalids), threshold1, threshold2)
classesVsPOS <- posClasses(filtProform(pairsVsNoInvalids))
classesVsPOSAnts <- posClasses(dplyr::filter(filtProform(pairsVsNoInvalids), nymClass == "antonym"))



