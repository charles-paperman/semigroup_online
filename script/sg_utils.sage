def emptyAutomaton(letters):
    d = {}
    for x in letters:
        d[(0,x)] = [0]
    return Automaton(d,[0],[])
    
def stable_semigroup(M):
    S = M._stable()[0]
    d = {}
    for x in S:
        for y in S:
            d[(x,(y,))] = [M(x+y)]
    return TransitionSemiGroup(Automaton(d,[0],[0]))        

def computeOrderedAutomata(A):
    Order = set()
    Aut = {}
    for p in A._states:
        Aut[p] = Automaton(A._transitions,[p],A._final_states)                           
    for p in A._states:
        for q in A._states:
            B = Aut[p]-Aut[q]
            if (not B.is_finite_state_reachable()):
                Order.add((q,p))  
    return Order

def computeTransitionOrderedMonoid(A):
    M = TransitionSemiGroup(A)
    AutomataOrder = computeOrderedAutomata(A)
    MonoidOrder = set()
    for u in M:
        fu = M._Representations_rev[u]    
        for v in M:
            if (u != v):
                fv = M._Representations_rev[v]
                ordered_pair = True
                for q in A._states:                    
                    if (fu(q),fv(q)) not in AutomataOrder:
                        ordered_pair = False
                if ordered_pair:
                    MonoidOrder.add((u,v))       
    return MonoidOrder                
def graphvizSyntacticOrderedMonoid(L):
    return graphvizTransitionOrderedMonoid(L.automaton_minimal_deterministic())
def graphvizTransitionOrderedMonoid(A):    
    Order = computeTransitionOrderedMonoid(A)
    M = TransitionSemiGroup(A)    
    G = DiGraph(DiGraph(list(Order)))
    LG = [G.subgraph(K).transitive_reduction() for K in G.connected_components()]
    result = []
    E = M.idempotents()
    for G in LG:
        GGraphViz = "digraph {\n"
        nodes = ""
        for u in G.vertices():
            nodes += '"'+str(u)+'"'
            if u in E:
                nodes += '[fill=white fontcolor = red]'
            nodes += ';\n'
        edges = ""    
        for e in G.edges():
            edges += '"'+str(e[0])+'"->"'+str(e[1])+'";\n'
        GGraphViz =  'digraph {\n'+ nodes + edges+'}'
        GGraphViz = GGraphViz.replace('""','"1"')
        result.append(GGraphViz)
    return result        
def getLocalSemiGroups(M):
    E = set(M.idempotents())
    L = []
    
    for x in list(E):
        if (len(x) == 0):
            E.remove(x)

    for e in E:
        States = set()
        for x in M:
            States.add(M(e+x+e))
        States = list(States)    
        Transitions = {}
        for x in States:
            for y in range(len(States)):
                Transitions[(x,y)] = [M(x+States[y])]
        L.append(TransitionSemiGroup(Automaton(Transitions,[e],[e])))
    return L                                    
def is_LDA(M):
    for x in getLocalSemiGroups(M):
        if not(is_DA(x)):
            return False
    return True                                
def is_QLDA(M):
    S = stable_semigroup(M)
    return is_LDA(S)
def is_QA(M):
    S = stable_semigroup(M)
    return S.is_Ap()


def AutomataToRegExp(A):
    Initial_states = A._initial_states
    Final_states = A._final_states
    d = A._transitions
    states = A._states
    alphabet = A._alphabet
    Switch = True
    for i in Initial_states:
        for f in Final_states:
            if Switch:
                Swith = False
                L =  Aut2reg(d,alphabet,i,f,states)
            else:
                L = L + Aut2reg(d,alphabet,i,f,states)
    return L                   
