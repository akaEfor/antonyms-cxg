import csv
import torch

from antmask import *

def stripLastSpace(text):
    if (text[len(text)-1] == " "):
        text = text[0:len(text)-1]
    return text
    
def getTemplates(cxn, word, stripTrailingSpace):

    #print(f"getting templates for {word}")
    
    textX = ""
    testY = ""

    match cxn:
        case 'alike':
            textX = f", {word} and <mask> alike"
            #textX = f" {word} and <mask> alike"
            testY = f", <mask> and {word} alike"
        case 'whether':
            textX = f"whether {word} or <mask> "
            testY = f"whether <mask> or {word} "
        case 'either':
            textX = f"either {word} or <mask> "
            testY = f"either <mask> or {word} "
        case 'both':
            textX = f"both {word} and <mask> "
            testY = f"both <mask> and {word} "
        case 'between':
            textX = f"between {word} and <mask> "
            testY = f"between <mask> and {word} "
        case 'fromto':
            textX = f"from {word} to <mask> "
            testY = f"from <mask> to {word} "
        case 'versus':
            textX = f", {word} versus <mask> "
            testY = f", <mask> versus {word} "       
        case 'neither':
            textX = f"neither {word} nor <mask> "
            testY = f"neither <mask> nor {word} "
        case 'aswellas':
            textX = f", {word} as well as <mask> "
            testY = f", <mask> as well as {word} "                 
        case 'morethan':
            textX = f"more {word} than <mask> "
            testY = f"more <mask> than {word} "
        case 'ratherthan':
            textX = f", {word} rather than <mask> "
            testY = f", <mask> rather than {word} "     
        case 'XnotY':
            textX = f", {word} not <mask> "
            testY = f", <mask> not {word} "       
        case 'XcommanotY':
            textX = f", {word}, not <mask> "
            testY = f", <mask>, not {word} "       
        case 'insteadof':
            textX = f", {word} instead of <mask> "
            testY = f", <mask> instead of {word} "       
        case 'opposedto':
            textX = f", {word} as opposed to <mask> "
            testY = f", <mask> as opposed to {word} "    
        case 'question':
            textX = f", {word} or <mask>?"
            testY = f", <mask> or {word}?"       
        case 'and':
            textX = f", {word} and <mask> "
            testY = f", <mask> and {word} "       
        case 'or':
            textX = f", {word} or <mask> "
            testY = f", <mask> or {word} "  
        case 'notXbutY':
            textX = f"not {word} but <mask> "
            testY = f"not <mask> but {word} "
        case 'notXcommaY':
            textX = f"not {word}, <mask> "
            testY = f"not <mask>, {word} "
        case 'XandnotY':
            textX = f", {word} and not <mask> "
            testY = f", <mask> and not {word} "  
        case 'XbutnotY':
            textX = f", {word} but not <mask> "
            testY = f", <mask> but not {word} "  
        case 'notXbutnotY':
            textX = f"not {word} but not <mask> "
            testY = f"not <mask> but not {word} "
        case 'notonlyXbutY':
            textX = f"not only {word} but <mask> "
            testY = f"not only <mask> but {word} "
        case 'notXbutjustY':
            textX = f"not {word} but just <mask> "
            testY = f"not <mask> but just {word} "
        case 'XbutY':
            textX = f", {word} but <mask> "
            testY = f", <mask> but {word} "  
        case 'XyetY':
            textX = f", {word} yet <mask> "
            testY = f", <mask> yet {word} "          
            
    #print(textX)
    #print(testY)
    if stripTrailingSpace:
        textX = stripLastSpace(textX)
        testY = stripLastSpace(testY)
    
    templates = [textX, testY]

    return templates

                 
def readPairs(path):
    pairs = list()

    with open(path, mode="r") as iFile:
        reader = csv.reader(iFile)
        idx = 0
        for row in reader:
            if idx != 0:
                pairs.append((row[0],row[1],row[2]))
            idx = idx + 1
            
    return pairs

def writePairs(path, cxnResults):
    
    with open(path, mode="w", newline="") as oFile:
        writer = csv.writer(oFile)
    
        headerRow = ["Seed","Mask","Probability","HasPair"]
        writer.writerow(headerRow)

        for i in range(0,len(words)):   
        
            newRow = list()
            newRow.append(words[i][0])
            newRow.append(words[i][1])
            newRow.append(f"{words[i][2]:.2f}")
            newRow.append(words[i][3]) 
            
            writer.writerow(newRow)
    
    print(f"{len(words)} word sets written to: " + path)

def getToken(word):
    return "Ġ" + word

