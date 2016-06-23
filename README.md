# semigroup_online    >    >
    >    >
Sage based online tool to compute algebraic properties of automata.    >    >
    >    >
    >    >
    >    >
--> README.md    >    > 
|    >    >
--> index.html    > : load js-script    >    >
|    >    >
--> doc.html    >   : contains the documentation of online tool    >    >
|    >    >
--> cpaut.spkg    > : not up-to-date sage package    >    > 
|    >    >
--> script    >    >: folder containing script executed on server side    >    >
    >|    >    >
    >--> automata.sage  :   contains description and routine for finite automata    >    > 
    >|    >    >
    >--> transition_semigroup.sage  :   code from finite automata to semigroups    >    >
    >|    >    >
    >--> regular_language.sage  :   code for regular expression to finite automata    >    >
    >|    >    >
    >--> server.py  :   contains a Python server. Will load sage and transmit request to tool.sage    >    >   
    >|    >    >
    >--> tool.sage  :   mostly deal with request and dispatch them to adequate library (mostly a mess)    >    >
    >|    >    >
    >--> sg_utils.sage  :  contains scripts about semigroups    >    > 
    >|    >    >
    >--> automata.utils  :  contains scripts about automata    >    > 
    >|    >    >
    >--> parse_utils.sage   :   contains script to syntactically deal with request transmited by server    >    >
    >|    >    >
    >--> parse_utils.sage   :   contains script to syntactically deal with request transmited by server    >    >
    >|    >    >
    >--> chaines.sage   :   contains script to compute chaines.    >    >
    >    >
--> js  :   folder containing js script    >    > 
    >|    >    >
    >--> Display.js    :    lauch main routine and static button    >    >
    >|    >    >
    >--> ajaxObject.js :    construct a class dedicated to AJAX-communication with server    >    >
    >|    >    >
    >--> DisplayMonoid.js : deal with monoid-type respond from the server    >    >
    >|    >    >    
    >--> DisplayRegularInput.js  : display regular expression input    >    > 
    >|    >    >
    >--> DisplayImageInput.js   : deal with image-type respond from the server    >    >
    >|    >    >
    >--> DisplayAutomaton.js    : deal with automata-type respond from the server    >    >
    >|    >    >
    >--> utils.js   :    contains js-small tool often used    >    >
    >|    >    >
    >--> pairs.js   :   deal with pairs-type respond from the server    >    >  
    >    >
    >    > 
--> php_script  :   forlder containing a php script that providing current sources of the tool    >    >
    >    >
--> image  :    contains the images use by js-script    >    >
    >    >
--> data  :    >folder containing datas use by server    >    > 
    >|    >    >
    >--> sage_obj   :    folder containing sage objects containing semigroup to avoid to recompute everything at every request    >    >
    >|    >    >
    >--> img    >   :    folder containing img produce by the server    >    >
    >|    >    >
    >--> pairs    > :    folder containing informations about pairs    >    >
    >    >    >
--> css : contains the css of the online page (its a mess)