def Aut2reg(d,alphabet,i,f,states_list):
    A = alphabet
    states = list(states_list)
    d_reg = {}
    if i in states:
        states.remove(i)
    if f in states:
        states.remove(f)
    for t in d:
        for x in d[t]:
            if (t[0],x) in d_reg:
                d_reg[(t[0],x)] =  d_reg[(t[0],x)] + RegularLanguage(t[1],letters=A) 
            else:
                d_reg[(t[0],x)] =  RegularLanguage(t[1],letters=A)
                   
    while len(states) > 0:
        s = states.pop()
        d_reg_buff = dict(d_reg)
        to_remove = set() 
        for t1 in d_reg_buff:
            for t2 in d_reg_buff:
                if (t1[1] == s) and (t2[0] == s):
                    to_remove.add(t1)
                    to_remove.add(t2)
                    if not (s,s) in d_reg: 
                        if (t1[0],t2[1]) in d_reg:
                            d_reg[(t1[0],t2[1])] =  d_reg[(t1[0],t2[1])] +  d_reg[t1]*d_reg[t2]
                        else:
                            d_reg[(t1[0],t2[1])] =   d_reg[t1]*d_reg[t2]
                    if  (s,s) in d_reg: 
                        if (t1[0],t2[1]) in d_reg:
                            d_reg[(t1[0],t2[1])] =  d_reg[(t1[0],t2[1])] +  d_reg[t1]*(d_reg[(s,s)].kleene_star())*d_reg[t2]
                        else:
                            d_reg[(t1[0],t2[1])] = d_reg[t1]*(d_reg[(s,s)].kleene_star())*d_reg[t2]
        [d_reg.pop(t) for t in to_remove]
    
    if not (i,f) in d_reg:
        raise TypeError("Empty language")
    if (i == f):
        return d_reg[(i,i)].kleene_star()
    if (f,f) in d_reg:
        d_reg[(i,f)] = d_reg[(i,f)]*(d_reg[(f,f)].kleene_star())    
    if (i,i) in d_reg:
        d_reg[(i,f)] = (d_reg[(i,i)].kleene_star())*d_reg[(i,f)]    
    
    if ((f,i) in d_reg):
        return (d_reg[(i,f)]*d_reg[(f,i)]).kleene_star()*d_reg[(i,f)]
    else:
        return d_reg[(i,f)]     

def MonoidToSVG(M,filename,dic):
    file_dot = tmp_filename(".",".dot")
    f = file(file_dot,'w')
    if (dic["Request"] == "SyntacticMonoid"):
        f.write(M.graphviz_string())
 
    if (dic["Request"] == "RightCayley"):
        f.write(M.cayley_graphviz_string(orientation="right"))
    if (dic["Request"] == "LeftCayley"):
        f.write(M.cayley_graphviz_string(orientation="left"))
    f.close()
    os.system('dot -Tsvg %s -o %s'%(file_dot,filename+".svg"))
    
def complete(A):
    A.rename_states()
    d = dict(A._transitions)
    alphabet = A._alphabet
    states = A._states
    sink = len(states)
    complete = True
    for x in states:
        for a in alphabet:
            if not (x,a) in d:
                d[(x,a)] = [sink]
                complete = False
    if not complete:
        for a in alphabet:
            d[(sink,a)] = [sink]
    return Automaton(d,A._initial_states,A._final_states)

def PreImage(M,s):
    if (s == ""):       
        return  emptyAutomaton(M._generators)  
    Words = s.split(",")
    if "1" in Words:
        Words.append("")
        Words.remove("1")
    acc = [monoidElement(x) for x in Words]
    d = {}
    for x in M:
        for a in M._generators:
            d[(x,a)] = [M(x+a)]
    return Automaton(d,[monoidElement("")],acc).minimal_automaton()   

def SubMonoidRequest(M,s):
    Words = s.split(",")
    identity = monoidElement("")
    if "1" in Words:
        Words.append(identity)
        Words.remove("1")
    return SubMonoid(M,Words)
    
def SubMonoid(M,generators):
    G = set(generators)
    identity = monoidElement("")
    G.add(identity)
    return SubSemiGroup(M,G)

def SubSemiGroup(M,generators):
    d = {}
    letters = [monoidElement((x,)) for x in generators]
    identity = monoidElement("")
    toDealWith = list([identity])
    Elements = set()
    if identity in generators:
        Elements.add(identity)
              
    while len(toDealWith)>0:
        y = toDealWith.pop()        
        for a in letters:
            u = y+a[0]
            z = M(u)            
            if z not in Elements:
                toDealWith.append(z)
                Elements.add(z)
            if y in Elements:
                d[(y,a)] = [z]
    A = Automaton(d,[],[],alphabet=letters)
    return TransitionSemiGroup(A) 
      
