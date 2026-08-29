#import nltk
#nltk.download('wordnet')
from nltk.corpus import wordnet as wn

def getNumSynsets(word):
    return len(wn.synsets(word))

def getDirectAntonyms(word):
    antonyms = set()

    for syn in wn.synsets(word):
        for lemma in syn.lemmas():
            if (len(lemma.antonyms()) > 0) & (lemma.name() == word):
                antonyms.add(lemma.antonyms()[0].name())

    return antonyms


def getRelated(word):
    indirects = set()

    for syn in wn.synsets(word):        
        if syn.pos() == 'a':
            for lemma in syn.lemmas():           
                if lemma.antonyms():
                    if lemma.name() == word:                     
                        for sim in syn.similar_tos():
                            indirects.add(sim.lemmas()[0].name())

    return indirects

def getSatelliteRelated(word):
    indirects = set()

    for syn in wn.synsets(word):        
        if syn.pos() == 's':
            for lemma in syn.lemmas():           
                if lemma.name() == word:                     
                    for sim in syn.similar_tos():
                        indirects.add(sim.lemmas()[0].name())
    return indirects

def getIndirectAntonymsPrimary(word):
    antonyms = set()

    for syn in wn.synsets(word):       
        if syn.pos() == 'a':
            for lemma in syn.lemmas():            
                if lemma.antonyms():
                    if lemma.name() == word:
                        ant = lemma.antonyms()[0].name();
                        
                        #antonyms.add(ant) #don't add the direct antonym here
                        antonyms.update(getRelated(ant))

    return antonyms

def getIndirectAntonymsSecondary(word):
    antonyms = set()
    
    for relWord in getSatelliteRelated(word):     
        antonyms.update(getDirectAntonyms(relWord))

    return antonyms

def getIndirectAntonyms(word):
    
    antonyms = getDirectAntonyms(word)
    indirects = set()
    
    if len(antonyms) > 0:
        indirects.update(getIndirectAntonymsPrimary(word))
    else:
        indirects.update(getIndirectAntonymsSecondary(word))

    return indirects

def antInWordnet(word):
    ants = getDirectAntonyms(word)
    antStr = ""
    
    if (len(ants) == 0):
        return ""
    else:
        if len(ants) == 1:
            return ants.pop()
        else:
            for ant in ants:
                antStr = ant + ';' + antStr

    return antStr

def antPairInWordnet(word1,word2):
    ants1 = getDirectAntonyms(word1)
    ants2 = getDirectAntonyms(word2)
    word1Match = False
    word2Match = False
    
    if (len(ants1) == 0 or len(ants2) == 0):
        return False
    else:
        for ant1 in ants1:
            if ant1 == word2:  
                word1Match = True
                
        for ant2 in ants2:
            if ant2 == word1:
                word2Match = True
               
    # using 'or' here will return some additional pairs - seems like some WordNet direct antonyms are returned in one direction only
    # return word1Match or word2Match 
    
    return word1Match and word2Match
  