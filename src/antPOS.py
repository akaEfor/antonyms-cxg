from anttoken import *

def writePosRows(writer, pairSet, pos):
        
    for i in range(0,len(pairSet)): 
        newRow = []
            
        for j in pairSet[i]:
            newRow.append(j)
                
        newRow.append(pos)           
        writer.writerow(newRow)

    return len(pairSet)

def dedupLists(adjList, nounList, verbList, selectedPairs, path):

    print(f"Before dedup - adj: {len(adjList) - 1}; noun: {len(nounList) - 1}; verb: {len(verbList) - 1};")
    
    num = 0

    adjPairs = []
    nounPairs = []
    verbPairs = []
    selPairs = []

    for i in range(1,len(selectedPairs)):   # skip header row
        selEntry = sorted((selectedPairs[i][1], selectedPairs[i][2]))        
        selPairs.append(selEntry)

    for i in range(1,len(adjList)):   # skip header row
        adjEntry = sorted((adjList[i][0], adjList[i][1]))        
        if adjEntry not in selPairs and adjEntry not in adjPairs:
            adjPairs.append(adjEntry)
        else:
            print(f"adj dup {adjEntry}")

    for i in range(1,len(nounList)):   # skip header row
        nounEntry = sorted((nounList[i][0], nounList[i][1]))        
        if nounEntry not in selPairs and nounEntry not in adjPairs and nounEntry not in nounPairs:
            nounPairs.append(nounEntry)
        else:
            print(f"noun dup {nounEntry}")

    for i in range(1,len(verbList)):   # skip header row
        verbEntry = sorted((verbList[i][0], verbList[i][1]))        
        if verbEntry not in selPairs and verbEntry not in adjPairs and verbEntry not in nounPairs and verbEntry not in verbPairs:
            verbPairs.append(verbEntry)
        else:
            print(f"verb dup {verbEntry}")
    
    print(f"After dedup - adj: {len(adjPairs)}; noun: {len(nounPairs)}; verb: {len(verbPairs)};")
        

    with open(path, mode="w", newline="") as oFile:
        writer = csv.writer(oFile)

        row = ['word1','word2','POS']
        writer.writerow(row)   

        num = writePosRows(writer, adjPairs, 'adj')
        num = num + writePosRows(writer, nounPairs, 'noun')
        num = num + writePosRows(writer, verbPairs, 'verb')
        
        print(f"total pairs: {num}")
    
    return num


# check tokenisation of a set of antonym/synonym pairs
def processNyms(tokeniser, inputFile, outputFile, pos):

    nyms = readNyms(inputFile)
    checkOOVNymList(tokeniser, nyms, outputFile, pos)