def commutatorsSubGroup(G):
    if not is_G(G):
        raise ValueError("Commutators subgroups: must be a group, comm'on")
    Commutators = set()
    inverse = dict()
    for x in G:
        inverse[x] =3 
    for x in G:
        for y in G:
            return 3    
                                                                   
def QuotientRequest(M,s):
    Words = s.split(",")
    identity = ""
    if "1" in Words:
        Words.append(identity)
        Words.remove("1")
    return Quotient(M,Words)
    
def Quotient(M,C):
    d = {}    
    C = frozenset([monoidElement(u) for u in C])        
    if len(C)<2:
        return M

    for x in M:
        if x not in C:
            d[x] = frozenset([x])
        else:
            d[x] = C                 
    toDealWith = list(d.values())
    while len(toDealWith)>0:
        C = toDealWith.pop()
        for a in M._generators:
            listToMergeR = []
            listToMergeL = []
            for x in C:
                for b in d[a]:
                    xb = M(x+b)
                    if not d[xb] in listToMergeR:
                        listToMergeR.append(d[xb])
                    bx = M(b+x)
                    if not d[bx] in listToMergeL:
                        listToMergeL.append(d[bx])
            DR = frozenset()
            DL = frozenset()
            if len(listToMergeR) > 1:
                for K in listToMergeR:
                    DR = DR.union(K)
            if len(listToMergeL) > 1:
                for K in listToMergeL:
                    DL = DL.union(K)
            if len(DR.intersection(DL))>0:
                D = DR.union(DL)
                toDealWith.append(D)     
                for x in D:
                    d[x] = D
            else:
                if len(DR)>0:
                    toDealWith.append(DR)     
                    for x in DR:
                        d[x] = DR

                if len(DL)>0:
                    toDealWith.append(DL)     
                    for x in DL:
                        d[x] = DL                
            
    transitions = {}
    states = set(d.values())
    for x in states:
        for a in M._generators:
            y = d[M(list(x)[0]+a)]
            transitions[(x,a)] = [y]                         
    A = Automaton(transitions,[],[])
    return TransitionSemiGroup(A)   

       
def makeAutomatonComplete(A):
    A.rename_states()
    d = A._transitions
    bot = -1
    for x in A._states:
        for a in A._alphabet:
            if (x,a) not in d:
                d[(x,a)] = [-1]
    return Automaton(d,A._initial_states,A._final_states)                            

def is_DS(M):
    E = set(M.idempotents())
    All = set(M)
    NonE = All.difference(E)
    for e in E:
        if not (M.is_sub_semigroup(M.J_class_of_element(e))) > 0:
            return False
    return True
def is_G(M):
    E = set(M.idempotents())    
    if len(E) > 1:
        return False
    else:
        return True
def is_Gsol(M):
    if is_G(M):        
        H = HclassToGapGroup(M,list(M)[0])                
        return H.is_solvable()
    else:
        return False	
        	
def is_Msol(M):
    E = set(M.idempotents())
    while len(E) > 0:
        e = E.pop()
        J = M.J_class_of_element(e)
        E = E.difference(J)
        H = HclassToGapGroup(M,e)
        if not (H.is_solvable()):
            return False
    return True        
def is_J(M):
    E = M.idempotents()
    for e in E:
        if len(M.J_class_of_element(e))>1:
            return false
    return true    
def is_R(M):
    E = M.idempotents()
    for e in E:
        if len(M.R_class_of_element(e))>1:
            return false
    return true    
def is_L(M):
    E = M.idempotents()
    for e in E:
        if len(M.L_class_of_element(e))>1:
            return false
    return true  
def is_Nil(M):
    if is_J(M):
        return (len(M.idempotents()) <= 2) 
    else:
        return False      
def is_DA(M):
    return (M.is_Ap() and is_DS(M))                         

def HclassToGroup(M,x):
    H = list(M.H_class_of_element(x))
        
        
