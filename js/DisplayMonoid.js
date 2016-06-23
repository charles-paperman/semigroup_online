var selectColor = "rgba(76, 175, 80, 0.75)";
function inputMonoid(obj,id)
{
    var menu = computableMenu();
    menu.holder.style.minWidth = "370px";
    menu.properties.inputtype = "Monoid";
    menu.holder.style.backgroundColor = colorinput;
    menu.properties.id = id;
    menu.allowSelection = true;
    drawMonoid(menu,obj,id);
    menu.obj = obj;
    menu.id = id;
    menu.sendRequest = function()
    {
        this.onthefly();
    }
    onTheFlyCheckbox(menu);
    ComputationMonoid(menu);
    
    return menu;
}
function ComputationMonoid(menu)
{
    var computation = verticalSlideMenu();
    computation.setAttribute("class","smallButton");
    computation.chooseLabel("Computations");    
    var rec = computation.addChoice("Recognized language");
    rec.menu = menu;
    rec.actionProperty = "RecognizedLanguage"
    rec.action = MenuAction;   
    rec.output = "automaton";
 
    var quotient = computation.addChoice("Quotient");
    quotient.menu = menu;
    quotient.actionProperty = "Quotient"
    quotient.action = MenuAction;   
    quotient.output = "monoid";
 
    var sub = computation.addChoice("Submonoid");
    sub.menu = menu;
    sub.actionProperty = "Submonoid"
    sub.action = MenuAction;   
    sub.output = "monoid";


    var algebra = computation.addChoice("Monoids varieties");
    algebra.menu = menu;
    algebra.actionProperty = "MembershipMonoids"
    algebra.action = MenuAction; 
    algebra.output = "image"; 

  
   
    menu.options.appendChild(computation);
     
}
function newMonoid()
{
  
    var menu = computableMenu();
    menu.allowSelection = true;
    menu.update= function (obj,id){
        this.input.innerHTML = "";
        this.id = id;
        this.obj = obj;
        drawMonoid(this,obj,id);
        var morphism = document.createElement("div");
        this.input.appendChild(morphism);
        morphism.innerHTML = "Morphism:<br>";
        morphism.style.margin = "10px";
        morphism.style.padding = "10px";
        morphism.style.borderLeft = "solid 1px grey";
        var input = document.createElement("textarea");
        var output = newAjaxObject();
        input.style.margin = "10px";
        output.holder.style.margin = "10px";
        input.output = output;
        output.properties.MonoidId = id;
        output.properties.inputtype = "Words";
        output.properties.Request = "WordImage";
        input.onkeyup = function()
        {   
            this.output.properties.description = this.value;
            this.output.sendRequest();
        }
        output.dealRequest = function (obj)
        {
            this.holder.innerHTML = '';

            Obj = JSON.parse(obj);
            this.holder.innerHTML = Obj.description;
            div = document.getElementById(this.properties.MonoidId+Obj.description);
            div.style.animation = "";
            div.offsetWidth = div.offsetWidth;
            //last line important for animation for some reason oO
            div.style.animation = "highlight 1.5s";
        }
        morphism.appendChild(input);
        morphism.appendChild(output.holder);
        
        PIajax = newAjaxObject();
        menu.input.appendChild(PIajax.holder);
        PIajax.holder.innerHTML =  "Compute the preimage of selected elements";
        PIajax.holder.setAttribute("class","smallButton");
        PIajax.holder.menu = this;
        PIajax.properties.MonoidId = id;
        PIajax.properties.inputtype = "Words";
        PIajax.properties.Request = "WordsPreImage"
        PIajax.holder.onclick = function()
        {
            s = "";
            for (x in this.menu.semigroup.selectedElements)
            {
                s += this.menu.semigroup.selectedElements[x].innerHTML+",";
            }
            this.ajaxObject.properties.description = s.slice(0,-1);
            this.ajaxObject.sendRequest();
        }
        PIajax.dealRequest = function(str)
        {
            var Obj = JSON.parse(str).description;
            var Aut = inputAutomaton();
            var canvas = newCanvas();
            canvas.attach(Aut);
            Aut.inputTransitions.value = Obj.automaton_desc.transitions.replace(/;/g,";\n");
            Aut.inputFinal.value = Obj.automaton_desc.final;
            Aut.inputInitial.value = Obj.automaton_desc.initial;
        }

     
    
            
    }

    return menu;
}
function drawMonoid(menu,obj,id)
{
    var max_depth = parseInt(obj.Jgraph.max_depth);        		            
    var div = document.createElement('div');
    div.style.display = "block";
    div.style.margin = "auto";
    menu.input.appendChild(div);
    menu.semigroup = div;
    var sgdraw = document.createElement('div');
    sgdraw.style.display="block";
    sgdraw.enable_selection = true;    
    div.Elements = [];     
    div.id = id;
    div.Idempotents = [];
    div.selectedElements = [];
    div.appendChild(sgdraw);     
    div.evaluate = function ()
    {
        s = "id="+this.id+"&selectedElements="         
        for (i in this.selectedElements)
        {
            s = s + this.selectedElements[i].value+",";
        }
        if (this.selectedElements.length>0)
        {
            s = s.substring(0,s.length-1)
        }
        return s;
    }
    if (menu.allowSelection)
    {
        menu.elements.push(div);
    }
    for (i = 0; i <= max_depth; i++)  		      	   
    {
      var eggbox = document.createElement('div');
      sgdraw.appendChild(eggbox);
      eggbox.style.margin = "20px";
      eggbox.setAttribute("align","center");       
      for (var j in obj.Jgraph.depth[i.toString()])
      {
            
           var u = obj["Jgraph"]["depth"][i.toString()][j]
           var box =  document.createElement('table');
           box.setAttribute("class","dclass");       
           box.setAttribute("cellspacing","10px");      
           box.setAttribute("cellpadding","10px");      
           box.setAttribute("id","dclass"+u);   
           var tbox = document.createElement('tbody');
           box.appendChild(tbox);
           eggbox.appendChild(box);   
           for (var k in obj["box"][u])
           {
                var L = obj["box"][u][k]
                var tr =  document.createElement('tr');
                tbox.appendChild(tr)
                for (var l in obj["box"][u][k])
                {
                    var td =  document.createElement('td');
                   td.setAttribute("class","hclass");       
                   td.setAttribute("align","center");      
                   td["selected"]= false;  
                   tr.appendChild(td);
                    for (var n in obj["box"][u][k][l])
                    {
                        value = obj["box"][u][k][l][n];
                        var element =  document.createElement('div');
                        div.Elements.push(element);
                        element.setAttribute("id",id+value);
                        element.setAttribute("class","element");
                        element.value = value;
                        element.Hclass = td;
                        element.isSelected = false;
                        if (obj["idempotents"].indexOf(obj["box"][u][k][l][n])>-1)
                        {
                            element.idempotent = true;
                            div.Idempotents.push(element);
                            element.style.color = "red";
                        }
                        else 
                        {
                            element.idempotent = false;
                            element.style.color = "black";
                        }   
                        element.holder = div;
                        element.menu = menu;
                        if (menu.allowSelection)
                        { 
                            element.onclick = function () { 
                                if (!this.is_selected)
                                {
                                    this.style.backgroundColor = selectColor;
                                    this.holder.selectedElements.push(this);
                                }
                                else
                                {
                                    this.style.backgroundColor = "";
                                    var index = this.holder.selectedElements.indexOf(this) 
                                    this.holder.selectedElements.splice(index,1);

                                }
                                this.is_selected = !this.is_selected;
//                                if (this.menu.onTheFly.checked)
//                                {
//                                    this.menu.sendRequest();
//                                }
                            };
                        }
                        element.textContent = obj["box"][u][k][l][n];
                        td.appendChild(element);
                        
                        element.select = function() {
                            toggleselect(this);                         
                            }; 
                      

                    }
                }
           }                    
      }
    }
}


