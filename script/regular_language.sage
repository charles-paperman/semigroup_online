#-*- coding:utf-8 -*-
from sage.rings.integer import Integer
import re

def simplify_regex(regex,A=None):
        r"""
        Generate a regular language using a simplify regex syntax. 
        The alphabet is automatically compute. To use with caution, 
        since in a lot of cases, it will not produce the desire regular language.
        INPUT:

        - ``alphabet`` -- list of letters 

        OUTPUT:

            Regular Languages over automatically compute alphabet

        EXAMPLES::

            sage: L = simplify_regex("(abba)*")
            sage: simplify_regex("(abc)*+(ad)*")
            Regular language: (a*b*c)^_star+(a*d)^_star over alphabet set(['a', 'c', 'b', 'd'])
            sage: simplify_regex("(ab)^3+(cd)*")
            Regular language: (a*b)^3+(c*d)^_star over alphabet set(['a', 'c', 'b', 'd'])
        
            sage: simplify_regex("(xx)*+(xd)*")
            Regular language: (xx)^_star+(x*d)^_star over alphabet set(['d'])

        """
        if not(A):
            s = str(regex)
            s = s.replace("(","")  
            s = s.replace(")","")        
            s = s.replace("^","")  
            s = s.replace("_star","")        
            s = s.replace("*","")  
            s = s.replace("+","")
            s = s.replace("-","")
            s = s.replace(" ","")
            s = s.replace("A","")        
            for x in range(10):
                while (str(x) in s):           
                    s = s.replace(str(x),"")
            A = set(s)
        alph_str = "("
        for a in A:
            alph_str = alph_str + a + "+"
        alph_str = alph_str[0:len(alph_str)-1] + ")"

        regex = regex.replace("A",alph_str)
        regex = regex.replace("1","(_empty_word)")  
        for x in A:
           for y in A:
               regex = regex.replace(x+y,x+"."+y)
        regex = regex.replace("*","^_star")  
        regex = regex.replace(")(",")*(")
        regex = regex.replace("_star(","_star*(")
        for x in A:
           regex = regex.replace(x+"(",x+"*(")
           regex = regex.replace(")"+x,")*"+x)
           regex = regex.replace("_star"+x,"_star*"+x)
           regex = regex.replace(x+x,x+"*"+x)
        regex = regex.replace(".","*")           
        return RegularLanguage(regex,letters=A)
