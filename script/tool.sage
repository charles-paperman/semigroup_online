import urllib
load('regular_language.sage')
load('sg_utils.sage')
load('parse_utils.sage')
load('chaines.sage')
load('automata_utils.sage')
local = os.getcwd()
sage_obj_url = local+"/../data/sage_obj/"
imgurl = local+"/../data/img/"
#sage_obj_url = "/home/charles/www/sage_obj/"
#imgurl = "/home/charles/www/img/"
     
     
def draw_box_JSON(box):
    s = '"box":{'

    for u in box:
        s = s +'"'+ str(u)+'":{'
        for L in box[u]:
            s = s + '"'+str(L[0][0]) + '":{'
            for H in L:
                s = s + '"'+str(H[0]) + '":['
                for a in H:
                    s = s +'"'+ str(a) +'",'
                s = s[0:len(s)-1] + '],'
                #uns = u.replace("*","")              
            s = s[0:len(s)-1]+"},"
        s = s[0:len(s)-1] + '},' 
    return s[0:len(s)-1]+'}' 
    
def depth_DAG(G):
    Top = G.topological_sort()
    Top.reverse()
    Depth = {}
    for x in G:
        Depth[x] = 0
    while len(Top) > 0:
        x = Top.pop()
        for y in G.depth_first_search(x):
            Depth[y] = Depth[y]+1          
    val = list(set(Depth.values()))
    val.sort()
    result = {}
    for k in range(len(val)):
        result[str(k)] = []    
    for x in G:
        dx = val.index(Depth[x])
        result[str(dx)].append(x)
        Depth[x] = dx
    discret = 1    
    for x in result:
        discret = lcm(discret,len(result[x]))
    s = str(result)
    s = "{"
    for x in result:
        s += '"'+str(x)+'":['
        for y in result[x]:
            s += '"'+str(y)+'",'
        s = s[0:len(s)-1]+"]," 
    s = s[0:len(s)-1]+"}"
    return (s,len(val),Depth)

def J_class_graph_JSON(S,representant):
    Gcal =  DiGraph(S.cayley_graph(loop=False, orientation="left_right"))  
    J = {}
    if verbose:
        count = 0
    l = list(representant)    
    for x in representant:
        J[x] = list(S.J_class_of_element(x))
        Jx = set(J[x])
        Jx.remove(x)    
        Lx = [x]
        Lx.extend(Jx)            
        Gcal.merge_vertices(Lx)
     
    d = depth_DAG(Gcal)    
    
    result = '{"nodes":['
    for x in l:
        result = result + '{"name":"'+str(x)+'", "depth":"'+str(d[2][x])+'","max_depth":"'+str(d[1]-1)+'"},' 
    result = result[0:len(result)-1]+'],"depth":'+str(d[0])+',"max_depth":"'+str(d[1]-1)+'"}'      
    result = result.replace("'",'"')
    return result

def box_request(s,A=None):
    try: 
        M = simplify_regex(s,A=A).syntactic_monoid()    
    except:
        return "parse regexp error "     
    box = M.box_representation()
    req = "{"
    req = req + draw_box_JSON(box)
    req = req+', "idempotents":['
    for x in M.idempotents():
        req = req + '"'+x+'",'
    req = req[0:len(req)-1] +"]"
    req = req+', "elements":['
    for x in M:
        req = req + '"'+x+'",'
    req = req[0:len(req)-1] +"],"
    req = req + '"Jgraph":'+J_class_graph_JSON(M,set(box))+"}" 
    req = req.replace('""','"1"') 
    return req

def pres_request(s,maxlen=None):
    E = parse_presentation(s)
    try: 
        M = semigroup_by_presentation(E,maxlen=maxlen) 
    except:
        return "Error computing presentation"     
    box = M.box_representation()
    req = "{"
    req = req + draw_box_JSON(box)
    req = req+', "idempotents":['
    for x in M.idempotents():
        req = req + '"'+x+'",'
    req = req[0:len(req)-1] +"]"
    req = req+', "elements":['
    for x in M:
        req = req + '"'+x+'",'
    req = req[0:len(req)-1] +"],"
    req = req + '"Jgraph":'+J_class_graph_JSON(M,set(box))+"}" 
    req = req.replace('""','"1"') 
    return req


def automata_sg(s,format,A=None):
    try: 
        aut = simplify_regex(s,A=A).automaton_minimal_deterministic()
    except:
        return "Error parsing the regexp"     
    return automata_request(aut,format)

def automata_pres(s,format,maxlen=None):
    E = parse_presentation(s)
    try: 
        aut = semigroup_by_presentation(E,maxlen=maxlen)._automaton 
    except:
        return "Error computing presentation"     
    return automata_request(aut,format)
