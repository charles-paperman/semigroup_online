function newAjaxObject()
{
    var ajaxObject = {};
    var holder = document.createElement("div");
    ajaxObject.holder = holder;
    holder.ajaxObject = ajaxObject;
    ajaxObject.elements = [];
    ajaxObject.properties = {};
    
    ajaxObject.sendRequest = function()
    {
        this.beforeSending();
        var xmlhttp = new XMLHttpRequest();
        xmlhttp.obj = this;
        xmlhttp.onreadystatechange = function() 
        {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) 
            {      		            
          	    var rep =  xmlhttp.responseText;
          	    try 
          	    {
              	    this.obj.dealRequest(rep.trim());
          	    }
          	    catch(err)
          	    {
          	        this.obj.dealError(err)
          	    } 
                this.obj.onNextRequestDealt();
                this.obj.onNextRequestDealt = function (){};                
            }
         }                 
        s = "request.php?"+this.request();
        xmlhttp.open("GET", s, true);
        xmlhttp.send();	
    }
    ajaxObject.request =  function ()
    {
        var s = "";
        for (var x in this.elements)
        {
            s += "&"+this.elements[x].evaluate();
        }
        for (var x in this.properties)
        {
            s += "&"+x+"="+this.properties[x];
        }
        return s;
    }
    ajaxObject.dealRequest = function (str){    
    };    
    ajaxObject.dealError = function (str){    
    };    
    ajaxObject.beforeSending = function(){};
    ajaxObject.onNextRequestDealt = function (){};

    return ajaxObject;
}

function headOfObject(obj)
{
    var head = document.createElement("div");
    var close = document.createElement("div");
    head.appendChild(close);
    close.innerHTML = "&#x274C;";
    close.style.display = "inline-block";
    close.style.marginRight = "5px";
    close.style.cursor = "pointer";
    close.obj = obj;
    close.onclick = function()
    {
        this.obj.del();
    }
    
    obj.holder.appendChild(head);
    obj.head = head;
    obj.close = close;
    var refresh = document.createElement("img");
    head.appendChild(refresh);
    refresh.src = "image/refresh.png";
    refresh.style.cursor = "pointer";

    refresh.style.display = "inline-block";
    refresh.style.marginRight = "10px";
    refresh.style.marginTop = "2px";
    obj.refresh = refresh;
    refresh.obj = obj;
    refresh.width = "15";
    refresh.onclick = function()
    {
        this.obj.sendRequest();
    }
    
    var eye = document.createElement("img");
    head.appendChild(eye);
    eye.src = "image/eye.png";
    eye.style.cursor = "pointer";

    eye.style.display = "None";
    eye.style.marginTop = "4px";
    obj.exploreButton = eye;
    eye.obj = obj;
    eye.width = "20";
    eye.onclick = function()
    {
        this.obj.explore();
    }
    var title = document.createElement("div");
    head.appendChild(title);
    title.style.display = "inline-block";
    title.innerHTML = "";
    title.style.marginLeft = "8px";
    obj.title = title;
    
    obj.holder.appendChild(head);
    obj.head = head;
    
    head.setAttribute("class","computableMenuHead");
 
}
function bodyOfObject(obj)
{
    var body = document.createElement("div");
    var input = document.createElement("div");    
    var options = document.createElement("div");
    body.appendChild(input);   
    body.appendChild(options);   
    input.style.marginRight = "5px";
    input.style.padding = "5px";
    input.style.marginLeft = "-1px";

    options.style.padding = "5px";
    options.style.minHeight = "100px";

    options.style.paddingRight = "5px";
    obj.body = body;
    obj.input = input;
    obj.options = options;
    body.setAttribute("class","computableMenuBody");
    obj.holder.appendChild(body);
}
function footOfObject(obj)
{
    var foot = document.createElement("div");
    obj.foot = foot;
    foot.setAttribute("class","computableMenuFoot");
    obj.holder.appendChild(foot);
}
function computableMenu()
{   
    var menu = newAjaxObject();
    menu.holder.setAttribute("class","computableMenu");
    headOfObject(menu);
    bodyOfObject(menu);
    menu.flyingEvents = []
    menu.onthefly = function() 
    {
        for (var l in this.flyingEvents)
        {   
            this.flyingEvents[l].sendRequest();
        }
    };

    menu.del = function()
    {
        this.ondelete();
        this.holder.remove();
    }
    menu.reduce = function()
    {
        this.showsmall();
        this.onreduce();
    }    
    menu.unreduce = function()
    {
        this.showall();
        this.onunreduce();
    }
    menu.showsmall = function()
    {
       this.options.style.display = "none";       
    }
    menu.showHead = function()
    {
        this.head.stype.display = "";
    }
    menu.hideHead = function()
    {
        this.head.stype.display = "none";
    }
    
    menu.showall = function()
    {
        this.options.style.display = "inline-block";
    }
    menu.toggledHead = true;  
    menu.explore = function(){};    
    //Events declaration
    menu.ondelete = function(){};
    menu.onreduce = function(){};
    menu.onunreduce = function(){};    
    return menu;    
}
