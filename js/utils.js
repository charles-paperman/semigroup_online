function alphabetTool(computableMenu){

    var alphabet = document.createElement("div");
    alphabet.style.margin = "10px";
    computableMenu.options.appendChild(alphabet);
    var alphabetlabel = document.createElement("div");
    alphabet.appendChild(alphabetlabel);
    alphabetlabel.innerHTML = "Alphabet:"
    alphabetlabel.style.display = "inline-block";
    alphabetlabel.style.marginTop = "20px";
    var tool = document.createElement("div");
    alphabet.appendChild(tool);
    alphabet.tool = tool;
    tool.alphabet = alphabet;
    alphabet.detect = true;
    tool.innerHTML = "autodetect";
    tool.style.backgroundColor="white";
    tool.style.color = "red";
    tool.style.margin = "10px";
    tool.style.padding = "10px";
    tool.style.minHeight="19px";
   
    tool.style.border = "solid 1px black";
    tool.style.display = "inline-block";
    tool.setAttribute("contenteditable","true");
    tool.onfocus = function ()
    {
        this.innerHTML = "";
    }
    tool.onblur = function()
    {
        s = this.textContent.replace(/\s/g,"");
        if (s == "")
        {
            this.innerHTML = "autodetect";
        }
        if (this.innerHTML == "autodetect")
        {
            this.style.color = "red";
            this.alphabet.detect = true;
        }
        else
        {
            this.style.color = "green";
            this.alphabet.detect = false;
        }
        
    };
    computableMenu.elements.push(alphabet);
    alphabet.evaluate = function()
    {
        s = this.tool.textContent.replace(/\s/g,"");
        if (!this.detect)
        {
            return "alphabet="+s;
        }
        else
        {
            return "";
        }
    }
}
function onTheFlyCheckbox(computableMenu)
{
    var cb = document.createElement("div");
    cb.style.margin = "10px";
    computableMenu.options.appendChild(cb);
    var cblabel = document.createElement("div");
    cb.appendChild(cblabel);
    cblabel.innerHTML = "Compute on the fly:"
    cblabel.style.display = "inline-block";
    cblabel.style.marginTop = "-1px";
    var tool = document.createElement("input");
    tool.type = "checkbox";
    tool.checked = "true";
    cb.appendChild(tool);
    cb.tool = tool;
    tool.cb = cb;
    computableMenu.onTheFly = tool;

}
function verticalSlideMenu()
{
    var slideMenu = document.createElement("div");
    slideMenu.setAttribute("class","slideHolder");
    slideMenu.style.transition = "height 0.25s";    
    slideMenu.style.height = "20px";      
    slideMenu.expandFactor = "20";
    slideMenu.onStartActive = function (){};
    slideMenu.onEndActive = function (){};    

    var label = document.createElement("div");
    slideMenu.appendChild(label);
    slideMenu.label = label;
    label.slideMenu = slideMenu;
    slideMenu.hideLabel = function(){
        this.label.style.display = "none";
    };
    slideMenu.showLabel = function(){
        this.label.style.display = "";
    };
    slideMenu.choices = [];
    slideMenu.chooseLabel = function(label)
    {
        this.label.innerHTML = label;
    }
    slideMenu.addChoice = function(label,action){        
        var choice = document.createElement("div");
        choice.innerHTML = label;
        choice.label = label;
        choice.setAttribute("class","slideChoice");
        choice.style.display = "none";
        choice.style.height = "20px";
        choice.slideMenu = this;
        choice.action = action;
        choice.onclick = function ()
        {
            this.action();
//            this.slideMenu.closeMenu();
        }
        this.appendChild(choice);   
        this.choices.push(choice);        
        return choice;        
    };    
    slideMenu.removeChoice = function(choice){        
        this.choices.splice(choice,1);
        choice.remove();           
    };    
    slideMenu.removeAllChoices = function(){        
        for (var x in this.choices)
        {
            this.choices[x].remove();
        }
        this.choices = []

    };    

    slideMenu.displayChoices = function()
    {
        this.removeEventListener("transitionend",this.displayChoices);      
        for (var i in this.choices)
        {
            this.choices[i].style.display = "block";
        }
    };
    slideMenu.hideChoices = function()
    {
        for (var i in this.choices)
        {
            this.choices[i].style.display = "none";
        }
        this.showLabel();
    };
    slideMenu.onmouseenter = function()
    {
        this.onStartActive();
        this.style.height = ((this.choices.length+1)*this.expandFactor).toString()+"px";
        this.addEventListener("transitionend",this.displayChoices);      
    };
    slideMenu.onmouseleave = function()
    {
        this.onEndActive();
        this.removeEventListener("transitionend",this.displayChoices);      
        this.style.height = "20px";
        this.hideChoices();                              
    };
    slideMenu.appendTo = function (element)
    {
        element.appendChild(this);
    }
    slideMenu.closeMenu = function(element)
    {
        this.onEndActive();
        this.onmouseenterOld = this.onmouseenter; 
        this.onmouseleaveOld = this.onmouseleave;
        this.onmouseenter = function () {};
        this.onmouseleave = function () {};
        this.removeEventListener("transitionend",this.displayChoices);      
        this.addEventListener("transitionend",this.restoremouse);      
        this.hideChoices();                              
        this.style.height = "20px";                
    }
    slideMenu.restoremouse = function() 
    { 
        this.onmouseenter = this.onmouseenterOld; 
        this.onmouseleave = this.onmouseleaveOld;
    }

    return slideMenu;
}