def automata_aut(s,format):
    try: 
        aut = parse_aut(s).minimal_automaton() 
    except:
        return "Error parsing automaton"     
    return automata_request(aut,format)



def regexp_list_json(regexp_list):
    return str(regexp_list)    

def deal_request(s):
    s = s.split("?")[1]
    dic = parse_get(s)
    if (dic["inputtype"] == "Automata"):
        return InputAutomata(dic)
    if (dic["inputtype"] == "RegularExpression"):
        return InputRegularExpression(dic)
    if (dic["inputtype"] == "Monoid"):
        return InputMonoid(dic)
    if (dic["inputtype"] == "Words"):
        return InputWords(dic)        
    if (dic["inputtype"] == "Logic"):
        return InputLogic(dic)        

def InputAutomata(dic):
    if dic["Request"] == "isValid":
        try:
            if ("alphabet" in dic):
                A = parseAutomataDescription(dic["description"],dic["initial_states"],dic["final_states"],set(dic["alphabet"]))
            else:
                A = parseAutomataDescription(dic["description"],dic["initial_states"],dic["final_states"])
            return returnAutomatonRequest(A,dic) 
        except:            
            print >> log, "Unexpected error:", sys.exc_info()
            return "false"
    if "AutomatonId" in dic:
        A = load(sage_obj_url+dic["AutomatonId"])        
    else:           
        if ("alphabet" in dic):
            A = parseAutomataDescription(dic["description"],dic["initial_states"],dic["final_states"],set(dic["alphabet"]))
        else:
            A = parseAutomataDescription(dic["description"],dic["initial_states"],dic["final_states"])
    dic["title"] = "Automaton with "+str(len(A._states))+" states"
    if (dic["Request"] == "TransitionMonoid"):
        if not A.is_deterministic():
            return '{"type":"error","description":"Automaton should be deterministic"}'
        else:
            M = TransitionSemiGroup(A)
            return returnMonoidRequest(M,dic)
    if (dic["Request"] == "SyntacticMonoid"):
        A = A.minimal_automaton()
        M = TransitionSemiGroup(A)
        return returnMonoidRequest(M,dic)
    if (dic["Request"] == "SyntacticOrder"):
        return returnOrderRequest(A,dic)
    if (dic["Request"] == "MembershipTransitionMonoid"):
        print "plop"
        return returnMembershipRequestofAut(A,dic,Lattice="Variety")    
    if (dic["Request"] == "Automaton"):
        return returnAutomatonRequest(A,dic)
    if (dic["Request"] == "MinimalAutomaton"):
        return returnAutomatonRequest(A.minimal_automaton(),dic)
    if (dic["Request"] == "ComputePairs"):
        if not A.is_deterministic():
            return '{"type":"error","description":"Automaton should be deterministic"}'
        else:
            M = TransitionSemiGroup(A)
            return returnPairRequest(M)
    return  '{"type":"error","description":"Not Implemented Error"}'   
                                
def InputRegularExpression(dic):
    if "description" not in dic:                
        return '{"type":"error","description":"No description of the automaton"}'      
    else:
        dic["title"] = dic["description"]   
        try:
            if ("alphabet" in dic):        
                L = parseRegularDescription(dic["description"],alphabet=dic["alphabet"])
            else:
                L = parseRegularDescription(dic["description"])
        except:       
            return '{"type":"error","description":"unvalid regular expression"}'   
        if (dic["Request"] == "SyntacticMonoid"):
            return returnMonoidRequest(L.syntactic_monoid(),dic)
        if (dic["Request"] == "LeftCayley") or (dic["Request"] == "RightCayley"):
            dic["format"] = "Image";
            return returnMonoidRequest(L.syntactic_monoid(),dic)
        if (dic["Request"] == "SyntacticOrder"):
            return returnSyntacticOrderRequest(L,dic)    
        if (dic["Request"] == "MinimalAutomaton"):
            return returnAutomatonRequest(L.automaton_minimal_deterministic(),dic)
        if (dic["Request"] == "MembershipMonoids"):
            return returnMembershipRequest(L,dic,Lattice="Variety")
        if (dic["Request"] == "CircuitComplexity"):
            return returnMembershipRequest(L,dic,Lattice="Complexity")
        if dic["Request"] == "isValid":
            try:
                L.automaton();
                return "true"
            except:
                return "false"
        if (dic["Request"] == "ComputePairs"):
            M = L.syntactic_monoid()
            return returnPairRequest(M)

        return  '{"type":"error","description":"Not Implemented Error"}'   

