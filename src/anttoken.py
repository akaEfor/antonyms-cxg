from transformers import RobertaTokenizer, RobertaModel
from transformers import AutoTokenizer
from transformers import pipeline
import csv
import torch
from antwordnet import *
from collections import defaultdict

HEADER_KEY = 'HEADER'
EMPTY_VALUE = 'NONE'


def runTokeniser(tokeniser, text):
    encoded = tokeniser(text)
    return encoded.tokens()
    
def readWords(path):
    words = list()

    with open(path, mode="r") as iFile:
        reader = csv.reader(iFile)
        for row in reader:
            words.append(row[0])
            
    return words

def writeTokens(path, words):
    
    with open(path, mode="w", newline="") as oFile:
        writer = csv.writer(oFile)

        for i in range(1,len(words)):   # skip header row

            textToTokenise = words[i] + " " + words[i]  # tokenisation may be different at start of a sentence vs. mid-sentence
            tokens = runTokeniser(tokeniser, textToTokenise)
        
            #print(textToTokenise)
            #print(tokens)
        
            newRow = list()
            newRow.append(textToTokenise)
        
            # don't include separator tokens at the start and end
            for j in range(1,len(tokens) - 1):
                newRow.append(tokens[j])
            
            writer.writerow(newRow)
     
    print("tokens written to: " + path)

def readNyms(path):
    nyms = list()

    with open(path, mode="r", encoding="ISO-8859-1") as iFile:
    #with open(path, mode="r") as iFile:
        reader = csv.reader(iFile)
        for row in reader:
            antsyn = row
            nyms.append(antsyn)
            
    return nyms

def getDictKey(entry, hasLeadingSpace):
    if hasLeadingSpace:
        return f"{entry[0]}-{entry[1][1:]}"   # word 2 in reference (master) file has a leading space, so trim that for the dict key
    else:
        return f"{entry[0]}-{entry[1]}"  
        
    
def readIntoDict(path, hasLeadingSpace):
    
    nymDict = defaultdict(lambda: EMPTY_VALUE)

    with open(path, mode="r", encoding="ISO-8859-1") as iFile:
            
        reader = csv.reader(iFile)
        rowNum = 0
        
        for row in reader:

            if rowNum == 0:
                nymDict[HEADER_KEY] = row
                
            rowNum = rowNum + 1
            nymDict[getDictKey(row, hasLeadingSpace)] = row
    
    return nymDict


def checkOOVWord(tokeniser, word):
        
    textToTokenise = " " + word  # just checking tokenisation mid-sentence 
        
    tokens = runTokeniser(tokeniser, textToTokenise)

    if len(tokens) > 3:
        print("words split: " + textToTokenise)
        print(tokens)

    return len(tokens) <= 3

def checkOOVAndWordnet(tokeniser, word1, word2):

    if checkOOVWord(tokeniser, word1) & checkOOVWord(tokeniser, word2):
        if antPairInWordnet(word1,word2):
            return True
        
    return False

def checkOOVPair(tokeniser, nym):

    return checkOOVWord(tokeniser, nym[1]) & checkOOVWord(tokeniser, nym[2]) 

