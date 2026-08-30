# Utility functions for comparing various aspects of pair / construction interaction

prepCxnPairs <- function(dfCxns) {
  
  cxnpairs <- dfCxns %>% 
    dplyr::mutate(
      cxn = if_else(cxn == 'more', 'morethan', 
              if_else(cxn == 'rather', 'ratherthan',   
                if_else(cxn == 'from', 'fromto', 
                  if_else(cxn == 'not', 'XnotY', 
                    if_else(cxn == 'notcomma', 'XcommanotY', 
                      if_else(cxn == 'instead', 'insteadof', 
                        if_else(cxn == 'not', 'XnotY', 
                          if_else(cxn == 'opposed', 'opposedto', 
                            if_else(cxn == 'notbut', 'notXbutY', 
                              if_else(cxn == 'notxy', 'notXcommaY', 
                                if_else(cxn == 'andnot', 'XandnotY', 
                                  if_else(cxn == 'butnot', 'XbutnotY', 
                                    if_else(cxn == 'notbutnot', 'notXbutnotY', 
                                      if_else(cxn == 'notonly', 'notonlyXbutY', 
                                        if_else(cxn == 'notjust', 'notXbutjustY', 
                                          if_else(cxn == 'but', 'XbutY', 
                                            if_else(cxn == 'yet', 'XyetY', cxn)))))))))))))))))) %>%
    dplyr::mutate(
      remCxn = (cxn == 'morethan' | cxn == 'aswellas' | cxn == 'and' | cxn == 'or'),
      negCxn = (cxntype == 'j-negated' | cxntype == 'negatedX2' | cxntype == 'restrictive' | cxntype == 'additive'),
      contrastiveCxn = (cxn == 'XbutY' | cxn == 'XyetY'),
      orCxn = (cxn == 'whether' | cxn == 'or' | cxn == 'question' | cxn == 'either'),
      andCxn = (cxn == 'and' | cxn == 'alike' | cxn == 'between' | cxn == 'both')
    ) %>%
    dplyr::mutate(
      isAntCxn = (startsWith(as.character(cxntype), 'j-') & !negCxn & !remCxn)
    ) %>%
    dplyr::mutate(
      isExtendedAntCxn = (isAntCxn | cxn == 'ratherthan' | cxn == 'aswellas' | cxn == 'morethan' | cxn == 'and')
    ) %>%
    dplyr::mutate(
      w1XYexpected = as.integer((word2 == w1XtopY)),
      w1YXexpected = as.integer((word2 == w1YtopX)),
      w2XYexpected = as.integer((word1 == w2XtopY)),
      w2YXexpected = as.integer((word1 == w2YtopX)) ) %>%
    dplyr::mutate(
      numWord1Reciprocals = w1XYexpected + w1YXexpected,
      numWord2Reciprocals = w2XYexpected + w2YXexpected,
      numXReciprocals = w1XYexpected + w2XYexpected,
      numYReciprocals = w1YXexpected + w1YXexpected,
      numReciprocals = numWord1Reciprocals + numWord2Reciprocals) %>%
    # need the check that the match has not already been found because could have matches on tokens that may or may
    # not have had a leading space (and which got stripped out before the results file was written)
    dplyr::mutate(
      w1XYexpected2 = as.integer((word2 == w1X2ndY) & (word2 != w1XtopY)),
      w1YXexpected2 = as.integer((word2 == w1Y2ndX) & (word2 != w1YtopX)),
      w2XYexpected2 = as.integer((word1 == w2X2ndY) & (word1 != w2XtopY)),
      w2YXexpected2 = as.integer((word1 == w2Y2ndX) & (word1 != w2YtopX)) ) %>%
    dplyr::mutate(
      w1XYexpected3 = as.integer((word2 == w1X3rdY) & (word2 != w1X2ndY) & (word2 != w1XtopY)),
      w1YXexpected3 = as.integer((word2 == w1Y3rdX) & (word2 != w1Y2ndX) & (word2 != w1YtopX)),
      w2XYexpected3 = as.integer((word1 == w2X3rdY) & (word1 != w2X2ndY) & (word1 != w2XtopY)),
      w2YXexpected3 = as.integer((word1 == w2Y3rdX) & (word1 != w2Y2ndX) & (word1 != w2YtopX)) ) %>%
    dplyr::mutate(
      w1XYexpected4 = as.integer((word2 == w1X4thY) & (word2 != w1X3rdY) & (word2 != w1X2ndY) & (word2 != w1XtopY)),
      w1YXexpected4 = as.integer((word2 == w1Y4thX) & (word2 != w1Y3rdX) & (word2 != w1Y2ndX) & (word2 != w1YtopX)),
      w2XYexpected4 = as.integer((word1 == w2X4thY) & (word1 != w2X3rdY) & (word1 != w2X2ndY) & (word1 != w2XtopY)),
      w2YXexpected4 = as.integer((word1 == w2Y4thX) & (word1 != w2Y3rdX) & (word1 != w2Y2ndX) & (word1 != w2YtopX)) ) %>%
    dplyr::mutate(
      w1XYexpected5 = as.integer((word2 == w1X5thY) & (word2 != w1X4thY) & (word2 != w1X3rdY) & (word2 != w1X2ndY) & (word2 != w1XtopY)),
      w1YXexpected5 = as.integer((word2 == w1Y5thX) & (word2 != w1Y4thX) & (word2 != w1Y3rdX) & (word2 != w1Y2ndX) & (word2 != w1YtopX)),
      w2XYexpected5 = as.integer((word1 == w2X5thY) & (word1 != w2X4thY) & (word1 != w2X3rdY) & (word1 != w2X2ndY) & (word1 != w2XtopY)),
      w2YXexpected5 = as.integer((word1 == w2Y5thX) & (word1 != w2Y4thX) & (word1 != w2Y3rdX) & (word1 != w2Y2ndX) & (word1 != w2YtopX)) ) %>%
    dplyr::mutate(
      avgProbWord1 = (w2XprobY + w2YprobX) / 2,
      avgProbWord2 = (w1XprobY + w1YprobX) / 2,
      avgProbExpectedWord = (w1XprobY + w1YprobX + w2XprobY + w2YprobX) / 4
      ) %>%
    dplyr::mutate(
      w1Only = (numWord1Reciprocals == 2 & numWord2Reciprocals == 0),
      w2Only = (numWord2Reciprocals == 2 & numWord1Reciprocals == 0)
    )    
}