def InputMonoid(dic):
    if "id" not in dic:                
        return '{"type":"error","description":"wrong idea (huhu)"}'      
    else:           
        M = load(sage_obj_url+dic["id"])        
        if (dic["Request"] == "Box"):
            return returnMonoidRequest(M,dic)
        if (dic["Request"] == "MembershipMonoids"):
            return returnMembershipRequestofMonoid(M,dic,Lattice="Variety")
        if (dic["Request"] == "CircuitComplexity"):
            return returnMembershipRequestofMonoid(M,dic,Lattice="Complexity")
        if (dic["Request"] == "RecognizedLanguage"):
            A = PreImage(M,dic["selectedElements"])
            return returnAutomatonRequest(A,dic)
        if (dic["Request"] == "Quotient"):
            M = QuotientRequest(M,dic["selectedElements"])
            return returnMonoidRequest(M,dic)
        if (dic["Request"] == "Submonoid"):
            M = SubMonoidRequest(M,dic["selectedElements"])
            return returnMonoidRequest(M,dic)
        


    return  '{"type":"error","description":"Not Implemented Error"}'   

def InputWords(dic):
    if "description" not in dic:                
        return '{"type":"error","description":"No description of Word"}'
    else:
        s = dic["description"]
        M = load(sage_obj_url+dic["MonoidId"])
        if (dic["Request"] == "WordImage"):           
            u = M(s)    
            return returnWordRequest(u)
        if (dic["Request"] == "WordsPreImage"):    
            A = PreImage(M,s)
            return returnAutomatonRequest(A,dic)
        if (dic["Request"] == "GroupOfHclass"):
            if (s == "1"):
                s = ""
            H = HclassToGapGroup(M,s)
            return returnGroupRequest(H.structure_description())            
        return '{"type":"error","description":"error for request:'+str(dic)+'"}'        

def InputLogic(dic):
    if "description" not in dic:                
        return '{"type":"error","description":"No description of Word"}'
    else:        
        t = parseJsonEncoding(dic["description"])
        if ("Alphabet" in dic):
            Alphabet = set(dic["Alphabet"])
        else:
            Alphabet = detectAlphabet(t)
        A = evaluate_MSO_tree(t,Alphabet)
        A = Closure(A)
        if (dic["Request"] == "SyntacticMonoid"):
            dic["title"] = "Syntactic monoid of formula"
            return returnMonoidRequest(TransitionSemiGroup(A),dic)    
        if (dic["Request"] == "MinimalAutomaton"):
            dic["title"] = "Minimal automaton of formula"
            return returnAutomatonRequest(A,dic)
        return '{"type":"error","description":'+str(A)+'}'        

def returnAutomatonRequest(A,dic):
    id_filename = tmp_filename(sage_obj_url)
    save(A,id_filename)
    split = id_filename.split("/")
    id_filename = split[len(split)-1]
    if "title" not in dic:
        dic["title"] = ""
    if ("format" not in dic) or (dic["format"] == "Image"):
        file_svg = tmp_filename(imgurl)
        A.to_svg(file_svg)
        f = file(file_svg+".svg","r+")
        d = f.readlines()
        f.seek(0)
        for i in d:
            if not ('polygon fill="white"' in i):
                f.write(i)    
        f.truncate()
        f.close()
        split = file_svg.split("/")
        filename = split[len(split)-1]
        d = A._transitions
        trans_string = ""
        for x in d:
            trans_string += str(x[0])+"."+str(x[1])+"->"+str(d[x]).translate(None,'"[]')+";" 
        initial_string = str(A._initial_states).translate(None,'"[]')
        final_string = str(A._final_states).translate(None,'"[]')
        
        return '{"type":"Automata","format":"Image","description":{"url":"data/img/'+filename+'.svg", "id":"'+id_filename+'", "automaton_desc": '+aut_to_json(A)+'}}'
    
    if dic["format"] == "Json":
        rep = '{"type":"Automata","format":"Json","description":{'
        rep = rep + '"Initials":"'
        for x in A._initial_states:
            rep = rep+str(x)+','
        rep = rep[0:len(rep)-1]+'","Finals":"'
        for x in A._final_states:
            rep = rep+str(x)+','
        rep = rep[0:len(rep)-1]+'","Transitions":[ '
        d = A._transitions
        for x in d:
            rep = rep+'"'+str(x[0])+"."+str(x[1])+"->"
            for y in d[x]:
                rep = rep + str(y)+',' 
            rep = rep[0:len(rep)-1]+';",'
        rep = rep[0:len(rep)-1]+']},"title":"'+dic["title"]+'"}'               
        return rep 
    return '{"type":"error","description":"unvalid format"}'

