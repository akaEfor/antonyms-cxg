# Utility functions related to processing of files generated from full-vocabulary tests

combineProb <- function(pairs) {
  res <- pairs %>% 
    dplyr::mutate(
      MinProb = if_else(is.na(ProbX), 
                        ProbY,
                        if_else(is.na(ProbY), 
                                ProbX,
                                if_else(ProbX > ProbY, ProbY, ProbX))),
      MaxProb = if_else(is.na(ProbX), 
                        ProbY,
                        if_else(is.na(ProbY), 
                                ProbX,
                                if_else(ProbX > ProbY, ProbX, ProbY)))     
    )
}

filtProform <- function(pairs) {
  res <- pairs %>% dplyr::filter(NymType != 'proform')   
}

filtInvalids <- function(pairs) {
  res <- pairs %>% dplyr::filter(!startsWith(as.character(NymType), 'x-'))    
}

filtCxn <- function(pairs, excludeCxn) {
  res <- pairs %>% dplyr::filter(Cxn != as.character(excludeCxn))   
}

selectKeyFields <- function(pairs) {
  res <- pairs %>% 
    dplyr::select(Seed, Mask, InWordNet, MinProb, nymClass, NymType, AntonymType)
}

filtPairs <- function(pairs, keepInvalids, keepProform, keyFieldsOnly, probThreshold, 
                      excludeCxn1, excludeCxn2, Xpaired, Ypaired) {
  res <- pairs %>% 
    dplyr::select(-WordsMatch) %>%
    dplyr::mutate(
      nymClass = if_else(
        startsWith(as.character(NymType), 'antonym'), 'antonym',
          if_else(startsWith(as.character(NymType), 'co-hyponym'), 'co-hyponym',
            if_else(startsWith(as.character(NymType), 'x-'), 'excluded',
                    if_else(NymType == 'proform', 'proform', 'residual'
                            ) ) ) ) )

  res <- combineProb(res)

  if (keepInvalids == FALSE) {
    res <- filtInvalids(res) 
  }

  if (keepProform == FALSE) {
    res <- filtProform(res) 
  }
  
  if (excludeCxn1 != '') {
    res <- filtCxn(res, excludeCxn1) 
  }

  if (excludeCxn2 != '') {
    res <- filtCxn(res, excludeCxn2) 
  }

  if (Xpaired == TRUE & Ypaired == FALSE) {
    res <- res %>% dplyr::filter(HasPairX == 'paired')   
  }
  else if (Xpaired == FALSE & Ypaired == TRUE) {
    res <- res %>% dplyr::filter(HasPairY == 'paired')   
  }
  else if (Xpaired == TRUE & Ypaired == TRUE) {
    res <- res %>% dplyr::filter(HasPairX == 'paired' | HasPairY == 'paired')   
  }
  
  if (keyFieldsOnly == TRUE) {
    res <- selectKeyFields(res) 
  }
  
  if (probThreshold != -1) {
    res <- res %>% dplyr::filter(MinProb > probThreshold)
  }
  
  res
  
}

readAndFiltPairs <- function(dir, file, keepInvalids, keepProform, keyFieldsOnly, probThreshold, 
                             excludeCxn1, excludeCxn2, Xpaired, Ypaired) {
  path <- paste0(dir,file)
  res <- read.csv(path)
  res <- filtPairs(res, keepInvalids, keepProform, keyFieldsOnly, probThreshold, 
                   excludeCxn1, excludeCxn2, Xpaired, Ypaired)
}

updatePOS <- function(pairs) {
  res <- pairs %>% 
    dplyr::mutate(
      posClass = if_else(
        startsWith(as.character(POS), 'adj'), 'adjective',
        if_else(startsWith(as.character(POS), 'noun'), 'noun',
                if_else(startsWith(as.character(POS), 'verb'), 'verb',
                        if_else(startsWith(as.character(POS), 'adv'), 'adverb', 'other'
                        ) ) ) ))
}

posClasses <- function(dfPairs) {
  posPairs <- updatePOS(dfPairs)
  nPairs <- nrow(posPairs)
  
  cls <- posPairs %>% dplyr::group_by(nymClass, posClass) %>% 
    dplyr::summarise(nyms = n(), 
                     pcNyms = round(n() * 100 / nPairs, 1)
    )
}


nymClasses <- function(dfPairs, threshold1, threshold2) {
  nPairs <- nrow(dfPairs)
  nPairsT1 <- nrow(dplyr::filter(dfPairs, MinProb > threshold1))
  nPairsT2 <- nrow(dplyr::filter(dfPairs, MinProb > threshold2))
  
  cls <- dfPairs %>% dplyr::group_by(nymClass) %>% 
    dplyr::summarise(nyms = n(), 
                     nymsT1 = sum(MinProb > threshold1), 
                     nymsT2 = sum(MinProb > threshold2), 
                     pcNyms = round(n() * 100 / nPairs, 1), 
                     pcNymsT1 = round(sum(MinProb > threshold1) * 100 / nPairsT1, 1),
                     pcNymsT2 = round(sum(MinProb > threshold2) * 100 / nPairsT2, 1),
                     pcWN = round(sum(InWordNet == 'y') * 100 / nPairs, 1),
                     pcWNT1 = round(sum(InWordNet == 'y' & MinProb > threshold1) * 100 / nPairsT1, 1),
                     pcWNT2 = round(sum(InWordNet == 'y' & MinProb > threshold2) * 100 / nPairsT2, 1)
                     )
}
  