def HclassToGapGroup(M,x):
    H = set(M.H_class_of_element(x))
    E = set(M.idempotents())
    H = list(H)
    n = len(H)
    permutations = []
    for x in H: 
        permx = []           
        Rem = set(range(1,n+1))
        while len(Rem) > 0:
            i = Rem.pop()            
            j = H.index(M(H[i-1]+x))+1                
            cyclei = (i,)
            while not (j == i):
                Rem.remove(j)
                cyclei += (j,)
                j = H.index(M(H[j-1]+x))+1
            if len(cyclei) > 1:    
                permx.append(cyclei)
        if len(permx) > 0:
            permutations.append(permx)              
    G = SymmetricGroup(n)
    return G.subgroup(permutations)

VarietyLattice = {"All":["Msol","DS"],"Msol":["Ap","Gsol","Com"],"Ap":["DA"],"DS":["G","DA","Com"],"Com":["Ab","ACom"],"G":["Gsol"],"Gsol":["Ab"],"DA":["Idempotent","R","L"],"R":["J"],"L":["J"],"J":["ACom","Nil"],"ACom":["SemiLattice"],"Idempotent":["SemiLattice"],"Nil":["SemiLattice"],"SemiLattice":["Trivial"],"Ab":["Trivial"],"Trivial":[]}
VarietyList = VarietyLattice.keys()


def VertexGraphvizLattice(Lattice,point,LatticeColor,done):
    if point in done:
        return ""
    else:    
        done.add(point)
        s = '"'+point+'" [fillcolor='+LatticeColor[point]+'];\n'
        for x in Lattice[point]:
            s += VertexGraphvizLattice(Lattice,x,LatticeColor,done)
        return s
def EdgeGraphvizLattice(Lattice,point,done):
    s = ""
    if not (point in done):
        done.add(point) 
        for x in Lattice[point]:
            s += '"'+point+'" -> "'+x+'";\n'                
            s += EdgeGraphvizLattice(Lattice,x,done)
    return s           
def GraphvizLattice(Lattice,point,LatticeColor):
    doneVertex = set()
    doneEdge = set()
    return 'digraph {\nnode [style=filled]\n'+ VertexGraphvizLattice(Lattice,point,LatticeColor,doneVertex) + EdgeGraphvizLattice(Lattice,point,doneEdge)+'}'
def GraphvizVariety(M):
    LatticeColor = {}
    for x in VarietyList:
        if VarietyTest(M,x):
            LatticeColor[x] = "lightgreen"
        else:
            LatticeColor[x] = "lightgrey"
    return GraphvizLattice(VarietyLattice,"All",LatticeColor)                         

def VarietyListToSVG(M,filename):
    file_dot = tmp_filename(".",".dot")
    f = file(file_dot,'w')
    f.write(GraphvizVariety(M))
    f.close()
    os.system('dot -Tsvg %s -o %s'%(file_dot,filename+".svg"))

def VarietyTest(M,VarietyName):
    if (VarietyName == "All"):
        return True
    if (VarietyName == "Trivial"):
        return (len(M) == 1)
    if (VarietyName == "Ap"):
        return M.is_Ap()
    if (VarietyName == "J"):
        return is_J(M)
    if (VarietyName == "Nil"):
        return is_Nil(M)

    if (VarietyName == "R"):
        return is_R(M)
    if (VarietyName == "L"):
        return is_L(M)
    if (VarietyName == "DS"):
        return is_DS(M)
    if (VarietyName == "G"):
        return is_G(M)
    if (VarietyName == "Gsol"):
        return is_Gsol(M)
    if (VarietyName == "Msol"):
        return is_Msol(M)
    if (VarietyName == "DA"):
        return is_DA(M)             
    if (VarietyName == "Com"):
        return (M.is_Commutative()) 
    if (VarietyName == "ACom"):
        return (M.is_Commutative() and M.is_Ap()) 
    if (VarietyName == "Ab"):
        return (M.is_Commutative() and is_G(M)) 
    if (VarietyName == "Idempotent"):
        return (M.is_Idempotent()) 
    if (VarietyName == "SemiLattice"):
        return (M.is_Idempotent() and M.is_Commutative()) 

           