# word1 matches when word1 = X
matchesForCxnW1X <- function(dfCxns, cxnName, filtNum) {
  cxns <- dfCxns
  
  if (cxnName != "") {
    cxns <- dfCxns %>% dplyr::filter(cxn == cxnName) 
  }
  
  totalRows <- n_distinct(cxns$pairid)
  
  cxns <- cxns %>%
    dplyr::group_by(cxn, w1XtopY) %>% 
    dplyr::summarise(nrows = n(), percent = round((n() * 100 / totalRows),2), avgProb = round(mean(avgProbExpectedWord), 2)) %>%  
    dplyr::filter(nrows > filtNum)
}

# word2 matches when word2 = X
matchesForCxnW2X <- function(dfCxns, cxnName, filtNum) {
  cxns <- dfCxns
  
  if (cxnName != "") {
    cxns <- dfCxns %>% dplyr::filter(cxn == cxnName) 
  }
  
  totalRows <- n_distinct(cxns$pairid)
  
  cxns <- cxns %>%
    dplyr::group_by(cxn, w2XtopY) %>% 
    dplyr::summarise(nrows = n(), percent = round((n() * 100 / totalRows),2), avgProb = round(mean(avgProbExpectedWord), 2)) %>% 
    dplyr::filter(nrows > filtNum)
}

# word1 matches when word1 = Y
matchesForCxnW1Y <- function(dfCxns, cxnName, filtNum) {
  cxns <- dfCxns
  
  if (cxnName != "") {
    cxns <- dfCxns %>% dplyr::filter(cxn == cxnName) 
  }
  
  totalRows <- n_distinct(cxns$pairid)
  
  cxns <- cxns %>%
    dplyr::group_by(cxn, w1YtopX) %>% 
    dplyr::summarise(nrows = n(), percent = round((n() * 100 / totalRows),2), avgProb = round(mean(avgProbExpectedWord), 2)) %>%  
    dplyr::filter(nrows > filtNum)
}

