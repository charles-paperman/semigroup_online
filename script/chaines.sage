from sys import stdout
import os
import random
import threading

r"""
Li = Dyck of depth at most i
benchmark  
           L1 2.73 ms (monoid 6)
           L2 71.5 ms (monoid 15)
           L3 1.82  s (monoid 31)
           L4 34.6  s (monoid 56)
           L5 9   min (monoid 92)

"""
log = open("log.txt", "w")
ex1 = {(1,'a'):[0],(3,'b'):[0],(3,'a'):[2],(1,'b'):[3],(0,'b'):[4],(4,'b'):[4],(2,'a'):[3],(2,'b'):[1],(4,'a'):[4],(0,'a'):[1]}

ex2 = {(1,'a'):[2],(3,'b'):[1],(3,'a'):[0],(1,'b'):[2],(0,'b'):[4],(4,'b'):[0],(2,'a'):[3],(2,'b'):[0],(4,'a'):[4],(0,'a'):[2]}

ex3 = {(1,'a'):[2],(3,'b'):[4],(3,'a'):[3],(1,'b'):[0],(0,'b'):[0],(4,'b'):[3],(2,'a'):[1],(2,'b'):[2],(4,'a'):[0],(0,'a'):[3]}

ex4 = {(1,'a'):[3],(3,'b'):[2],(3,'a'):[1],(1,'b'):[4],(0,'b'):[2],(4,'b'):[1],(2,'a'):[2],(2,'b'):[4],(4,'a'):[0],(0,'a'):[4]}

ex5 = {(1,'a'):[3],(3,'b'):[4],(3,'a'):[4],(1,'b'):[3],(0,'b'):[4],(4,'b'):[1],(2,'a'):[0],(2,'b'):[2],(4,'a'):[4],(0,'a'):[2]}

ex6 = {(1,'a'):[4],(3,'b'):[1],(3,'a'):[0],(1,'b'):[2],(0,'b'):[4],(4,'b'):[4],(2,'a'):[0],(2,'b'):[3],(4,'a'):[3],(0,'a'):[2]}

ex7 = {(3,'a'):[1],(3,'b'):[0],(1,'a'):[3],(4,'a'):[4],(0,'a'):[4],(2,'b'):[4],(2,'a'):[2],(0,'b'):[1],(4,'b'):[2],(1,'b'):[4]}

ex8 = {(3,'a'):[1],(3,'b'):[2],(1,'a'):[3],(4,'a'):[0],(0,'a'):[4],(2,'b'):[4],(2,'a'):[2],(0,'b'):[2],(4,'b'):[1],(1,'b'):[4]}

ex9 = {(3,'a'):[1],(3,'b'):[4],(1,'a'):[0],(4,'a'):[2],(0,'a'):[2],(2,'b'):[1],(2,'a'):[4],(0,'b'):[3],(4,'b'):[0],(1,'b'):[1]}

ex10 = {(3,'a'):[2],(3,'b'):[0],(1,'a'):[0],(4,'a'):[4],(0,'a'):[1],(2,'b'):[1],(2,'a'):[3],(0,'b'):[4],(4,'b'):[4],(1,'b'):[3]}

ex11 = {(3,'a'):[4],(3,'b'):[3],(1,'a'):[4],(4,'a'):[0],(0,'a'):[3],(2,'b'):[1],(2,'a'):[2],(0,'b'):[4],(4,'b'):[3],(1,'b'):[2]}

c_ex_tight = [ex2,ex3,ex5,ex6,ex7,ex8,ex10,ex11]
L={}
u = ""
for i in range(10):
    u = "(a"+u+"b)*"
    L[i+1] = simplify_regex(u)
         
def convert_transition_to_online(d):
    s = ""
    for x in d:
        s += str(x[0])+"."+str(x[1])+"->"
        for y in d[x]:
            s += str(y)+","
        s = s[0:len(s)-1]+";\n"
    return s
def convert_transition_from_online(s):
    d = {}
    dic = s.split(";")
    for x in dic:
        if len(x) >0:
            left = x.split("->")[0].split(".")    
            right = x.split("->")[1].split(",")
            d[(left[0],left[1])] = list(right)
    return d
                
def returnPairRequest(M):
    rep = '{"type":"Pairs","description":{'    
    if (len(M)<300):
        Pairs = compute_pairs(M,output=log)
        Tight = test_tighness(M,pairs=Pairs,output=log)  
        saving_computation(M,Pairs,Tight)      
        if Tight == True:
            rep+='"tight":"True",'
        else:
            rep+='"tight":"False","clash":['
            for x in Tight:
                rep+='{"left":"'+str(x[0])+'","right":"'+str(x[1])+'","level":'+str(x[2])+'},'     
            rep = rep[0:len(rep)-1]+'],'
                
        rep+='"Pairs":{'
        for i in range(len(Pairs)-1):
            rep+='"'+str(i)+'":['
            for x in Pairs[i][0]:
                for y in Pairs[i][0][x]:
                    rep+= '{"left":"'+str(x)+'","right":"'+str(y)+'"},'
            rep=rep[0:len(rep)-1]+'],'
        rep=rep[0:len(rep)-1]+ '}}}'
    else:
        rep='"tight":"TooBig"}}'
        
    return rep
