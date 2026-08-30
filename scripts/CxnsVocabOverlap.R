source("CxnsVocabFns.R")

# code used to calculate levels of overlap between pairs found in OR constructions (whether, either, question and or)

keepInvalids = FALSE
keepProform = FALSE
keyFieldsOnly = TRUE
probThreshold = -1
antsOnly = FALSE

npPairsET <- 
  readAndFiltPairs(masterFilesLoc,'antos-eitherX-eitherY-master.csv', 
                   keepInvalids, keepProform, keyFieldsOnly, probThreshold, '', '', FALSE, FALSE)                
npPairsWh <- 
  readAndFiltPairs(masterFilesLoc,'antos-whetherX-whetherY-master.csv', 
                   keepInvalids, keepProform, keyFieldsOnly, probThreshold, '', '', FALSE, FALSE)                
npPairsQ <- 
  readAndFiltPairs(masterFilesLoc,'antos-questionX-questionY-master.csv', 
                   keepInvalids, keepProform, keyFieldsOnly, probThreshold, '', '', FALSE, FALSE)                
npPairsOr <- 
  readAndFiltPairs(masterFilesLoc,'antos-orX-orY-master.csv', 
                   keepInvalids, keepProform, keyFieldsOnly, probThreshold, '', '', FALSE, FALSE)              

if (antsOnly) {
  npPairsWh <- npPairsWh %>% dplyr::filter(nymClass == "antonym")
  npPairsET <- npPairsET %>% dplyr::filter(nymClass == "antonym")
  npPairsQ <- npPairsQ %>% dplyr::filter(nymClass == "antonym")
  npPairsOr <- npPairsOr %>% dplyr::filter(nymClass == "antonym")
}

# generate pairwise overlap by percentage
whRowRed <- getOverlapsOrCxns(npPairsWh, npPairsWh, npPairsET, npPairsQ, npPairsOr)
etRowRed <- getOverlapsOrCxns(npPairsET, npPairsWh, npPairsET, npPairsQ, npPairsOr)
qRowRed <- getOverlapsOrCxns(npPairsQ, npPairsWh, npPairsET, npPairsQ, npPairsOr)
orRowRed <- getOverlapsOrCxns(npPairsOr, npPairsWh, npPairsET, npPairsQ, npPairsOr)

# generate pairwise overlap by number of pairs
whRowNum <- getOverlapNumOrCxns(npPairsWh, npPairsWh, npPairsET, npPairsQ, npPairsOr)
etRowNum <- getOverlapNumOrCxns(npPairsET, npPairsWh, npPairsET, npPairsQ, npPairsOr)
qRowNum <- getOverlapNumOrCxns(npPairsQ, npPairsWh, npPairsET, npPairsQ, npPairsOr)
orRowNum <- getOverlapNumOrCxns(npPairsOr, npPairsWh, npPairsET, npPairsQ, npPairsOr)

npPairsWhCommon <- npPairsWh %>% dplyr::select(-InWordNet, -MinProb, -AntonymType) # %>% dplyr::filter(MinProb > 0.8)
npPairsETCommon <- npPairsET %>% dplyr::select(-InWordNet, -MinProb, -AntonymType) # %>% dplyr::filter(MinProb > 0.8)
npPairsQCommon <- npPairsQ %>% dplyr::select(-InWordNet, -MinProb, -AntonymType) # %>% dplyr::filter(MinProb > 0.8)
npPairsOrCommon <- npPairsOr %>% dplyr::select(-InWordNet, -MinProb, -AntonymType) # %>% dplyr::filter(MinProb > 0.8)

# get number pairs shared by all OR constructions
commonToOrCxns <- npPairsWhCommon %>% 
  dplyr::inner_join(npPairsETCommon, by=c('Seed'='Seed', 'Mask'='Mask','nymClass'='nymClass', 'NymType'='NymType'))  %>%
  dplyr::inner_join(npPairsQCommon, by=c('Seed'='Seed', 'Mask'='Mask','nymClass'='nymClass', 'NymType'='NymType'))  %>%
  dplyr::inner_join(npPairsOrCommon, by=c('Seed'='Seed', 'Mask'='Mask','nymClass'='nymClass', 'NymType'='NymType')) %>%
  dplyr::group_by(nymClass) %>%
  dplyr::summarise(nyms = n()) %>%
  rbind(c("proform",as.numeric(0))) %>%
  dplyr::mutate(nyms = as.numeric(nyms))

commonToOrCxns <- orderLevels(commonToOrCxns, "both") 