def returnMonoidRequest(M,dic):
    id_filename = tmp_filename(sage_obj_url)
    save(M,id_filename)
    split = id_filename.split("/")
    id_filename = split[len(split)-1]
    if ("format" not in dic) or (dic["format"] == "Json"):
        rep = '{"type":"Monoid","format":"Json","id":"'+id_filename+'","description":{'
        box = M.box_representation()
        req = rep 
        req +=  draw_box_JSON(box)
        req += ', "idempotents":['
        for x in M.idempotents():
            req += '"'+str(x)+'",'
        req = req[0:len(req)-1] +"]"
        req += ', "elements":['
        for x in M:
            req +=  '"'+str(x)+'",'
        req = req[0:len(req)-1] +"],"
        req += '"Jgraph":'+J_class_graph_JSON(M,set(box))+"}}" 
        req = req.replace('""','"1"') 
        return req                
    
    if dic["format"] == "Image":
        file_svg = tmp_filename(imgurl)
        MonoidToSVG(M,file_svg,dic)
        f = file(file_svg+".svg","r+")
        d = f.readlines()
        f.seek(0)
        for i in d:
            if not ('polygon fill="white"' in i):
                f.write(i)
        f.truncate()
        f.close()
        split = file_svg.split("/")
        filename = split[len(split)-1]
        return '{"type":"Monoid","title":"'+dic["title"]+'","format":"Image","description":{"url":"data/img/'+filename+'.svg", "id":"'+id_filename+'"}}'
    
    return '{"type":"error","description":"unvalid format"}'

def returnWordRequest(word):
    return '{"type":"Word","format":"Json","description":"'+str(word)+'"}'

def returnGroupRequest(groupstring):
    return '{"type":"Group","format":"Json","description":"'+groupstring+'"}'
def returnMembershipRequest(L,dic,Lattice="Variety"):
    return returnMembershipRequestofAut(L.automaton_minimal_deterministic(),dic,Lattice=Lattice)
    
def returnMembershipRequestofAut(A,dic,Lattice="Variety"):
    return returnMembershipRequestofMonoid(TransitionSemiGroup(A),dic,Lattice=Lattice)

def returnMembershipRequestofMonoid(M,dic,Lattice="Variety"):    
    s = '{"format":"Image","type":"VarietyList","description":['
    id_filename = tmp_filename(sage_obj_url)
    save(M,id_filename)
    split = id_filename.split("/")
    id_filename = split[len(split)-1]
    file_svg = tmp_filename(imgurl)
    if (Lattice == "Variety"):
        VarietyListToSVG(M,file_svg)
    if (Lattice == "Complexity"):
        ComplexityListToSVG(M,file_svg)
        
    f = file(file_svg+".svg","r+")
    d = f.readlines()
    f.seek(0)
    for i in d:
        if not ('polygon fill="white"' in i):
            f.write(i)
    f.truncate()
    f.close()
    split = file_svg.split("/")
    filename = split[len(split)-1]
    return '{"type":"'+Lattice+'List","format":"Image","description":{"url":"data/img/'+filename+'.svg", "MonoidId":"'+id_filename+'"}}'

def returnOrderRequest(A,dic):
    M = TransitionSemiGroup(A)
    id_filename = tmp_filename(sage_obj_url)
    save(M,id_filename)
    split = id_filename.split("/")
    id_filename = split[len(split)-1]    
    listGraphs = graphvizTransitionOrderedMonoid(A)
    listFileSVG = []
    for G in listGraphs:        
        file_svg = tmp_filename(imgurl)
        listFileSVG.append(file_svg)
        file_dot = tmp_filename(".",".dot")
        f = file(file_dot,'w') 
        f.write(G)
        f.close()
        os.system('dot -Tsvg %s -o %s'%(file_dot,file_svg+".svg"))
        f = file(file_svg+".svg","r+")
        d = f.readlines()
        f.seek(0)
        for i in d:
            if not ('polygon fill="white"' in i):
                f.write(i)
        f.truncate()
        f.close()
       
    result = '{"type":"Order","format":"Images","ImageCount":'+str(len(listFileSVG))+',"description":{"id":"'+id_filename+'","ImagesList":[ '
    for f in listFileSVG:
        split = f.split("/")
        filename = split[len(split)-1]    
        result += '{"url":"data//img/'+filename+'.svg"},'
    result = result[0:len(result)-1]+"]}}"
    result = (result.replace(" ",""))
    return result
def returnSyntacticOrderRequest(L,dic):
    return returnOrderRequest(L.automaton_minimal_deterministic(),dic)
