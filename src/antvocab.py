from transformers import RobertaTokenizer, RobertaModel
from transformers import AutoTokenizer
from transformers import pipeline
import csv
import torch
from antmask import *
from anttoken import *


def charRange(c1, c2):
    """Generates the characters from `c1` to `c2`, inclusive."""
    for c in range(ord(c1), ord(c2)+1):
        yield chr(c)

def getSortedVocab(tokeniser):
    
    vocab_dict = tokeniser.get_vocab()
    sorted_vocab = sorted(vocab_dict.items(), key=lambda item: item[1])
    vocab_list = [token for token, token_id in sorted_vocab]

    return vocab_list


def getVocabToTest(tokeniser, excludeList):

    vocab_list = getSortedVocab(tokeniser)
    
    vocab_to_test = []

    for item in vocab_list:
        # include vocab items > 1 char and with a leading space (so it starts a word)
        if ((len(item) > 2) & (item[0] == 'Ġ')):
            if ((item[1] in charRange('a', 'z')) & (item not in excludeList)):
                vocab_to_test.append(item)

    vocab_to_test = sorted(vocab_to_test, key=lambda item: item)

    print(f"Vocab To Test: {len(vocab_to_test)}")

    return vocab_to_test

def prependCharToListItems(inputList, char):

    outputList = []
    
    for i in range(0,len(inputList)):
        outputList.append(char + inputList[i])

    return outputList
    
def getExcludeList(cxn):        
    # if you want to exclude certain tokens from the vocabulary used to test specific cxns, add them here
    return []
        
def getVocab(tokeniser, cxn):

    # adds leading space to exclude tokens to generate mid-sentence-type tokens
    excludeList = prependCharToListItems(getExcludeList(cxn), "Ġ")

    return getVocabToTest(tokeniser, excludeList)
    

def getTemplate(cxn, word):
    
    match cxn:
        case 'whetherX':
            return f"whether {word} or <mask>"
        case 'whetherY':
            return f"whether <mask> or {word}"
        case 'eitherX':
            return f"either {word} or <mask>"
        case 'eitherY':
            return f"either <mask> or {word}"
        case 'questionX':
            return f", {word} or <mask>?"
        case 'questionY':
            return f", <mask> or {word}?"
        case 'orX':
            return f", {word} or <mask>"
        case 'orY':
            return f", <mask> or {word}"
        case 'alikeX':
            return f", {word} and <mask> alike"
        case 'alikeY':
            return f", <mask> and {word} alike"
        case 'bothX':
            return f"both {word} and <mask>"
        case 'bothY':
            return f"both <mask> and {word}"
        case 'betweenX':
            return f"between {word} and <mask>"
        case 'betweenY':
            return f"between <mask> and {word}"
        case 'fromX':
            return f"from {word} to <mask>"
        case 'fromY':
            return f"from <mask> to {word}"
        case 'versusX':
            return f", {word} versus <mask>"
        case 'versusY':
            return f", <mask> versus {word}"  
        case 'neitherX':
            return f"neither {word} nor <mask>"
        case 'neitherY':
            return f"neither <mask> nor {word}" 
        case 'ratherX':
            return f", {word} rather than <mask>"
        case 'ratherY':
            return f", <mask> rather than {word}"  
        case 'ancillary-good-bad':
            return f", {word} is good, <mask> is bad"
        case 'ancillary-good-but-bad':
            return f", {word} is good, but <mask> is bad"
        case 'long-on-short-on':
            return f"long on {word}, short on <mask>"
        case 'long-on-but-short-on':
            return f"long on {word} but short on <mask>"
        case 'long-X-short-Y':
            return f"take a long {word} off a short <mask>"
        case 'easy-to-X-difficult-to-Y':
            return f"easy to {word}, difficult to <mask>"
        case 'easy-to-X-but-difficult-to-mask':
            return f"easy to {word} but difficult to <mask>"
        case 'easy-to-mask-but-difficult-to-Y':
            return f"easy to <mask> but difficult to {word}"
        case 'quick-to-X-slow-to-mask':
            return f"quick to {word}, slow to <mask>"
        case 'good-for-X-bad-for-mask':
            return f"good for {word}, bad for <mask>"
        case 'good-for-X-but-bad-for-mask':
            return f"good for {word} but bad for <mask>"
        case 'good-X-bad-mask':
            return f"good {word}, bad <mask>"
        case 'good-X-but-bad-mask':
            return f"good {word} but bad <mask>"
        case 'easy-X-hard-mask':
            return f"easy {word}, hard <mask>"
        case 'easy-X-but-hard-mask':
            return f"easy {word} but hard <mask>"
        case 'X-or-mask':
            return f", {word} or <mask>"
        case 'X-yet-mask':
            return f", {word} yet <mask>"
        case 'X-but-mask':
            return f", {word} but <mask>"
        case 'mask-but-X':
            return f", <mask> but {word}"
        case 'andX':
            return f", {word} and <mask>"
        case 'andY':
            return f", <mask> and {word}"
        case 'XnotY-X':
            return f", {word} not <mask> "    
        case 'XnotY-Y':
            return f", <mask> not {word} "   
        case 'alikeXnocomma':
            return f"{word} and <mask> alike"
        case 'alikeYnocomma':
            return f"<mask> and {word} alike"
        case 'aswellasX':
            return f", {word} as well as <mask> "   
        case 'aswellasY':
            return f", <mask> as well as {word} "     
        case _:
            return ""
    
    
