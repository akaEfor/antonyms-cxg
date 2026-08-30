source("CxnsVocabContrastTypes.R")
source("CxnsVocabOverlap.R")

# code used for generating various charts included in the dissertation

#########################################################################################################
# charts to show contrast type breakdown in various constructions

classesWhNoInvalids <- orderLevels(classesWhNoInvalids, "both") 
classesWhXNoInvalids <- orderLevels(classesWhXNoInvalids, "X") 
classesWhYNoInvalids <- orderLevels(classesWhYNoInvalids, "Y") 

classesWhPOS <- posClasses(filtProform(pairsWhNoInvalids))
classesWhPOSAnts <- posClasses(dplyr::filter(filtProform(pairsWhNoInvalids), nymClass == "antonym"))

classesWhAdj <- classesWhPOS %>% dplyr::filter(posClass == 'adjective') %>% dplyr::select(-posClass) %>% droplevels()
classesWhAdj <- orderLevels(classesWhAdj, "pos") 

classesWhAdv <- classesWhPOS %>% dplyr::filter(posClass == 'adverb') %>% dplyr::select(-posClass) %>% droplevels()
classesWhAdv <- orderLevels(classesWhAdv, "pos") 

classesWhNoun <- classesWhPOS %>% dplyr::filter(posClass == 'noun') %>% dplyr::select(-posClass) %>% droplevels()
classesWhNoun <- orderLevels(classesWhNoun, "pos") 

classesWhVerb <- classesWhPOS %>% dplyr::filter(posClass == 'verb') %>% dplyr::select(-posClass) %>% droplevels()
classesWhVerb <- orderLevels(classesWhVerb, "pos") 

pairsWhOther <- updatePOS(filtProform(pairsWhNoInvalids)) %>% dplyr::filter(posClass == "other")
classesWhOther <- nymClasses(pairsWhOther, threshold1, threshold2)
classesWhOther <- orderLevels(classesWhOther, "other") 

# set antSet and tableData before running ggplot

# antSet = both is the default for most constructions, used for showing overall breakdown of contrast type;
# for the whether construction, a number of more detailed charts are also generated (see use of other antSet values)

antSet <- "both"
#antSet <- "X"
#antSet <- "Y"
#antSet <- "pos-adj"
#antSet <- "pos-noun"
#antSet <- "pos-verb"
#antSet <- "pos-adv"
#antSet <- "pos-other"


#tableData <- classesWhNoInvalids
#tableData <- classesETNoInvalids
#tableData <- classesQNoInvalids
#tableData <- classesOrNoInvalids
#tableData <- classesAlikeNoInvalids
#tableData <- classesBothNoInvalids
#tableData <- classesNtrNoInvalids
#tableData <- classesRatherNoInvalids
#tableData <- classesAndNoInvalids
#tableData <- classesFromNoInvalids
#tableData <- classesBtwnNoInvalids
#tableData <- classesVsNoInvalids
tableData <- commonToOrCxns # this is defined in the Overlap.R file, to represent shared pairs across OR cxns
#axLimitY <- 2600

axLimitY <- 1600
colours <- c("darksalmon","lightblue", "darkgoldenrod3","darkseagreen") 

if (antSet == "X") {
  tableData <- classesWhXNoInvalids
}
if (antSet == "Y") {
  tableData <- classesWhYNoInvalids
  #colours <- c("lightblue", "darkgoldenrod3","darkseagreen") 
}
if (startsWith(as.character(antSet), "pos")) {
  axLimitY = 800
  colours <- c("lightblue", "darkgoldenrod3","darkseagreen") 
  if (antSet == "pos-adj") { tableData <- classesWhAdj }
  if (antSet == "pos-adv") { tableData <- classesWhAdv }
  if (antSet == "pos-noun") { tableData <- classesWhNoun }
  if (antSet == "pos-verb") { tableData <- classesWhVerb }
  if (antSet == "pos-other") { tableData <- classesWhOther }
}


ggplot(data = tableData, aes(x = nymClass, y = nyms)) + 
#ggplot(data = tableData, aes(x = nymClass, y = nymsT2)) + # use this if showing data from the 0.8 threshold
  geom_col(width=0.6, aes(fill = nymClass)) +
  plotTheme + 
  theme(axis.text.y = element_blank()) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, axLimitY)) +
  scale_fill_manual(values = colours) +
  coord_flip() +
  guides(fill = guide_legend(reverse = TRUE)) +
  theme(legend.position="none") 


