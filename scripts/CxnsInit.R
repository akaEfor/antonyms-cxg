library('dplyr')
library('magrittr')
library('ggplot2')
library('stringi')
library('forcats')

# **** update scriptsDir to the location of the scripts dir in the local antonyms-cxg folder ****
scriptsDir <- '~/Lingo/Dissertation/Data/antonyms-cxg/scripts'

setwd(scriptsDir)

masterFilesLoc <- '../data/master-cxn-pair-files/'

plotTheme <- 
  theme(  
    panel.background = element_rect(fill = "white", colour="white"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    plot.background = element_rect(fill = "white", colour="black"),
    text = element_text(colour = "black"),
    plot.title = element_text(size=10, face="bold", margin=margin(0, 0, 10, 25)),
    axis.text.x=element_text(angle=-25, hjust= .1, size=10),
    axis.text.y = element_text(size=10),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.line.x = element_line(color = "grey80", linewidth = .4),
    axis.line.y = element_line(color = "grey80", linewidth = .4),
    axis.ticks.x = element_line(color = "grey80", linewidth = .4),
    axis.ticks.y = element_line(color = "grey80", linewidth = .4),
    plot.margin = margin(10, 25, 10, 15), 
    legend.title=element_blank()
  )