def runVocabMaskTests(unmasker, cxn, vocab, path):
            
    resultsExcludeList = prependCharToListItems(getExcludeList(cxn), " ")
    
    idx = 0
    candidateDict = defaultdict(lambda: EMPTY_VALUE)
    candidates = []
    alreadyFound = []
    
    for word in vocab:
        idx = idx + 1
        noSpaceWord = word[1:len(word)]

        currTemplate = getTemplate(cxn, noSpaceWord)
        if currTemplate == "":
            break      
        #print(f"currTemplate is: {currTemplate}")
    
        res = unmasker(currTemplate)
    
        for i, result in enumerate(res):
            if (result['score'] > 0.5) & (result['token_str'] not in resultsExcludeList):
           
                noSpaceResult = result['token_str'][1:]
                alreadyFound.append((noSpaceResult, noSpaceWord))

                identical = ""
                if noSpaceWord == noSpaceResult:
                    identical = "identical"
            
                if ((noSpaceWord, noSpaceResult) in alreadyFound):
                    #candidateDict[noSpaceWord] = [noSpaceWord, result['token_str'], result['score'], "paired", identical]
                    candidateDict[noSpaceWord] = [noSpaceWord, noSpaceResult, result['score'], "paired", identical]
                    candidateDict[noSpaceResult][3] = "paired"
                else:
                    #candidateDict[noSpaceWord] = [noSpaceWord, result['token_str'], result['score'], "", identical]
                    candidateDict[noSpaceWord] = [noSpaceWord, noSpaceResult, result['score'], "", identical]
                    
        if idx % 1000 == 0:
            print(f"{idx} tokens processed")
        
        if idx > 20000:
            break

    for x in candidateDict.values():
        candidates.append(x)

    print(f"Candidates: {len(candidates)}")

    writeAntos(path, candidates)

def createDictEntry(cxn, noSpaceWord, resultToken, resultScore, isPaired):
    return [cxn, noSpaceWord, resultToken, resultScore, isPaired]


def processVocabItemInMask(unmasker, word, cxn, resultsExcludeList, resultDict, alreadyFound, skipCols):

    #alreadyFound = []
    
    noSpaceWord = word[1:len(word)]

    currTemplate = getTemplate(cxn, noSpaceWord)
    if currTemplate == "":
        return   
            
    res = unmasker(currTemplate)

    reversePairIdx = 4
    if skipCols:
        reversePairIdx = reversePairIdx + skipCols             

    for i, result in enumerate(res):
            
        if (result['score'] > 0.5) & (result['token_str'] not in resultsExcludeList):

            #noSpaceResult = result['token_str'][1:]
            noSpaceResult = result['token_str']
            if (result['token_str'][0] == " "):
                noSpaceResult = result['token_str'][1:]
                
            alreadyFound.append((noSpaceResult, noSpaceWord))
            dictKey = f"{noSpaceWord}-{noSpaceResult}"
            existingEntry = resultDict[dictKey]
            newEntry = []
            
            if ((noSpaceWord, noSpaceResult) in alreadyFound):
                reverseDictKey = f"{noSpaceResult}-{noSpaceWord}"
                reverseEntry = resultDict[reverseDictKey]
                #print(f"reverse dict entry: key:{reverseDictKey} {reverseEntry} (cxn: {cxn}; idx: {reversePairIdx})")
                
                # prev entry can be empty if a word is paired with itself, in which case, skip the update
                if reverseEntry != EMPTY_VALUE and len(reverseEntry) > reversePairIdx:  
                    #print(f"updating at index: {reversePairIdx}")
                    resultDict[reverseDictKey][reversePairIdx] = "paired" 
                    
                newEntry = createDictEntry(cxn, noSpaceWord, result['token_str'], result['score'], "paired")
            else:
                newEntry = createDictEntry(cxn, noSpaceWord, result['token_str'], result['score'], "")

            if existingEntry == EMPTY_VALUE:
                if skipCols > 0:
                    newEntry = ["","","","",""] + newEntry
                resultDict[dictKey] = newEntry
                #print(f"adding dict entry: {dictKey} {resultDict[dictKey]}")
            else:
                resultDict[dictKey] = existingEntry + newEntry   
                #print(f"updating dict entry: {dictKey} {resultDict[dictKey]}")
                

    return resultDict, alreadyFound

    