#########################################################################################################
# generate plots showing changes in antonym number and percentage at different probability thresholds

threshValNum <- c(1501, 821, 355, 1220, 632, 273, 1070, 544, 226, 651, 362, 171)
threshVal <- c(0.64, 0.702, 0.785,0.507, 0.588, 0.666,0.626, 0.715, 0.779,0.43, 0.532, 0.629)
threshValCommon <- c(0.228, 0.164, 0.150, 0.222, 0.182, 0.167, 0.312, 0.252, 0.234, 0.353, 0.282, 0.25)
threshLab <- c("whether","whether","whether","either","either","either","question","question","question","or","or","or")
thresh <- c("0.5", "0.65", "0.8","0.5", "0.65", "0.8","0.5", "0.65", "0.8","0.5", "0.65", "0.8")
dfThresh <- data.frame(cbind(threshVal, threshLab, thresh)) %>% 
  dplyr::mutate(threshVal = as.numeric(threshVal)) %>% dplyr::mutate(threshVal = threshVal * 100)
dfThreshCommon <- data.frame(cbind(threshValCommon, threshLab, thresh)) %>% 
  dplyr::mutate(threshValCommon = as.numeric(threshValCommon)) %>% dplyr::mutate(threshValCommon = threshValCommon * 100)
dfThreshNum <- data.frame(cbind(threshValNum, threshLab, thresh)) %>% 
  dplyr::mutate(threshValNum = as.numeric(threshValNum))


antPlotTheme <- plotTheme + theme(
  #legend.position="none",
  axis.title.x = element_text(size=14, margin=margin(10, 0, 0, 0)),
  axis.title.y = element_text(size=14, margin=margin(0, 10, 0, 0)),
  axis.text.x=element_text(size=12),
  axis.text.y = element_text(size=12))

ggplot(data = dfThresh, aes(x = thresh, y = threshVal, group = threshLab, colour = threshLab)) + 
  geom_line(linewidth = 0.8) + geom_point(size = 1) +
  labs(title = " ", x = "Probability Threshold", y = "% Antonyms") +
  antPlotTheme + 
  scale_y_continuous(expand=c(0,0), limits = c(40, 80)) +
  guides(colour = guide_legend(reverse = TRUE)) 

ggplot(data = dfThreshCommon, aes(x = thresh, y = threshValCommon, group = threshLab, colour = threshLab)) + 
  geom_line(linewidth = 0.8) + geom_point(size = 1) +
  labs(title = " ", x = "Probability Threshold", y = "% Shared Antonyms") +
  antPlotTheme + 
  scale_y_continuous(expand=c(0,0), limits = c(0, 40)) 

ggplot(data = dfThreshNum, aes(x = thresh, y = threshValNum, group = threshLab, colour = threshLab)) + 
  geom_line(linewidth = 0.8) + geom_point(size = 1) +
  labs(title = " ", x = "Probability Threshold", y = "# Antonyms") +
  antPlotTheme + 
  scale_y_continuous(expand=c(0,0), limits = c(0, 1600)) 


#########################################################################################################
# generate plot for all constructions: #pairs found only from seed position X versus only from seed position Y

posPairs <- c(246, 1287, 367, 1160, 332, 657, 356, 719, 421, 750, 392, 1023,506, 834, 295, 750, 540, 732, 367, 346, 265, 572, 587, 226)
posXY <- c("X","Y","X","Y","X","Y","X","Y","X","Y","X","Y","X","Y","X","Y","X","Y","X","Y","X","Y","X","Y")
posLab <- c("whether","whether","either","either","question","question","or","or","alike","alike","both","both",
            "between","between","and","and","neither","neither","fromto","fromto","versus","versus","ratherthan","ratherthan")

dfPos <- data.frame(cbind(posLab, posXY, posPairs)) %>% 
  dplyr::mutate(posPairs = as.numeric(posPairs))

seedColours <- c("orange3", "skyblue2") 

ggplot(data = dfPos, aes(x = posLab, y = posPairs, fill = posXY)) + 
  geom_bar(stat = "identity", position = position_dodge2(reverse = TRUE, padding = 0.1), alpha = 0.65, color = "gray72")  +
  labs(title = " ", x = "", y = "# pairs") +
  antPlotTheme + theme(axis.title.y = element_text(size=8)) +
  scale_y_continuous(expand=c(0,0), limits = c(0, 1300)) +
  scale_fill_manual(values = seedColours) + 
  coord_flip()

