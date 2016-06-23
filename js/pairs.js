function newPair()
{
    var menu = computableMenu();
     menu.update = function(obj)
    {
        menu.input.innerHTML = "";
        var tight = document.createElement("div");
        tight.style.whiteSpace = "normal";
        tight.style.maxWidth = "500px";
        tight.style.margin = "10px";
        menu.input.appendChild(tight);
        if (obj.tight == "True")
        {
             tight.innerHTML = "The monoid is <b>tight</b>. The following are <b>all</b> the non-separability pairs of each half level of the dot-depth:";
        }
        if (obj.tight == "False")
        {
             tight.innerHTML = " The monoid is <b>not tight</b>. In green, <b>some</b> of the non-separability pairs of each half level of the dot-depth. In red, pairs whose status is unknown.";
        }            
        if (obj.tight == "TooBig")
        {
             tight.innerHTML = " The monoid was too big (size > 300) to be tested.";
        }          
        else
        {  
           var removeIdentity = document.createElement("div");
           removeIdentity.innerHTML = "Remove pairs in identity ";
           removeIdentity.style.margin = "10px";
           removeIdentity.style.textAlign = "right";           
           removeIdentity.value = true;
           tight.appendChild(removeIdentity);
           
           var checkbox = document.createElement("input")
           checkbox.type = "checkbox";
           checkbox.checked = false;
           removeIdentity.appendChild(checkbox);
           checkbox.to_hide = [];
           checkbox.toggle = function()
          {
              if (this.checked)
              {
                for (x in this.to_hide)
                {
                    this.to_hide[x].style.display="none";
                }
              }
              else
              {
                for (x in this.to_hide)
                {
                    this.to_hide[x].style.display="block";
                }
              }
          }; 
          checkbox.onchange = function() 
          {
              this.toggle(); 
          };
          
           var conflit = false; 
           if ("clash" in obj)
           {
               conflit = true;
            }
            
            for (var x in obj.Pairs)
            {
                var div = document.createElement("div");     
                var button = document.createElement("div");     
                var text = document.createElement("div");
                button.on = "Display pairs of level "+x;
                button.off = "Hide pairs of level "+x;
                button.innerHTML = button.on;
                button.setAttribute("class","smallButton");
                button.text = text
                text.style.marginLeft = "30px"
                text.style.maxHeight="400px";
                text.style.overflow = "auto";
                text.style.width = "200px";
                text.style.backgroundColor = okcolor;
                button.conflit = conflit;
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
                text.style.display = "none";
                menu.input.appendChild(div);
                div.appendChild(button)
                div.appendChild(text);
                for (var y in obj.Pairs[x]){
                    var s = document.createElement("div");
                    text.appendChild(s)
                    s.innerHTML = "("+obj.Pairs[x][y].left+","+obj.Pairs[x][y].right+")\n";
                    if (obj.Pairs[x][y].left == obj.Pairs[x][y].right)
                    {
                        checkbox.to_hide.push(s)
                    }

                    s.style.padding = "7px";
                    s.onmouseenter = function()
                    {
                        this.style.backgroundColor = "#e6fff5";
                    };
                    s.onmouseleave = function()
                    {
                        this.style.backgroundColor = "";
                    };

                }
                if (conflit)
                {
                    var textconf = document.createElement("div");
                    textconf.style.marginLeft = "30px"
                    textconf.style.maxHeight="400px";
                    textconf.style.overflow = "auto";
                    textconf.style.width = "200px";
                    textconf.style.display = "none";
                    textconf.style.backgroundColor = notokcolor;
                    button.textconf = textconf;
                    div.appendChild(textconf);
                    for (var y in obj.clash)
                    {
                        if (obj.clash[y].level == x)
                        {
                            var s = document.createElement("div");
                            textconf.appendChild(s)
                            s.innerHTML = "("+obj.clash[y].left+","+obj.clash[y].right+")\n";
                            if (obj.clash[y].left == obj.clash[y].right)
                            {
                                checkbox.to_hide.push(s)
                            }
                            s.style.padding = "7px";
                            s.onmouseenter = function()
                            {
                                this.style.backgroundColor = "#ffe6e6";
                            };
                            s.onmouseleave = function()
                            {
                                this.style.backgroundColor = "";
                            };
                        }
                    }
                }
            }
        }
    }
    return menu;
}