def display_chains(Pairs, index=0):
    s = """
digraph {
ranksep=0.5;
"""
    E = set(M)
    while len(E) > 0:
        x = M.pop_J_maximal(E)
        Jx = M.J_class_of_element(x)
        E = E.difference(Jx)
        s += "subgraph cluster"+x+"{\n style=filled;\n color=black;\n fillcolor=azure;\n splines=false\n"
        for y in Jx:
            color = '"blue"'
            if y in M.idempotents():
                color = '"red"'
            s+=  '"'+y+'" [label="'+y+'" fontcolor='+color+'];\n'
        s += '}\n'
    for x in M:
        for y in Pairs[index][0][x]:
            s+='"'+x+'"->"'+y+'";\n'
    s+= "}"
    return  s
    from sage.misc.temporary_file import tmp_filename 
    from sage.misc.viewer import browser
    file_dot = tmp_filename(".",".dot")
    file_gif = tmp_filename(".",".png")
    f = file(file_dot,'w')
    f.write(u)
    f.close()
    f = file(str(i)+".dot",'w')
    f.write(u)
    f.close()

    os.system('dot -Tgif %s -o %s; %s %s  2>/dev/null 1>/dev/null '%(file_dot,file_gif,browser(),file_gif))

def next_pairs(M,Drev,verbose=False,output=stdout):    
    # D doit être un dictionnaire de paires, Drev son reverse
    d = {}
    Pairs = {}
    PairsRev = {}
    Active = []
    i = 0.0
    for x in M:
        if verbose:
            i+= 1
            print  >> output, "\r\t Constructing next pairs:"+str(int(100*i/len(M)))+"%",
            output.flush()
        
        Active.append((x,x))
        for a in M._generators:
            d[(x,a)] = [M(a)]
        for e in M.idempotents():
            d[(x,e)] = []
        for z in M:
            e = M.idempotent_power(z)
            for y in Drev[z]:
                u = M(e+y+e)
                if u not in d[(x,e)]:
                    d[(x,e)].append(u)
        Pairs[x] = [x]
        PairsRev[x] = [x]
    Letters = [a for a in M._generators]
    Letters.extend([e for e in M.idempotents()])
    if verbose:
               
        print  >> output, "\tDone."
    
    while len(Active) > 0:
        NActive = []
        if verbose:
            i = 0.0 
            print  >> output, "\n\t\tPairs to check:"+str(len(Active))
            
            output.flush()
        for p in Active:
            if verbose:
                i += 1
                print  >> output, "\r\t\t\t remaining:"+str(int(100*i/len(Active)))+"%",
                output.flush()

            for a in Letters:
                for u in d[(p[0],a)]:
                    v = (M(p[0]+a),M(p[1]+u))
                    if not v[1] in Pairs[v[0]]:
                         NActive.append(v)
                         Pairs[v[0]].append(v[1])
                         PairsRev[v[1]].append(v[0])
        Active = list(NActive)
    return (Pairs,PairsRev)



def first_pairs(M):
    d = {}
    for x in M:
        d[x] = list(M)
    return d

def compute_pairs(M,verbose=False,output=stdout):
    i = 0
    Finished = False
    Pairs = {}
    Pairs[0] = (first_pairs(M),first_pairs(M))
    while not Finished:
        if verbose:
            print  >> output, "\t Actual level: "+str(i)+"..."
            output.flush()
        Finished = True
        Pairs[i+1] = next_pairs(M,Pairs[i][1],verbose=verbose,output=output)
        print  >> output, "Done"
        for x in Pairs[i+1][0]:
            if len(Pairs[i+1][0][x]) < len(Pairs[i][0][x]):
                Finished = False
        i += 1
    return Pairs
def test_tighness(M,output=stdout,path="",pairs=None):
    print  >> output, "start computing pairs ..."
    output.flush()
    if pairs == None:
        Pairs = compute_pairs(M,verbose=True, output=output)
    else:
        Pairs = pairs
    print  >> output, "Done"
    print >> output, "Pairs:"
    if not (path==""):
        f = file(path+"/Pairs","w")
        for i in Pairs:
            f.write(str(Pairs[i])+"\n")
        f.close()
    Conflit = set()
    for i in range(1,len(Pairs)-1):
        print  >> output, "\ttest level "+str(i)
        D = Pairs[i][1]
        F = Pairs[i+1][0]
        j = 1.0
        for e in M.idempotents():
            print  >> output, "\r\t\t"+str(int(100*j/len(M.idempotents())))+"% ...", 
            output.flush()
            j += 1
            for u in F[e]:
                for v in F[e]:
                    for w in D[e]:
                        if M(u+w+v) not in F[e]:
                            Conflit.add((e,M(u+w+v),i)) 
        print  >> output, "\tDone nb of conlit:"+str(len(Conflit))
    if len(Conflit) == 0:
        return True
    else:
        return Conflit