def runPairedVocabTests(unmasker, cxn1, cxn2, vocab, path):
            
    resultsExcludeList1 = prependCharToListItems(getExcludeList(cxn1), " ")
    resultsExcludeList2 = prependCharToListItems(getExcludeList(cxn2), " ")
    alreadyFound1 = []
    alreadyFound2 = []
    
    idx = 0
    candidates = []
    candidateDict = defaultdict(lambda: EMPTY_VALUE)
    
    for word in vocab:
        idx = idx + 1

        #candidateDict, alreadyFound1 = already = processVocabItemInMask(unmasker, word, cxn1, resultsExcludeList1, candidateDict, alreadyFound1, 0)
        candidateDict, alreadyFound1 = processVocabItemInMask(unmasker, word, cxn1, resultsExcludeList1, candidateDict, alreadyFound1, 0)
        candidateDict, alreadyFound2 = processVocabItemInMask(unmasker, word, cxn2, resultsExcludeList2, candidateDict, alreadyFound2, 5)                   

        if idx % 1000 == 0:
            print(f"{idx} tokens processed")
        
        if idx > 20000:
            break

    for x in candidateDict.values():
        candidates.append(x)

    print(f"Candidates: {len(candidates)}")

    writeAntos2Cxns(path, candidates,cxn1, cxn2)    

    
def writeAntos(path, words):
    
    with open(path, mode="w", newline="") as oFile:
        writer = csv.writer(oFile)
    
        headerRow = ["Seed","Mask","Probability","HasPair", "WordsMatch"]
        writer.writerow(headerRow)

        for i in range(0,len(words)):   
        
            newRow = list()
            newRow.append(words[i][0])
            newRow.append(words[i][1])
            newRow.append(f"{words[i][2]:.2f}")
            newRow.append(words[i][3]) 
            newRow.append(words[i][4]) 
            
            writer.writerow(newRow)
    
    print(f"{len(words)} word sets written to: " + path)

def writeAntos2Cxns(path, words, cxn1, cxn2):
    
    with open(path, mode="w", newline="") as oFile:
        writer = csv.writer(oFile)
    
        headerRow = ["Seed","Mask","InWordNet","Cxn",f"Prob-{cxn1}",f"HasPair-{cxn1}",f"Prob-{cxn2}",f"HasPair-{cxn2}","WordsMatch"]
        writer.writerow(headerRow)

        for i in range(0,len(words)):   
        
            newRow = list()

            hasCxn1 = words[i][0] != ""
            hasCxn2 = len(words[i]) > 5 and words[i][5] != ""

            if hasCxn1:
                word1 = words[i][1]
                word2 = words[i][2]
            else:
                word1 = words[i][6]
                word2 = words[i][7]

            if (word2[0] == " "):
                word2 = word2[1:]  # expect the masked token to have a leading space; strip that out here            

            newRow.append(word1)
            newRow.append(word2) 

            if antPairInWordnet(word1,word2):
                newRow.append("y")
            else:
                newRow.append("n")

            cxnStatus = ""
            if hasCxn1 and hasCxn2:
                cxnStatus = "both"
            else:
                if hasCxn1:
                    cxnStatus = words[i][0]
                else:
                    cxnStatus = words[i][5]
            newRow.append(cxnStatus)   

            if words[i][3] == '':
                newRow.append(words[i][3])
            else:
                newRow.append(f"{words[i][3]:.2f}")
            newRow.append(words[i][4])             

            if hasCxn2:
                if words[i][8] == '':
                    newRow.append(words[i][8])
                else:
                    newRow.append(f"{words[i][8]:.2f}")
                newRow.append(words[i][9])   
            else:
                newRow.append("") 
                newRow.append("") 
                
            if word1 == word2:
                newRow.append("y")
            else:
                newRow.append("n")

            writer.writerow(newRow)
    
    print(f"{len(words)} word sets written to: " + path)
