function inputRegularExpression()
{ 
    var menu = computableMenu();
    menu.remaining = canvas.remaining;
    var inputtext = document.createElement("div");
    inputtext.innerHTML = "Regular expression:"
    var input = document.createElement("textarea");
    input.style.margin = "10px";
    input.cols = "40";
    input.style.backgroundColor = okcolor
    input.menu = menu;
    input.evaluate = function ()
    {
        return "description="+this.value;        
    };
    menu.childrenCount = 0;
    menu.inputRegularExpression = input;
    menu.elements.push(input);
    menu.properties.inputtype = "RegularExpression";
    menu.properties.Request = "isValid";
    input.old = "";
    input.onkeyup = function()
    {
        if (this.old != this.value && this.menu.onTheFly.checked)
        {
            input.old = input.value;
            this.menu.sendRequest();
        }
        
    }
    menu.dealRequest = function (str) 
    {
        if (str == "true")
        {
            this.inputRegularExpression.style.backgroundColor = okcolor;
            this.onthefly();
        }
        else
        {
            this.inputRegularExpression.style.backgroundColor = notokcolor;
        }
    }
    alphabetTool(menu);
    onTheFlyCheckbox(menu);
    ComputationReg(menu);
    menu.input.appendChild(inputtext);
    menu.input.appendChild(input);
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
function ComputationReg(menu)
{
    var computation = verticalSlideMenu();
    computation.setAttribute("class","smallButton");
    computation.chooseLabel("Computations");    
    var automata = computation.addChoice("Minimal automaton");
    automata.menu = menu;
    automata.actionProperty = "MinimalAutomaton"
    automata.action = MenuAction;   
    automata.output = "automaton";
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

    var pairs = computation.addChoice("Compute the Σ<SUB>k</SUB>-pairs of syntactic monoid");
    pairs.menu = menu;
    pairs.actionProperty = "ComputePairs"
    pairs.action = MenuAction;
    pairs.output = "pairs";       

    var membership = computation.addChoice("Test variety lattice of syntactic monoid");
    membership.menu = menu;
    membership.actionProperty = "MembershipMonoids"
    membership.action = MenuAction;
    membership.output = "image";       


 
  
    menu.options.appendChild(computation);
}