r"""
%skip
EXAMPLES::

    sage: L = RegularLanguage("((a+b+c)^3)^_star*a*c*((a+c)^4)^_star*a*c*b*a*((a+b+c)^5)^_star",["a","b","c"])
    sage: L
    Regular language: ((a+b+c)^3)^_star*a*c*((a+c)^4)^_star*a*c*b*a*((a+b+c)^5)^_star over alphabet ['a', 'b', 'c']
    sage: A = L.automaton()
    sage: A
    Automaton of 76 states
    sage: B = A.minimal_automaton()                           #not tested - 71s
    sage: C = A.minimal_automaton(algorithm="Brzozowski")     #not tested - 63s
    sage: D = A.minimal_automaton(algorithm="Moore")          #not tested - 54s
    sage: B                         #not tested                                         
    Automaton of 2402 states         #not tested
    sage: C         #not tested
    Automaton of 2425 states         #not tested
    sage: D         #not tested
    Automaton of 2425 states         #not tested
    sage: A.is_accepted('aaaacaaaaacbaaaaaa')         #not tested
    True         #not tested
    sage: B.is_accepted('aaaacaaaaacbaaaaaa')         #not tested
    False         #not tested
    sage: C.is_accepted('aaaacaaaaacbaaaaaa')         #not tested
    True         #not tested
    sage: D.is_accepted('aaaacaaaaacbaaaaaa')         #not tested
    True

"""
load automata.sage
load transition_semigroup.sage
import itertools
class RegularLanguages(object):
    r"""
    Return the class of regular expressions over a given alphabet.

    INPUT:

    - ``alphabet`` -- list of letters

    OUTPUT:

        Regular Languages class over given alphabet. Each letter become a regularlanguage of itself. The letter 'x' is reserved for the kleene star operation.

    EXAMPLES::

        sage: RegularLanguages(('a','b'))
        Regular languages over alphabet ('a', 'b')

    """
    def __init__(self, alphabet):
        r"""

        EXAMPLES::


        """
        self._alphabet = alphabet
        glob = globals()
        for x in alphabet:
            glob[x] = RegularLanguage(x,alphabet)
        glob["x"] = var("x")


    def __repr__(self):
        r"""
        EXAMPLES::

            sage: RegularLanguages(('a','b','c'))
            Regular languages over alphabet ('a', 'b', 'c')
        """
        return "Regular languages over alphabet %s" % (self._alphabet,)
    def full_language(self):
        r"""
            return the language of all words.
        EXAMPLES::

        """ 
        E = set(self._alphabet)   
        s= E.pop()
        while len(E) > 0:
            s=s+"+"+E.pop()
        return RegularLanguage("("+s+")^_star",self._alphabet)
    def empty_language(self):
        r"""
            return the empty language.
        EXAMPLES::

        """    
        return (-self.full_language())
                        
    @cached_method
    def list_by_depth(self, depth=None, unique=False, starfree=False, verbose=False):
        r"""
        Return a list of regular expressions of given depth.

        INPUT:

        - ``depth`` -- integer
        - ``unique`` -- boolean (default False)
        - ``starfree`` -- boolean (default False)
        - ``verbose`` -- boolean (default False)
        
        OUTPUT:

        list of regular expressions

        EXAMPLES:

        The list (with redondancies)::

            sage: R = RegularLanguages(('a','b'))
            sage: L = R.list_by_depth(3)
            sage: len(L)
            124

        The list (with unique result)::

            sage: L = R.list_by_depth(3, unique=True)
            sage: len(L)
            44

        ::

            sage: R = RegularLanguages(("a"))
            sage: R.list_by_depth(1)
            [Regular language: a over alphabet a]
            sage: len(R.list_by_depth(2))
            4

        Some benchmarks::

            sage: R = RegularLanguages(("a", "b", "c"))
            sage: time L = R.list_by_depth(6) # not tested
            CPU times: user 16.43 s, sys: 1.65 s, total: 18.08 s
            Wall time: 17.90 s
            sage: time L = R.list_by_depth(6) # not tested
            Time: CPU 0.00 s, Wall: 0.00 s
            sage: time L = R.list_by_depth(7) # not tested
            Time: CPU 28.95 s, Wall: 28.96 s

        """
        if depth == 0:
            return [RegularLanguage("",self._alphabet)]
        if depth == 1:
            L  = []
            for a in self._alphabet:
                L.append(RegularLanguage(a,self._alphabet))
            return L
        P = []    
        for i in range(1,depth):    
            P.extend(self.list_by_depth(i,unique=unique,starfree=starfree))
        L = []
        for i in range(1, depth):
            for left in self.list_by_depth(i,unique=unique,starfree=starfree):          
                for right in self.list_by_depth(depth-i, unique=unique,starfree=starfree):
                    R = RegularLanguage(("(%s*%s)" % (left._regex, right._regex)),self._alphabet)
                    T = RegularLanguage(("(%s+%s)" % (left._regex, right._regex)),self._alphabet)
                    if (not unique) or not (R in L or R in P):
                        if verbose: print R
                        L.append(R)                
                    if (not unique) or not (T in L or T in P):
                        if verbose: print T                
                        L.append(T)
        for regex in P:
            R = RegularLanguage(("(%s)^_star" % (regex._regex)),self._alphabet)
            T = RegularLanguage(("-%s" % (regex._regex)),self._alphabet)
            if not(starfree) and ((not unique) or not (R in L or R in P)):
                if verbose: print R            
                L.append(R)
            if (not unique) or not  (T in L or T in P):
                if verbose: print T     
                L.append(T)
        return L
        
    def random_element(self, depth, aperiodic=False):
        r"""
        """   
        if (depth == 0):
            return RegularLanguage("%s" % (sample(self._alphabet,1)[0]),self._alphabet)
        if not aperiodic:
            c = sample(range(4),1)[0]   
            if (c== 0):
                L = self.random_element(depth-1)
                while L == self.empty_language() or L == self.full_language() or L._regex[len(L._regex)-1] == 'x':
                    L = self.random_element(depth-1)
                return L.kleene_star()
            if (c== 3):
                L = self.random_element(depth-1 )
                while L == self.empty_language() or L == self.full_language() or L._regex[len(L._regex)-1] == 'x':
                    L = self.random_element(depth-1)
                return -L        
            
            if (c== 1):
                return self.random_element(depth-1 )*self.random_element(depth-1 )
            if (c== 2):
                L1 = self.random_element(depth-1 )
                while L1 == self.full_language():
                    L1 = self.random_element(depth-1 )
                L2 = self.random_element(depth-1 )
                while L2 == self.full_language() or L1 == L2:
                    L2 = self.random_element(depth-1 )
        
                return L1+L2
        else:
            c = sample(range(3),1)[0]   
            if (c== 0):
                L = self.random_element(depth-1,aperiodic=aperiodic )
                while L == self.empty_language() or L == self.full_language() or L._regex[0] == '-':
                    L = self.random_element(depth-1,aperiodic=aperiodic)
                return -L        
            
            if (c== 1):
                return self.random_element(depth-1,aperiodic=aperiodic )*self.random_element(depth-1,aperiodic=aperiodic )
            if (c== 2):
                L1 = self.random_element(depth-1 ,aperiodic=aperiodic)
                while L1 == self.full_language():
                    L1 = self.random_element(depth-1 ,aperiodic=aperiodic)
                L2 = self.random_element(depth-1 ,aperiodic=aperiodic)
                while L2 == self.full_language() or L1 == L2:
                    L2 = self.random_element(depth-1 ,aperiodic=aperiodic)
                
                return L1+L2
                    
    