# word2 matches when word2 = Y
matchesForCxnW2Y <- function(dfCxns, cxnName, filtNum) {
  cxns <- dfCxns
  
  if (cxnName != "") {
    cxns <- dfCxns %>% dplyr::filter(cxn == cxnName) 
  }
  
  totalRows <- n_distinct(cxns$pairid)
  
  cxns <- cxns %>%
    dplyr::group_by(cxn, w2YtopX) %>% 
    dplyr::summarise(nrows = n(), percent = round((n() * 100 / totalRows),2), avgProb = round(mean(avgProbExpectedWord), 2)) %>% 
    dplyr::filter(nrows > filtNum)
}



# matches when word = X
matchesForCxnWordInXPos <- function(dfCxns, cxnName, filtNum) {
  matchesW1 <- matchesForCxnW1X(dfCxns, cxnName, filtNum)
  matchesW2 <- matchesForCxnW2X(dfCxns, cxnName, filtNum)
  
  matchesW1 <- matchesW1 %>% dplyr::rename(XtopY = 'w1XtopY')
  matchesW2 <- matchesW2 %>% dplyr::rename(XtopY = 'w2XtopY')
  
  matches <- matchesW1 %>% 
    dplyr::union(matchesW2) %>%
    dplyr::group_by(XtopY) %>%
    dplyr::summarise(first(cxn), nrows = sum(nrows), percent = round(mean(percent),1), avgProb = round(mean(avgProb), 2))
}

# matches when word = Y
matchesForCxnWordInYPos <- function(dfCxns, cxnName, filtNum) {
  matchesW1 <- matchesForCxnW1Y(dfCxns, cxnName, filtNum)
  matchesW2 <- matchesForCxnW2Y(dfCxns, cxnName, filtNum)
  
  matchesW1 <- matchesW1 %>% dplyr::rename(YtopX = 'w1YtopX')
  matchesW2 <- matchesW2 %>% dplyr::rename(YtopX = 'w2YtopX')
  
  matches <- matchesW1 %>% 
    dplyr::union(matchesW2) %>%
    dplyr::group_by(YtopX) %>%
    dplyr::summarise(first(cxn), nrows = sum(nrows), percent = round(mean(percent),1), avgProb = round(mean(avgProb), 2))
}


filterCxns <- function(dfPairsFilt, cxnSet) {
  if (cxnSet == 1) {
    dfPairsFilt <- dfPairsFilt %>% dplyr::filter(isAntCxn == TRUE)
  }
  else if (cxnSet == 2) {
    dfPairsFilt <- dfPairsFilt %>% dplyr::filter(negCxn == TRUE | cxn == 'and')
  }
  else if (cxnSet == 3) {
    dfPairsFilt <- dfPairsFilt %>% dplyr::filter(andCxn == TRUE)
  }
  else if (cxnSet == 4) {
    dfPairsFilt <- dfPairsFilt %>% dplyr::filter(orCxn == TRUE)
  }
  else if (cxnSet == 5) {
    dfPairsFilt <- dfPairsFilt %>% dplyr::filter(isAntCxn == TRUE | cxn == 'ratherthan' | cxn == 'aswellas' | cxn == 'morethan' | cxn == 'and')
  }
  else if (cxnSet == 6) {
    dfPairsFilt <- dfPairsFilt %>% dplyr::filter(contrastiveCxn == TRUE)
  }
  else if (cxnSet == 7) {
    dfPairsFilt <- dfPairsFilt %>% dplyr::filter(negCxn == TRUE & cxn != 'notXbutjustY' & cxn != 'notonlyXbutY' & cxn != 'XcommanotY')
  }
  else if (cxnSet == 8) {
    dfPairsFilt <- dfPairsFilt %>% dplyr::filter(cxn == 'notXbutnotY')
  }
  
  dfPairsFilt
}

