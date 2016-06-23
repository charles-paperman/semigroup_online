        
def detectAlphabet(tree):
    print tree
    if "value" not in tree:
        print tree
    if (tree["value"] == 'Letters'):
        return set(tree["word"])
    if ("subFormulas" in tree):
        Alphabet = set()
        for F in tree["subFormulas"]:
            Alphabet = Alphabet.union(detectAlphabet(F))
        return Alphabet
    return set()
                                
def evaluate_MSO_tree(tree,Alphabet):
    print tree
    if (tree["value"] == "Forall"):
        return Forall(tree["variables"],evaluate_MSO_tree(tree["subFormulas"][0],Alphabet))
    if (tree["value"] == "Exists"):
        return Exists(tree["variables"],evaluate_MSO_tree(tree["subFormulas"][0],Alphabet))
    if (tree["value"] == "ForallSets"):
        return MSOForall(tree["variables"],evaluate_MSO_tree(tree["subFormulas"][0],Alphabet))
    if (tree["value"] == "ExistsSet"):
        return MSOExists(tree["variables"],evaluate_MSO_tree(tree["subFormulas"][0],Alphabet))
    if (tree["value"] == "And"):
        L = [evaluate_MSO_tree(F,Alphabet) for F in tree["subFormulas"]] 
        return And(L)
    if (tree["value"] == "Or"):
        L = [evaluate_MSO_tree(F,Alphabet) for F in tree["subFormulas"]] 
        return Or(L)
    if (tree["value"] == "Not"):
        return Not(evaluate_MSO_tree(tree["subFormulas"][0]),Alphabet)
    if (tree["value"] == 'orderPredicates'):
        print tree
        if tree["type"] == '<':
            return OrderPredicate(tree["variables"]["variable1"],tree["variables"]["variable2"],Alphabet)
        if tree["type"] == '>':
            return OrderPredicate(tree["variables"]["variable2"],tree["variables"]["variable1"],Alphabet)
        if tree["type"] == '=':
            return equalPredicate(tree["variables"]["variable1"],tree["variables"]["variable2"],Alphabet)

    if (tree["value"] == 'Letters'):
        return Letter(tree["word"],tree["variables"]["variable"],Alphabet)
    if (tree["value"] == 'InPredicate'):
        return In(tree["variable1"][0],tree["MSOvariable2"][0],Alphabet)
                        
def In(x,X,Alphabet):
    t = {}
    for a in Alphabet:
        t[(0,(a,frozenset((x,)),frozenset((X,))))]= [1]
        t[(0,(a,frozenset(),frozenset((X,))))]= [0]
        t[(0,(a,frozenset(),frozenset()))]= [0]
        t[(1,(a,frozenset(),frozenset()))]= [1]
        t[(1,(a,frozenset(),frozenset()))]= [1]
    A = Automaton(t,[0],[1])
    A.free_variables = set((x,))
    A.MSOfree_variables = set((X,))
    A.underlying_alphabet = Alphabet
    return A
                    
def variablesLanguage(FV,Alphabet):
    d = {}
    States = [frozenset(L) for L in list(powerset(FV))]
    
    for s in States:
        for a in Alphabet:
            for x in States:
                if s.isdisjoint(x):
                    d[(frozenset(s),(a,x,frozenset()))] = [frozenset(set(s).union(x))]   
    A = Automaton(d,[frozenset()],[frozenset(FV)])
    A.underlying_alphabet = Alphabet
    A.free_variables = FV
    A.MSOfree_variables = set()
    return A                    
def Letter(word,x,Alphabet):
    t = {}
    for b in Alphabet:
        t[(0,(b,frozenset(),frozenset()))] = [0]
        t[(len(word),(b,frozenset(),frozenset()))] = [len(word)]
    t[(0,(word[0],frozenset((x,)),frozenset()))] = [1] 
    for i in range(1,len(word)):
        t[(i,(word[i],frozenset(),frozenset()))] = [i+1] 
    A = Automaton(t,[0],[len(word)])
    A.free_variables = set((x,))
    A.MSOfree_variables = set()
    A.underlying_alphabet = Alphabet
    return A
        
def StrictelyLess(x,y,Alphabet):
    t = {}
    for a in Alphabet:
        for u in range(3):
            t[(u,(a,frozenset(),frozenset()))] = [u]
        t[(0,(a,frozenset((x,)),frozenset()))] = [1]
        t[(1,(a,frozenset((y,)),frozenset()))] = [2]
    A = Automaton(t,[0],[2])
    A.free_variables = set([(x,),(y,)])
    A.MSOfree_variables = set()
    A.underlying_alphabet = Alphabet
    return A    

