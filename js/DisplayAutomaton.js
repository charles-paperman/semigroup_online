function newAutomaton()
{  
    menu = newImage()  
    menu.imageUpdate = menu.update;

    menu.update = function(obj)
    {    
        if ("url" in obj)
        {
            this.imageUpdate(obj);
            var button = document.createElement("div");     
            var text = document.createElement("div");
            button.on = "Display transitions";
            button.off = "Hide transitions";
            button.innerHTML = button.on;
            button.setAttribute("class","smallButton");
            button.text = text
            text.style.marginLeft = "30px"
            this.input.appendChild(button);
            this.input.appendChild(text);
            text.style.display = "none";
            text.innerHTML = obj.automaton_desc.transitions.replace(/;/g,";<br>");
             button.onclick = function ()
                {
                    if (this.text.style.display =="none")
                    {
                        this.text.style.display = "inline-block";
                        if (this.conflit)
                        {
                            this.textconf.style.display = "inline-block";
                        }
                        this.innerHTML = this.off;
                    }
                    else
                    {
                        this.text.style.display = "none";
                        if (this.conflit)
                        {
                            this.textconf.style.display = "none";
                        }
                        this.innerHTML = this.on;

                    }
                }
        }
        else
        {
            canvas = newCanvas();
            A = inputAutomaton()
            canvas.attach(A);      
            A.inputInitial.value = obj.Initials;
            A.inputFinal.value = obj.Finals;
            for (x in obj.Transitions)
            {
                A.inputTransitions.value += obj.Transitions[x]+"\n";
            }
            A.sendRequest();
        }
    }
    return menu;    
}
function inputAutomaton()
{ 
    var menu = computableMenu();
    var inputtext = document.createElement("div");
    inputtext.innerHTML = "Transitions:"
    var input = document.createElement("textarea");
    input.style.margin = "10px";
    input.cols = "40";
    input.rows = "10";
    input.style.backgroundColor = okcolor
    input.menu = menu;
    input.evaluate = function ()
    {
        return "description="+this.value;        
    };

    var inputtextInitial = document.createElement("div");
    inputtextInitial.innerHTML = "Initial states:"
    var inputInitial = document.createElement("textarea");
    inputInitial.style.margin = "10px";
    inputInitial.cols = "40";
    inputInitial.rows = "1";
    inputInitial.style.backgroundColor = okcolor
    inputInitial.menu = menu;
    inputInitial.evaluate = function ()
    {
        return "initial_states="+this.value;        
    };

    var inputtextFinal = document.createElement("div");
    inputtextFinal.innerHTML = "Final states:"
    var inputFinal = document.createElement("textarea");
    inputFinal.style.margin = "10px";
    inputFinal.cols = "40";
    inputFinal.rows = "1";
    inputFinal.style.backgroundColor = okcolor
    inputFinal.menu = menu;
    inputFinal.evaluate = function ()
    {
        return "final_states="+this.value;        
    };


    menu.childrenCount = 1;
    menu.inputTransitions = input;
    menu.inputFinal = inputFinal;
    menu.inputInitial = inputInitial;
    menu.getDescription = function()
    {
        return this.inputTransitions.value+"&"+this.inputInitial.evaluate()+"&"+this.inputFinal.evaluate()
    }
    menu.elements.push(input);
    menu.elements.push(inputInitial);
    menu.elements.push(inputFinal);
    menu.properties.inputtype = "Automata";
    menu.properties.Request = "isValid";

    input.old = "";
    inputInitial.old = "";
    inputFinal.old = "";
    input.onkeydown = function(event)
    {
        
        if (event.keyCode == 13 && this.menu.onTheFly.checked)
        {
            this.menu.sendRequest();
        }
        
    }
    inputInitial.onkeyup = function()
    {
        if (this.old != this.value && this.menu.onTheFly.checked)
        {
            this.old = this.value;
            this.menu.sendRequest();
        }
        
    }
    inputFinal.onkeyup = function()
    {
        if (this.old != this.value && this.menu.onTheFly.checked)
        {
            this.old = this.value;
            this.menu.sendRequest();
        }
        
    }
    menu.dealRequest = function (str) 
    {
        if (str == "false")
        {
            this.inputInitial.style.backgroundColor = notokcolor;
            this.inputFinal.style.backgroundColor = notokcolor;
            this.inputTransitions.style.backgroundColor = notokcolor;
        }
        else
        {
            obj = JSON.parse(str).description;
            this.automatonId = obj.id;
            this.inputInitial.style.backgroundColor = okcolor;
            this.inputFinal.style.backgroundColor = okcolor;
            this.inputTransitions.style.backgroundColor = okcolor;
            this.onthefly();
        }
    }
    alphabetTool(menu);
    onTheFlyCheckbox(menu);
    ComputationAut(menu);
    menu.input.appendChild(inputtext);
    menu.input.appendChild(input);
    menu.input.appendChild(inputtextInitial);
    menu.input.appendChild(inputInitial);
    menu.input.appendChild(inputtextFinal);
    menu.input.appendChild(inputFinal);

    menu.onreduce = function()
    {
        this.remaining.style.display = "none";
    }
    menu.onunreduce = function()
    {
      this.remaining.style.display = "inline-block";
    }    
    return menu;
}
function ComputationAut(menu)
{
    var computation = verticalSlideMenu();
    computation.setAttribute("class","smallButton");
    computation.chooseLabel("Computations");    
    var automata = computation.addChoice("Draw automaton");
    automata.menu = menu;
    automata.actionProperty = "Automaton"
    automata.action = MenuAction;   
    automata.output = "automaton";
    var automata = computation.addChoice("Minimal automaton");
    automata.menu = menu;
    automata.actionProperty = "MinimalAutomaton"
    automata.action = MenuAction;   
    automata.output = "automaton";

    var monoid = computation.addChoice("Transition monoid");
    monoid.menu = menu;
    monoid.actionProperty = "TransitionMonoid"
    monoid.action = MenuAction;   
    monoid.output = "monoid";
    var monoid = computation.addChoice("Syntactic monoid");
    monoid.menu = menu;
    monoid.actionProperty = "SyntacticMonoid"
    monoid.action = MenuAction;   
    monoid.output = "monoid";
    var order = computation.addChoice("Syntactic order");
    order.menu = menu;
    order.actionProperty = "SyntacticOrder"
    order.action = MenuAction;   
    order.output = "image";
    var pairs = computation.addChoice("Compute the Σ<SUB>k</SUB>-pairs of the transitions monoid");
    pairs.menu = menu;
    pairs.actionProperty = "ComputePairs"
    pairs.action = MenuAction;
    pairs.output = "pairs";       
    var membership = computation.addChoice("Test variety lattice of transitions monoid");
    membership.menu = menu;
    membership.actionProperty = "MembershipTransitionMonoid"
    membership.action = MenuAction;
    membership.output = "image";       

    menu.options.appendChild(computation);
}