#nymClassesProb <- function(dfPairs, probThreshold) {
#  hiProb <- dfPairs %>% dplyr::filter(MinProb > probThreshold)
#  cls <- nymClasses(hiProb)
#}

pairsWithMask <- function(whpairs, str) {
  res <- whpairs %>% dplyr::filter(startsWith(as.character(Mask), str))
}

pairsWithSeed <- function(whpairs, str) {
  res <- whpairs %>% dplyr::filter(startsWith(as.character(Seed), str))
}

pairsWithDomain <- function(whpairs, str) {
  res <- whpairs %>% dplyr::filter(grepl(str, Domain, ignore.case = TRUE))
}

overlapNum <- function(leftPairs, rightPairs) {
  joinPairs <- leftPairs %>% dplyr::inner_join(rightPairs, by=c('Seed'='Seed', 'Mask'='Mask')) 
  overlap = nrow(joinPairs)
}

overlapRatio <- function(leftPairs, rightPairs) {
  nLeft = nrow(leftPairs)
  nBoth <- overlapNum(leftPairs, rightPairs)
  res <- round(nBoth / nLeft, 2)
}

getOverlaps <- function(rightPairs, npPairsAlike, npPairsBoth, npPairsNtr, npPairsET, npPairsWh, npPairsQ, npPairsOr) {
  
  ratioAA <- overlapRatio(npPairsAlike, rightPairs)
  ratioAB <- overlapRatio(npPairsBoth, rightPairs)
  ratioAN <- overlapRatio(npPairsNtr, rightPairs)
  ratioAE <- overlapRatio(npPairsET, rightPairs)
  ratioAW <- overlapRatio(npPairsWh, rightPairs)
  ratioAQ <- overlapRatio(npPairsQ, rightPairs)
  ratioAO <- overlapRatio(npPairsOr, rightPairs)
  ratios <- c(ratioAA, ratioAB, ratioAN, ratioAE, ratioAW, ratioAQ, ratioAO)
}

getOverlapsOrCxns <- function(rightPairs, npPairsWh, npPairsET, npPairsQ, npPairsOr) {
  
  ratioAW <- overlapRatio(npPairsWh, rightPairs)
  ratioAE <- overlapRatio(npPairsET, rightPairs)
  ratioAQ <- overlapRatio(npPairsQ, rightPairs)
  ratioAO <- overlapRatio(npPairsOr, rightPairs)
  ratios <- c(ratioAW, ratioAE, ratioAQ, ratioAO)
}

getOverlapNumOrCxns <- function(rightPairs, npPairsWh, npPairsET, npPairsQ, npPairsOr) {
  
  ratioAW <- overlapNum(npPairsWh, rightPairs)
  ratioAE <- overlapNum(npPairsET, rightPairs)
  ratioAQ <- overlapNum(npPairsQ, rightPairs)
  ratioAO <- overlapNum(npPairsOr, rightPairs)
  ratios <- c(ratioAW, ratioAE, ratioAQ, ratioAO)
}

orderLevels <- function(summaryClasses, antSet) {
  if (antSet == "Y") {
    summaryClasses <- summaryClasses %>%
      rbind(c("proform",as.numeric(0),as.numeric(0),as.numeric(0),as.numeric(0),as.numeric(0),as.numeric(0),
              as.numeric(0),as.numeric(0),as.numeric(0))) %>%
      dplyr::mutate(nyms = as.numeric(nyms))
  }
  if (antSet %in% c("Y","X","both")) {
    summaryClasses <- summaryClasses %>%
      dplyr::mutate(nymClass = fct_relevel(nymClass, "proform", "residual", "co-hyponym", "antonym"))
  }

  if (antSet == "other") {
    summaryClasses <- summaryClasses %>%
      rbind(c("residual",as.numeric(0),as.numeric(0),as.numeric(0),as.numeric(0),as.numeric(0),as.numeric(0),
              as.numeric(0),as.numeric(0),as.numeric(0))) %>%
      dplyr::mutate(nyms = as.numeric(nyms))
  }
    
  if (antSet %in% c("pos","other")) {
    summaryClasses <- summaryClasses %>% dplyr::mutate(nymClass = factor(nymClass)) %>%
      dplyr::mutate(nymClass = fct_relevel(nymClass, "residual", "co-hyponym", "antonym"))
  }
  
  summaryClasses
  
}