def checkOOVList(tokeniser, nymList, path):
    
    print(f"number of pairs: {len(nymList) - 1}")  # allow for header row

    numInVocab = 0

    with open(path, mode="w", newline="", encoding="ISO-8859-1") as oFile:
        writer = csv.writer(oFile)

        for i in range(0,len(nymList)): 
            if i == 0:   # header row
                nymList[0].append('WordNet-Has-Antonyms')
                nymList[0].append('A-WordNet-Antonym')
                nymList[0].append('B-WordNet-Antonym')
                nymList[0].append('A-WordNet-Synsets')
                nymList[0].append('B-WordNet-Synsets')
                writer.writerow(nymList[0])   
            else:
                if checkOOVPair(tokeniser, nymList[i]):
                    numInVocab = numInVocab + 1

                    wordA = nymList[i][1]
                    wordB = nymList[i][2]

                    antsA = antInWordnet(wordA)
                    antsB = antInWordnet(wordB)

                    wnStatus = 'neither'
                    if wordA in antsB:
                        if wordB in antsA:
                            wnStatus = 'both'
                        else:
                            wnStatus = 'one'

                    
                    nymList[i].append(wnStatus)
                    
                    nymList[i].append(antsA if antsA != '' else 'none')
                    nymList[i].append(antsB if antsB != '' else 'none')
                    
                    nymList[i].append(getNumSynsets(wordA))
                    nymList[i].append(getNumSynsets(wordB))
                    
                    writer.writerow(nymList[i])

        print(f"pairs in vocab: {numInVocab}")
    
    return numInVocab

def checkOOVNymList(tokeniser, nymList, path, pos):
    print(f"number of pairs: {len(nymList) - 1}")  # allow for header row

    numInVocab = 0

    with open(path, mode="w", newline="") as oFile:
        writer = csv.writer(oFile)

        for i in range(0,len(nymList)): 
            if i == 0:   # header row
                row = ['word1','word2','POS']
                writer.writerow(row)   
            else:
                row = nymList[i]
                if row[2] == '1':  # only consider antonyms
                    word1 = row[0]
                    word2 = row[1]
                    
                    if checkOOVAndWordnet(tokeniser, word1, word2):
                    
                        numInVocab = numInVocab + 1
                        newRow = [word1, word2, pos]
                        writer.writerow(newRow)

        print(f"pairs in vocab: {numInVocab}")
    
    return numInVocab

def updateAntos(fileToUpdate, updateFrom, resultPath, fileHasWord2LeadingSpaces):

    inputNyms = readNyms(fileToUpdate)
    referenceNyms = readIntoDict(updateFrom, True)

    with open(resultPath, mode="w", newline="") as oFile:
        writer = csv.writer(oFile)

        for i in range(0,len(inputNyms)): 
            
            inputRow = inputNyms[i]
            
            if i == 0:    # copy header row from update file
                inputRow = inputRow + referenceNyms[HEADER_KEY][4:]
            else:
                refRow = referenceNyms[getDictKey(inputRow, fileHasWord2LeadingSpaces)]
                if refRow != EMPTY_VALUE:
                    inputRow = inputRow + refRow[4:]  # don't repeat the seed/mask/prob/haspair from the reference file
                
            writer.writerow(inputRow)     
                
    print(f"{fileToUpdate} updated from {updateFrom}")

def updateAntosCxnPairs(fileToUpdate, updateFrom, resultPath):

    inputNyms = readNyms(fileToUpdate)
    referenceNyms = readIntoDict(updateFrom, False)

    with open(resultPath, mode="w", newline="") as oFile:
        writer = csv.writer(oFile)

        for i in range(0,len(inputNyms)): 
            
            inputRow = inputNyms[i]
            
            if i == 0:    # copy header row from update file
                inputRow = inputRow + referenceNyms[HEADER_KEY][3:]
            else:
                refRow = referenceNyms[getDictKey(inputRow, False)]
                if refRow != EMPTY_VALUE:
                    inputRow = inputRow + refRow[3:]  # don't repeat the seed/mask/inwordnet from the reference file
                
            writer.writerow(inputRow)     
                
    print(f"{fileToUpdate} updated from {updateFrom}")

def dedupPairs(inputFile, resultPath):

    referenceNyms = readIntoDict(inputFile, False)

    with open(resultPath, mode="w", newline="") as oFile:
        writer = csv.writer(oFile)
        writer.writerow(referenceNyms[HEADER_KEY])  

        for key in referenceNyms.keys():  

            inputRow = referenceNyms[key]

            if inputRow != EMPTY_VALUE and inputRow[0] != 'Seed':
                writer.writerow(inputRow)     
                
    print(f"{inputFile} updated")    