def Order(x,y,Alphabet):
    t = {}
    for a in Alphabet:
        for u in range(3):
            t[(u,(a,frozenset(),frozenset()))] = [u]
        t[(0,(a,frozenset((x,)),frozenset()))] = [1]
        t[(1,(a,frozenset((y,)),frozenset()))] = [2]
    A = Automaton(t,[0],[2])
    A.free_variables = set([(x,),(y,)])
    A.MSOfree_variables = set()
    A.underlying_alphabet = Alphabet
    return A    


def NumericPredicate(tree,ALphabet):
    print tree  
    t = {}
    for a in Alphabet:
        for u in range(3):
            t[(u,(a,frozenset(),frozenset()))] = [u]
        t[(0,(a,frozenset((x,)),frozenset()))] = [1]
        t[(1,(a,frozenset((y,)),frozenset()))] = [2]
    A = Automaton(t,[0],[2])
    A.free_variables = set([(x,),(y,)])
    A.MSOfree_variables = set()
    A.underlying_alphabet = Alphabet
    return A    


def Addvariables(A,lx=[],lX=[]):
    FV = set(A.free_variables)
    FV.union(lx)
    MFV = set(A.MSOfree_variables)
    MFV.union(lX)
    lx = set(lx).difference(FV)
    lX = set(lX).difference(MFV)
    d = A._transitions
    for x in lx:
        newd = {}        
        for t in d:
            S = set(t[1][1])
            S.add((x,))
            newd[t] = d[t]
            newd[(t[0],(t[1][0],frozenset(S),t[1][2]))] = d[t]
        d = dict(newd)

    for X in lX:
        newd = {}        
        for t in d:
            S = set(t[1][2])
            S.add((X,))
            newd[t] = d[t]
            newd[(t[0],(t[1][0],t[1,1],frozenset(S)))] = d[t]
        d = dict(newd)

    B = Automaton(d,A._initial_states,A._final_states)
    B.free_variables = FV
    B.MSOfree_variables = MFV 
    B.underlying_alphabet = Alphabet

    return B
def Or(MSOFormulaList):
    FV = set()
    MFV = set()
    Alphabet = set()
    for A in MSOFormulaList:
        FV = FV.union(A.free_variables)
        MFV = MFV.union(A.MSOfree_variables)
        Alphabet = Alphabet.union(A.underlying_alphabet)
    UpdateList = []
    for A in MSOFormulaList:
        UpdateList.append(Addvariables(A,FV,MFV))     
    B = UpdateList[0]
    UpdateList.remove(B)
    for A in UpdateList:
        B += A
    B.free_variables = FV
    B.MSOfree_variables = MFV     
    B.underlying_alphabet = Alphabet        
    return B    

def And(MSOFormulaList):
    return Not(Or([Not(F) for F in MSOFormulaList]))

def Implies(F1,F2):
    return Or([Not(F1),F2])


def Not(F):
    A = variablesLanguage(F.free_variables,F.underlying_alphabet)
    Addvariables(A,[],F.MSOfree_variables)
    B = (-F).intersection(A)
    B.free_variables = F.free_variables
    B.MSOfree_variables = F.MSOfree_variables 
    B.underlying_alphabet = F.underlying_alphabet        
    return B    
    
def Exists(ListVariables,F):
    d = F._transitions
    newd = {}
    for t in d:
        for x in ListVariables:
            s = t[1][1].difference(set((x,)))
            tp = (t[0],(t[1][0],s,t[1][2]))
            l = d[tp]   
            l.extend(d[t])                      
            newd[tp] = l
            
    A = Automaton(newd,F._initial_states,F._final_states)
    A.free_variables = F.free_variables.difference(set((x,)))
    A.MSOfree_variables = F.MSOfree_variables
    A.underlying_alphabet = F.underlying_alphabet
    return A    
def Forall(ListVariables,F):
    return Not(Exists(ListVariables,Not(F)))    

def MSOExists(ListVariables,F):     
    d = F._transitions
    newd = {}
    for t in d:
        if (not t[1][2].isdisjoint(ListVariables)):
            s = t[1][2].difference(ListVariables)
            tp = (t[0],(t[1][0],t[1][1],s))
            l = d[tp]   
            l.extend(d[t])                      
            newd[tp] = l
    A = Automaton(newd,F._initial_states,F._final_states)
    A.free_variables = F.free_variables
    A.MSOfree_variables = F.MSOfree_variables.difference(ListVariables)
    A.underlying_alphabet = F.underlying_alphabet
    return A    

def MSOForall(ListVariables,F):
    return Not(MSOExists(ListVariables,Not(F)))    

def Closure(F):
    if (len(F.free_variables) == 0) and (len(F.MSOfree_variables) == 0):
        dic = {}
        A = copy(F)    
        for a in F._alphabet:
            dic[a] = a[0]
        A.rename_letters(dic)
        return A.minimal_automaton()
           
                  