def test_tighness_randomly(N,size=5,alphabet=["a","b"],output=stdout):

    for i in range(N):
        M = TransitionSemiGroup(random_automaton(size,alphabet))
        print  >> output, "\n"
        print  >> output, M._automaton._transitions
        print  >> output, "Size of monoid :"+str(len(M))
        if len(M) <250:
            if not test_tighness(M)==True:
                return M
            else:
                print  >> output, "Done"
        else:
            print  >> output, "Too big"
def idempotent_set(E,M):
    F = frozenset(E)
    while not (F == product_set(F,F,M)):
        F = product_set(E,F,M)
    return F
def product_set(E,F,M):
    return frozenset([M(x+y) for x in E for y in F])
def aperiodic_point_like(M,verbose=True):
    Pointlike = [frozenset([x]) for x in M]
    Active = list(Pointlike)
    while len(Active)>0:
        if verbose:
            print "\r"+str(len(Active)),        
            stdout.flush()
        T = Active.pop()
        P = idempotent_set(T,M)
        Q = product_set(P,T,M)
        R = frozenset(P).union(Q)
        if R not in Pointlike:
            Pointlike.append(R)
            Active.append(R)
        for E in Pointlike:
            P = product_set(E,T,M)
            if P not in Pointlike:
                Pointlike.append(P)
                Active.append(P)
            P = product_set(T,E,M)
            if P not in Pointlike:
                Pointlike.append(P)
                Active.append(P)

    if verbose:
        print "Done (aperiodic-pointlike)"
    S = set(Pointlike)
    for e in list(S):
        for f in list(S):
            if e.issubset(f) and e in S and (not e==f):
                S.remove(e)
    return set(S)   
def saving_computation(M,pairs,tight):
    A = M._automaton
    s = "../data/pairs/"
    g = stringify_aut(A)[0:100]
    i = 0
    while (os.path.exists(s+"examples/"+g+str(i))) or (os.path.exists(s+"c_examples/"+g+str(i))) :
        i += 1
    g += str(i)
    if (tight==True):
        s += "examples/"+g
        os.makedirs(s)
    else:
        s += "c_examples/"+g
        os.makedirs(s)
        f = file(s+"/tight_ce.txt","w")
        f.write(str(tight))
        f.close()
    f = file(s+"/transitions.txt","w")
    for x in A._transitions:
        f.write(str(x[0])+"."+str(x[1])+"->"+str(A._transitions[x][0])+";\n")
    f.close()       
    f = file(s+"/pairs.txt","w")
    f.write(str(pairs))
    f.close()
          
def building_one_data(size=5,alphabet=["a","b"],output=stdout):
    A = random_automaton(size,alphabet)
    M = TransitionSemiGroup(A)    
    output.write("\t transitions:"+str(A._transitions)+"\n")
    output.write("\t size of monoids:"+str(len(M))+"\n")
    output.flush()
    if len(M)<100:
        Pairs = compute_pairs(M,verbose=True,output=output)
        Tight = test_tighness(M,pairs=Pairs,output=output)  
        saving_computation(M,Pairs,Tight)      
    return (A,M)            
def stringify_aut(A):
    s = str(A._transitions)
    return s.translate(None,"{('[, :]')}")
def building_data():
    x = sample(range(1000),1)[0]
    print x
    f = file("log_data_"+str(x),"w")
    i = 0
    while True:
        i += 1
        f.write(str(i)+"\n")
        t = building_one_data(size=(4+i%2),alphabet=["a","b"],output=f)
        f.write("\t"+str(t[0]._transitions)+"\n")
        f.write("\t"+str(len(t[1]))+"\n")
        f.flush()
def aperiodic_and_pairs(M,verbose=True):
    Pairs = compute_pairs(M,verbose=verbose)
    Ap = aperiodic_point_like(M,verbose=verbose)
    Ap_pairs = set()
    for A in Ap:
        for e in A:
            for f in A:
                Ap_pairs.add(frozenset((str(e),str(f))))
    pairs = set([frozenset((str(x),str(y))) for x in M for y in Pairs[len(Pairs)-1][0][x]])
    print pairs==Ap_pairs
    return (pairs==Ap_pairs,pairs.difference(Ap_pairs),Ap_pairs.difference(pairs))