class RegularLanguage:    
    def __init__(self, regex, letters=None):
        r"""
        INPUT:

        - ``regex`` - string different from the empty word
        - ``alphabet`` - Set of atomic letters
        """
        self._regex = regex
        if letters is None:
            s = regex
            s = s.replace("(","")  
            s = s.replace(")","")        
            s = s.replace("^","")  
            s = s.replace("x","")        
            s = s.replace("*","")  
            s = s.replace("+","")
            s = s.replace(" ","")
            for x in range(10):
                s = s.replace(str(x),"")

            letters = Set()
            for x in s:
                letters.add(x)
        self._letters = Set(letters)

    @cached_method
    def letters(self):
        r"""
        """
        return set(self._letters)
        
    @cached_method
    def __repr__(self):
        r"""
        String representation

        EXAMPLES::

            sage: RegularLanguage("a*b", ['a', 'b'])
            Regular language: a*b over alphabet ['a', 'b']
        """
        s = self._regex
        s = s.replace("*","")
        s = s.replace("^_star","*")
        s = s.replace("1e",'1')
        return "Regular language: %s over alphabet %s" % (s, self._letters)
        
    def __iter__(self):
        r"""
        Return an iterator of the language.
        
        NOTE::
         
            Exponential complexity. TODO: improve it.
        
        EXAMPLES::
        
            sage: L = RegularLanguage("(a*b)^_star",["a","b"])
            sage: it = iter(L)
            sage: for _ in range(6): next(it)
            ''
            'ab'
            'abab'
            'ababab'
            'abababab'
            'ababababab'
        """
        letters = self._letters
        for n in itertools.count():
            for p in itertools.product(*(letters,)*n):
                if p in self:
                    yield join(p).replace(" ","")
        
    def __contains__(self, word):
        r"""
        Return whether word is in the language.
        
        EXAMPLES::
        
            sage: L = RegularLanguage("(a*b)^_star",["a","b"])
            sage: "ababababab" in L
            True
            sage: "abababaabab" in L
            False
            
        Other notation::
        
            sage: ("a","b") in L
            True
            sage: ["b","a"] in L
            False

        """
        return self.automaton().is_accepted(word)
    def __eq__(self, other):
        r"""
        Return wheter self is equal to other.

        INPUT:

        -  ``self`` -  regular language
        -  ``other`` -  regular language

        OUTPUT:

        boolean

        EXAMPLES::

            sage: R = RegularLanguage("a*b", ['a', 'b'])
            sage: S = RegularLanguage("b*a*a", ['a', 'b'])
            sage: R == S
            False
            
        ::
            
            sage: L = RegularLanguage("a+b+c",["a","b","c"])
            sage: L == L
            True
            sage: L2 = RegularLanguage("a+a+b+c",["a","b","c"])
            sage: L == L2
            True
            sage: L3 = RegularLanguage("a*a+a+b+c",["a","b","c"])
            sage: L == L3
            False

        """    
        R = (self-other)+(other-self)
        return R.is_empty()
        
    def is_empty(self):
        r"""
        Return wheter self is empty.

        INPUT:

        -  ``self`` -  regular language

        OUTPUT:

        boolean

        EXAMPLES::

            sage: R = RegularLanguage("a*b", ['a', 'b'])
            sage: R.is_empty()
            False
            sage: R2 = RegularLanguage("-((a+b)^_star)", ['a', 'b'])
            sage: R2.is_empty()
            True


        """    
        A = self.automaton()
        return not A.is_finite_state_reachable()

    def __mul__(self, other):
        r"""
        Return the concatenation of regular languages.

        INPUT:

        -  ``self`` -  regular language
        -  ``other`` -  regular language

        OUTPUT:

        RegularLanguage

        EXAMPLES::

            sage: R = RegularLanguage("a*b", ['a', 'b'])
            sage: S = RegularLanguage("b*a*a", ['a', 'b'])
            sage: R * S
            Regular language: (a*b*b*a*a) over alphabet set(['a', 'b'])

        """
        regex = "(%s*%s)" % (self._regex, other._regex)
        letters = self.letters() | other.letters()
        return RegularLanguage(regex, letters)

    def __add__(self, other):
        r"""
        Return the union of regular languages.

        INPUT:

        -  ``self`` -  regular language
        -  ``other`` -  regular language

        OUTPUT:

        RegularLanguage

        EXAMPLES::

            sage: R = RegularLanguage("a*b", ['a', 'b'])
            sage: S = RegularLanguage("b*a*a", ['a', 'b'])
            sage: R + S
            Regular language: (a*b+b*a*a) over alphabet set(['a', 'b'])

        """
        regex = "(%s+%s)" % (self._regex, other._regex)
        letters = self.letters() | other.letters()
        return RegularLanguage(regex, letters)
    
    def __sub__(self, other):
        r"""
        Difference symetric of self by other language.

        OUTPUT:

        RegularLanguage

        EXAMPLES::

            sage: L = RegularLanguage("(a*b)^_star", ['a', 'b']) 
            sage: R = RegularLanguage("a*b", ['a', 'b'])     
            sage: L-R
            Regular language: (((a*b)^_star)-(a*b)) over alphabet set(['a', 'b'])

        """
        regex = "((%s)-(%s))" % (self._regex, other._regex)
        letters = self.letters()
        return RegularLanguage(regex, letters)

    def __neg__(self):
        r"""
        Complement of self             

        OUTPUT:

        RegularLanguage

        EXAMPLES::

            sage: L = RegularLanguage("(a*b)^_star", ['a', 'b'])
            sage: -L
            Regular language: -(a*b)^_star over alphabet set(['a', 'b'])

        

        """
        regex = "-%s" % self._regex
        letters = self.letters()
        return RegularLanguage(regex, letters)

    def intersection(self, other):
        r"""
        Return the intersection of regular languages.

        INPUT:

        -  ``self`` -  regular language
        -  ``other`` -  regular language

        OUTPUT:

        RegularLanguage

        EXAMPLES::
            sage: L = RegularLanguage("(a*b)^_star", ['a', 'b']) 
            sage: R = RegularLanguage("a*b", ['a', 'b'])     
            sage: L.intersection(R)
            Regular language: ((a*b)^_star-(-a*b)) over alphabet set(['a', 'b'])
            

        """
        regex = "((%s)-(-(%s)))" % (self._regex, other._regex)
        letters = self.letters() | other.letters()
        return RegularLanguage(regex, letters)        

    def kleene_star(self):
        r"""
        Return the Kleen star of a regular language.

        OUTPUT:

        RegularLanguage

        EXAMPLES::

            sage: R = RegularLanguage("a*b", ['a', 'b'])
            sage: R.kleene_star()
            Regular language: (a*b)^_star over alphabet set(['a', 'b'])

        """
        regex = "(%s)^_star" % self._regex
        letters = self.letters()
        return RegularLanguage(regex, letters)

    def __pow__(self, exponent):
        r"""
        Return the Kleen star or the integer power of a regular language.

        INPUT:

        - ``exponent`` -- integer or variable x

        OUTPUT:

        RegularLanguage

        EXAMPLES::

            sage: R = RegularLanguage("a*b", ['a', 'b'])
            sage: R^_star
            Regular language: (a*b)^_star over alphabet set(['a', 'b'])
            sage: R^3
            Regular language: (a*b)^3 over alphabet set(['a', 'b'])

        """
        regex = "(%s)^%s" % (self._regex, exponent)
        letters = self.letters()
        return RegularLanguage(regex, letters)

    @cached_method
    def automaton(self):
        r"""
        Return an automaton of the regular language.

        OUTPUT :

        automaton

        EXAMPLES::

            sage: RegularLanguage("a*a",["a"]).automaton()
            Automaton of 4 states
            sage: RegularLanguage("a^_star",["a"]).automaton()
            Automaton of 2 states
            sage: RegularLanguage("a*b",["a","b"]).automaton()
            Automaton of 4 states
            sage: RegularLanguage("a+b",["a","b"]).automaton()
            Automaton of 4 states
            sage: RegularLanguage("a^5",["a"]).automaton()
            Automaton of 10 states
            sage: RegularLanguage("((a^5)+b*b)^_star",["a","b"]).automaton()
            Automaton of 14 states

        """
        if self._regex == "":
            return Automaton.from_empty_string(self.letters())        
        else:    
            D = {}
            for letter in self.letters():
                D[letter] = Automaton.from_letter(letter,alphabet=self.letters())
            D["_empty_word"] = Automaton.from_empty_string(self.letters())
            D["_star"] = var("_star")
            return sage_eval(self._regex, D)

    @cached_method
    def automaton_deterministic(self):
        r"""
        Return a deterministic automaton of the regular language.

        OUTPUT :

        automaton

        EXAMPLES::

            sage: RegularLanguage("a*a",["a"]).automaton_deterministic()
            Automaton of 4 states
            sage: RegularLanguage("a^_star",["a"]).automaton_deterministic()
            Automaton of 3 states
            sage: RegularLanguage("a*b",["a","b"]).automaton_deterministic()
            Automaton of 4 states
            sage: RegularLanguage("a+b",["a","b"]).automaton_deterministic()
            Automaton of 4 states
            sage: RegularLanguage("a^5",["a"]).automaton_deterministic()
            Automaton of 7 states
            sage: RegularLanguage("((a^5)+b*b)^_star",["a","b"]).automaton_deterministic()
            Automaton of 9 states

        """
        return self.automaton().deterministic_automaton(rename_states=True)

    @cached_method
    def automaton_minimal_deterministic(self, algorithm=None):
        r"""
        Return the minimal deterministic automaton of the regular language.
        INPUT:

        - ``algorithm`` -- None, or "Brzozowski" or "Moore"

        OUTPUT:

        automaton

        EXAMPLES::

            sage: RegularLanguage("a*a",["a"]).automaton_minimal_deterministic()
            Automaton of 4 states
            sage: RegularLanguage("a*b",["a","b"]).automaton_minimal_deterministic()
            Automaton of 4 states
            sage: RegularLanguage("a+b",["a","b"]).automaton_minimal_deterministic()
            Automaton of 3 states
            sage: RegularLanguage("a^5",["a"]).automaton_minimal_deterministic()
            Automaton of 7 states
            sage: RegularLanguage("((a^5)+b*b)^_star",["a","b"]).automaton_minimal_deterministic()
            Automaton of 7 states 
            sage: RegularLanguage("a^_star",["a"]).automaton_minimal_deterministic()
            Automaton of 1 states

        """
        return self.automaton().minimal_automaton(algorithm=algorithm)
  
    @cached_method
    def syntactic_semigroup(self):
        return TransitionSemiGroup(self.automaton_minimal_deterministic(),monoid=False)

    @cached_method
    def syntactic_monoid(self):
        return TransitionSemiGroup(self.automaton_minimal_deterministic())
  
    def view(self):
        self.syntactic_monoid().view()    
        self.automaton_minimal_deterministic().view()    

    def is_equation_satisfied(self, eq, variables, monoid=True, verbose=False):
        r"""
        EXAMPLES:

           

        """
        if monoid:
            return self.syntactic_monoid().is_equation_satisfied(eq,variables,verbose=verbose)
        else:                                        
            return self.syntactic_semigroup().is_equation_satisfied(eq,variables,verbose=verbose)
    def Variety_test(self,Variety= None):
        r"""
        EXAMPLES:

            sage: L = RegularLanguage("(a*b)^_star",['a','b'])
            sage: L.Variety_test()
            Language in A
            Language not in J
            Language not in COM
            Language not in G
            Language not in DA
           
        """
        V = {"A": ["(x)^wx=(x)^w",["x"]],"DA":["(xy)^wx(xy)^w=(xy)^w",["x","y"]],"G": ["(x)^w=1",["x"]], "COM":["xy=yx",["x","y"]],"J":["(xy)^w(yx)^w(xy)^w= (xy)^w",["x","y"]]}
        if (Variety):
            if (Variety in V):
                if (self.is_equation_satisfied(V[Variety][0],V[Variety][1])):
                    print "Language in "+i
                else:
                    print "Language not in "+i
            else:
                raise TypeError(Variety+" is not implemented")
        for i in V:
            if (self.is_equation_satisfied(V[i][0],V[i][1])):
                print "Language in "+i
            else:
                print "Language not in "+i
                   