def unmaskWords(model, tokeniser, unmasker, template, targetToken):
    
    targetTokenProb = probForSpecificToken(unmasker, template, targetToken)
    
    res = unmasker(template)
    topToken = res[0]['token_str']
    topProb = res[0]['score']

    if topToken[0] == ' ':
        if len(topToken) == 1:
            print(f"found a space when testing {template} and target {targetToken}")
        topToken = topToken[1:len(topToken)]


    token2 = res[1]['token_str']
    if token2[0] == ' ':
        token2 = token2[1:len(token2)]
    token3 = res[2]['token_str']
    if token3[0] == ' ':
        token3 = token3[1:len(token3)]
    token4 = res[3]['token_str']
    if token4[0] == ' ':
        token4 = token4[1:len(token4)]
    token5 = res[4]['token_str']
    if token5[0] == ' ':
        token5 = token5[1:len(token5)]
        
    prob2 = res[1]['score']
    prob3 = res[2]['score']
    prob4 = res[3]['score']
    prob5 = res[4]['score']

    prob1to3 = topProb + prob2 + prob3
    prob1to5 = prob1to3 + prob4 + prob5
    
    logits = getMaskedLogits(model, tokeniser, template, -1)
    
    return (targetTokenProb, topToken, topProb, logits[0], prob1to3, prob1to5, token2, token3, token4, token5)

     
def runTemplatesForPair(model, tokeniser, unmasker, cxns, pair, stripTrailingSpace):
    results = []
    
    pairId = pair[0]
    word1 = pair[1]
    word2 = pair[2]
    
    #force search for tokens with an initial space
    token1 = getToken(word1)
    token2 = getToken(word2)

    for cxn in cxns:

        w1templates = getTemplates(cxn[0], word1, stripTrailingSpace)
        XYword1 = unmaskWords(model, tokeniser, unmasker, w1templates[0], token2)
        YXword1 = unmaskWords(model, tokeniser, unmasker, w1templates[1], token2)        
        #jsdW1 = jensen_shannon_divergence(XYword1[3], YXword1[3], False)

        w2templates = getTemplates(cxn[0], word2, stripTrailingSpace)
        XYword2 = unmaskWords(model, tokeniser, unmasker, w2templates[0], token1)
        YXword2 = unmaskWords(model, tokeniser, unmasker, w2templates[1], token1)
        #jsdW2 = jensen_shannon_divergence(XYword2[3], YXword2[3], False)

        
        data = {
            "cxn": cxn[0],
            "cxntype": cxn[1],
            "pairid": pairId,
            "word1": word1,
            "word2": word2,
            
            #"jsdW1": float(f"{jsdW1:.4f}"),
            #"jsdW2": float(f"{jsdW2:.4f}"),
            
            "w1XprobY": float(f"{XYword1[0]:.4f}"),
            "w1XtopY": f"{XYword1[1]}",
            "w1XtopYprob": float(f"{XYword1[2]:.4f}"), 
            #"w1Xtop3Yprob": float(f"{XYword1[4]:.4f}"), 
            #"w1Xtop5Yprob": float(f"{XYword1[5]:.4f}"), 
            "w1X2ndY": f"{XYword1[6]}",
            "w1X3rdY": f"{XYword1[7]}",
            "w1X4thY": f"{XYword1[8]}",
            "w1X5thY": f"{XYword1[9]}",
            
            "w1YprobX": float(f"{YXword1[0]:.4f}"),
            "w1YtopX": f"{YXword1[1]}",
            "w1YtopXprob": float(f"{YXword1[2]:.4f}"), 
            #"w1Ytop3Xprob": float(f"{YXword1[4]:.4f}"), 
            #"w1Ytop5Xprob": float(f"{YXword1[5]:.4f}"), 
            "w1Y2ndX": f"{XYword1[6]}",
            "w1Y3rdX": f"{XYword1[7]}",
            "w1Y4thX": f"{XYword1[8]}",
            "w1Y5thX": f"{XYword1[9]}",
            
            "w2XprobY": float(f"{XYword2[0]:.4f}"),
            "w2XtopY": f"{XYword2[1]}",
            "w2XtopYprob": float(f"{XYword2[2]:.4f}"),    
            #"w2Xtop3Yprob": float(f"{XYword2[4]:.4f}"),    
            #"w2Xtop5Yprob": float(f"{XYword2[5]:.4f}"),    
            "w2X2ndY": f"{XYword1[6]}",
            "w2X3rdY": f"{XYword1[7]}",
            "w2X4thY": f"{XYword1[8]}",
            "w2X5thY": f"{XYword1[9]}",
            
            "w2YprobX": float(f"{YXword2[0]:.4f}"),          
            "w2YtopX": f"{YXword2[1]}",
            "w2YtopXprob": float(f"{YXword2[2]:.4f}"),
            #"w2Ytop3Xprob": float(f"{YXword2[4]:.4f}"),
            #"w2Ytop5Xprob": float(f"{YXword2[5]:.4f}"),
            "w2Y2ndX": f"{XYword1[6]}",
            "w2Y3rdX": f"{XYword1[7]}",
            "w2Y4thX": f"{XYword1[8]}",
            "w2Y5thX": f"{XYword1[9]}"
        }

        results.append(data)

    return results
        
def runTemplatesForAll(model, tokeniser, unmasker, cxns, pairs, stripTrailingSpace):
    results = []
    
    for pair in pairs:
        print(f"running mask tests for: {pair}")
        results.extend(runTemplatesForPair(model, tokeniser, unmasker, cxns, pair, stripTrailingSpace))

    print(f"results list len: {len(results)}")

    return results