showMatchesByCxn <- function(dfPairs, dfCxns, cxnSet, discardUnrelateds) {
  
  dfPairsFilt <- dfPairs
  
  if (discardUnrelateds == TRUE) {
    dfPairsFilt <- dfPairsFilt %>% dplyr::filter(Canonical != "u")
  }
  dfPairsFilt <- filterCxns(dfPairsFilt, cxnSet)
  
  numPairs <- dplyr::n_distinct(dfPairsFilt$pairid)
  
  result <- dfPairsFilt %>%
    dplyr::group_by(cxn) %>%
    dplyr::summarise(percent = round(sum(numReciprocals > 0) * 100/numPairs, 1),
                     has4 = sum(numReciprocals == 4), has3 = sum(numReciprocals == 3),
                     has2 = sum(numReciprocals == 2), has1 = sum(numReciprocals == 1), 
                     has0 = sum(numReciprocals == 0),
                     avgRecip = round(mean(numReciprocals),2),
                     medAvgExpected = round(median(avgProbExpectedWord),4),
                     score = round(avgRecip * medAvgExpected, 4)
    ) %>%
    dplyr::full_join(dfCxns, by = "cxn")
} 

showMatchesByPair <- function(dfPairs, cxnSet, discardUnrelateds) {
  
  dfPairsFilt <- dfPairs
  
  if (discardUnrelateds == TRUE) {
    dfPairsFilt <- dfPairsFilt %>% dplyr::filter(Canonical != "u")
  }
  dfPairsFilt <- filterCxns(dfPairsFilt, cxnSet)
  
  numCxns <- dplyr::n_distinct(dfPairsFilt$cxn)
  
  result <- dfPairsFilt %>%
    dplyr::group_by(pairid) %>%
    dplyr::summarise(word1 = first(word1), word2 = first(word2),
                     matches = sum(numReciprocals > 0),
                     percent = round(sum(numReciprocals > 0) * 100/numCxns, 1),
                     has4 = sum(numReciprocals == 4), has3 = sum(numReciprocals == 3),
                     has2 = sum(numReciprocals == 2), has1 = sum(numReciprocals == 1), 
                     has0 = sum(numReciprocals == 0),
                     fullW1 = sum(numWord1Reciprocals == 2), 
                     fullW2 = sum(numWord2Reciprocals == 2), 
                     cxnMaxAvg = first(cxn[avgProbExpectedWord == max(avgProbExpectedWord)]), 
                     cxnMinAvg = first(cxn[avgProbExpectedWord == min(avgProbExpectedWord)]), 
                     avgRecip = round(mean(numReciprocals),2),
                     avgRecipW1 = round(mean(numWord1Reciprocals),2),
                     avgRecipW2 = avgRecip - avgRecipW1,
                     medAvgExpected = round(median(avgProbExpectedWord),4),
                     score = round(avgRecip * medAvgExpected, 4),
                     POS = first(POS),
                     ) %>%
    dplyr::select(-pairid)
} 

comparePairs <- function(dfPairs, cxn1, cxn2, filtNonRecip) {
  
  cp2Cxns <- dfPairs %>% dplyr::filter(cxn == cxn1 | cxn == cxn2)

  cp <- cp2Cxns %>%
    dplyr::group_by(pairid) %>%
    dplyr::summarise(
      word1 = first(word1), word2 = first(word2),
      cxn1Reciprocals = sum(if_else(cxn == cxn1, numReciprocals, as.integer(0))),
      cxn2Reciprocals = sum(if_else(cxn == cxn2, numReciprocals, as.integer(0))),
      cxn1AvgProb = sum(if_else(cxn == cxn1, avgProbExpectedWord, as.integer(0))),
      cxn2AvgProb = sum(if_else(cxn == cxn2, avgProbExpectedWord, as.integer(0))),
      cxnMaxAvg = first(cxn[avgProbExpectedWord == max(avgProbExpectedWord)]),
  ) %>%
  dplyr::mutate(
    probDiff = cxn2AvgProb - cxn1AvgProb, below0 = cxn2AvgProb - cxn1AvgProb  < 0,
    btwn0and10pc = cxn2AvgProb - cxn1AvgProb  >= 0 & cxn2AvgProb - cxn1AvgProb < 0.1,
    btwn10and100pc = cxn2AvgProb - cxn1AvgProb  >= 0.1 ) %>% 
  dplyr::select(-pairid) 
  
  if (filtNonRecip) {
    cp <- cp %>%
      dplyr::filter(cxn1Reciprocals > 0 | cxn2Reciprocals > 0)
  }
  
  cp
  
}
