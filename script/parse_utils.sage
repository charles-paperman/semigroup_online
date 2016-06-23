def tuple_to_str(x):
    s = ""
    for i in x:
        s+= i
    return s
def parse_aut_state(s):
    s = s.split(";")[0]
    states = s.split(",")
    return states
def aut_to_json(A):
    d = A._transitions
    trans_string = ""
    for x in d:
        trans_string += str(x[0])+"."+str(x[1])+"->"+str(d[x]).translate(None,'"[]')+";" 
    initial_string = str(A._initial_states).translate(None,'"[]')
    final_string = str(A._final_states).translate(None,'"[]')
    return '{"transitions":"'+trans_string+'","initial":"'+initial_string+'","final":"'+final_string+'"}'
def parse_transition(s,alphabet):
    transition = s.split(";")[0]
    next_s = ';'.join(s.split(";")[1:])
    start_state = transition.split(".")[0]
    letter = transition.split(".")[1][0]
    next_states_token = transition.split(">")[1]
    next_states = parse_aut_state(next_states_token)
    if (letter == '_'):
        letter = alphabet[0]
        for a in range(1,len(alphabet)):
            next_s = start_state+"."+alphabet[a]+">"+next_states_token+";"+next_s
        print "nouveau:" + next_s      
    if (letter not in alphabet):
        raise ValueError("Alphabet issue")    
    return (next_s,start_state,letter,next_states)
def computeAlphabet(s):
    A = set([x[0] for x in  s.split(".")[1:]])
    A = A.difference(["_"])
    
    return A
def parseAutomataDescription(transitions,initial,final,alphabet=None):
    s = urllib.unquote(transitions)
    s = ''.join(s.split())
    s = s.replace("-","")
    d = {}
    
    if (alphabet == None):
        alphabet = computeAlphabet(s)
            
    while len(s) > 0:
        p = parse_transition(s,list(alphabet))
        s = p[0]
        d[(p[1],p[2])] = p[3] 
        alphabet.add(p[2])
    if "A" in alphabet:
        alphabet.remove("A")    
        newd = {}
        for t in d:
            if (t[1] == "A"):
                for a in alphabet:
                    newd[(t[0],a)] = d[t]
            else:
                newd[t] = d[t]
        d = newd
    initial_states = parse_aut_state(urllib.unquote(initial))
    final_states = parse_aut_state(urllib.unquote(final))

    return Automaton(d,initial_states,final_states,alphabet=alphabet)    

def parse_get(s):
    try:
        t = s.split("&")
        dic = {}
        for x in t:
            y = x.split("=")
            dic[y[0]] = "=".join(y[1:len(y)])
        return dic        
    except:
        return {}    
def parse_enumeration(s):
    try:
        List = s.split(",")
        return List        
    except:
        return {}    

def parse_presentation(u):
    s = u.split(";")
    E = []
    for u in s:
        e = u.split("=")
        if len(e) == 2:
            e[0] = re.sub('[^A-Za-z]+', '', e[0])
            e[1] =re.sub('[^A-Za-z]+', '', e[1])
            E.append(tuple(e))
        else:        
            return "Error input mismatch" 
    return E
def parseRegularDescription(regstr,alphabet=None):
    s = regstr.replace('%20','')
    if (alphabet == None):
        L = simplify_regex(s)
        return  L
    else:
        return simplify_regex(s,A=set(alphabet))
def parseJsonEncoding(s):
    s = s.replace("%22","")
    if len(s) > 0:
        if (s[0] == "["):
            return parseJsonEncodingList(s)
        if (s[0] == "{"):
            return parseJsonEncodingObject(s)
    return s
def parseJsonEncodingList(s):
    curr_str = s[1:len(s)-1]
    L = commaSplit(curr_str)
    List = []
    for i in L:
        List.append(parseJsonEncoding(i))
    return List
def parseJsonEncodingObject(s):
    curr_str = s[1:len(s)-1]
    L = commaSplit(curr_str)
    Obj = {}
    for i in L:
        t = i.partition(":")    
        Obj[t[0]] = parseJsonEncoding(t[2])
    return Obj
    
def commaSplit(s):
    count = 0
    curr_s = ""
    result = []
    for i in s:
        curr_s += i
        if i in ["{","["]:
            count += 1
        if i  in ["}","]"]:
            count += -1
        if (i == ",") and (count == 0):
            result.append(curr_s[0:len(curr_s)-1])
            curr_s = ""
    result.append(curr_s)        
    return result
