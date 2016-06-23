var okcolor = "#ccffcc";
var notokcolor = "#ffccb3";
 var selectcolor = "#e5ffee";
//var colorinput = "rgba(255, 193, 7, 0.25)";
var rep = document.getElementById("rep");
var head = document.getElementById("head");
head.style.borderBottom = "solid 1px";
head.style.marginBottom = "10px";
var Title = document.createElement("div");
head.appendChild(Title);
Title.innerHTML = "Semigroup online";
Title.style.fontSize="xx-large";
Title.style.padding = "30px";
Title.style.textAlign = "center";
var inputReg = document.createElement("div");
inputReg.innerHTML = "Regular expression";
inputReg.setAttribute("class","mainButton");
var inputAut = document.createElement("div");
inputAut.innerHTML = "Automaton";
inputAut.setAttribute("class","mainButton");
var access = document.createElement("div");
access.innerHTML = "Access documents";
access.setAttribute("class","mainButton");
var documentation = document.createElement("div");
documentation.innerHTML = "Documentation";
documentation.setAttribute("class","mainButton");

var author = document.createElement("div");
author.innerHTML = '<div>by <a href="https://www.irif.univ-paris-diderot.fr/~paperman/"> Charles Paperman</a></div>';
author.setAttribute("class",'author');

head.appendChild(inputReg);
head.appendChild(inputAut);
head.appendChild(access);
head.appendChild(documentation);
head.appendChild(author);
inputReg.onclick = function()
{
    canvas = newCanvas();
    canvas.attach(inputRegularExpression());      
}
inputAut.onclick = function()
{
    canvas = newCanvas();
    canvas.attach(inputAutomaton());      
}
documentation.onclick = function()
{
   canvas = newCanvas();    
   doc = computableMenu();
   canvas.attach(doc);
   var xmlHttp = new XMLHttpRequest();
   xmlHttp.onreadystatechange = function() {
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
        {
           doc.input.innerHTML = xmlHttp.responseText;
        }
    };

    xmlHttp.open("GET", "doc.html", true); // true for asynchronous
    xmlHttp.send(null)
}
access.onclick = function()
{
    canvas = newCanvas();
    var div = computableMenu()
    canvas.attach(div);
    var button1 = document.createElement("div");
    button1.setAttribute("class","smallButton");
    button1.textContent = "Download sources";    
    var button2 = document.createElement("div");
    button2.setAttribute("class","smallButton");
    button2.textContent = "Download data";
    button2.onclick = function()
            {
                window.location = "data/pairs.tar.bz2"; 
            }

    div.input.appendChild(button1);
    div.input.appendChild(button2);
   
   var xmlHttp = new XMLHttpRequest();
   xmlHttp.onreadystatechange = function() {
        if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
        {
            button1.onclick = function()
            {
                window.location = "php_script/sources.tar.bz2";
            }

        }
    };

    xmlHttp.open("GET", "php_script/compress.php", true); // true for asynchronous
    xmlHttp.send(null)
}

function newCanvas()
{
    var canvas = document.createElement("div");
    canvas.style.display = "table";
    canvas.style.borderCollapse = "collapse";
    canvas.style.marginBottom = "10px";

    if (rep.children.length > 0)
    {
        rep.insertBefore(canvas,rep.children[0]);
    }
    else
    {
        rep.appendChild(canvas);
    }
        
    canvas.attach = function(obj)
    {
        this.appendChild(obj.holder);
        obj.canvas = this;
        obj.ondelete = function ()
        {
            obj.canvas.remove();
        }
    }
    return canvas;    
}

function MenuAction()
{  
    var menu = this.menu;
    var output = this.output;
    var request = this.actionProperty;
    if (this.output == "automaton")
    {
        object = newAutomaton();   
    }
    if (this.output == "image")
    {
        object = newImage();                            
    }
    if (this.output == "pairs")
    {
        object = newPair()
    }
    if (this.output == "monoid")
    {
        object = newMonoid();                            
        object.dealRequest = function(str){
            var obj = JSON.parse(str);            
            this.update(obj.description,obj.id);            
        }
    }    
    else
    {
        object.dealRequest = function(str){
            var obj = JSON.parse(str);            
            this.update(obj.description);            
        }

    } 
    object.dealError = function (str)
    {
        this.input.innerHTML = '<img src="image/error.svg" style="display:block;margin:auto;padding:10px"></img><div style="text-align:center">The server responses is uncorrect</div>'; 
    }
    object.title.innerHTML = this.innerHTML;
    object.properties.inputtype = menu.properties.inputtype;
    object.elements = menu.elements;
    if (menu.canvas.children.length == 1 )
    {
        object.holder.style.backgroundColor = "#E8EFEF";                        
        object.holder.dark = true;
    }
    else
    {
        object.holder.dark = !menu.canvas.children[1].dark; 
        if (!object.holder.dark) 
        {    
            object.holder.style.backgroundColor = "white";
        }
        else
        {                        
            object.holder.style.backgroundColor = "#E8EFEF";
        }
    }    
    object.properties.Request = request;
    object.menu = menu;
    object.refresh.style.display = "none";
    object.beforeSending = function ()
    {
        this.input.innerHTML = "";
        var wait = document.createElement("img");
        wait.src = "image/wait.gif"
        wait.style.display = "block";
        wait.style.marginLeft = "auto";
        wait.style.marginRight = "auto";
        wait.style.paddingTop = "40px";        
        this.input.appendChild(wait);
    }

    object.sendRequest();
    menu.canvas.insertBefore(object.holder,menu.canvas.children[1]);
    menu.flyingEvents.push(object);
    object.ondelete = function ()
    {
        this.menu.flyingEvents.splice(object,1);
    }
}
