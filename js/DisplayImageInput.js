var svgNS = "http://www.w3.org/2000/svg";  

function newImage()
{
    var menu = computableMenu();
    menu.holder.onmouseenter = function(){};   
    menu.update = function(obj)
    {
        this.lastUpdate = obj;
        this.input.innerHTML = "";
        var image = document.createElement("img");
        image.setAttribute('class','imageStandard');        
        if ("url" in obj)
        {
        
            image.src = obj.url;
            this.input.appendChild(image);
            this.image = image;        
        }
        if ("ImagesList" in obj)
        {
            this.imagesList = []
            for (i in obj.ImagesList)
            {
                image.src = obj.ImagesList[i].url;
                this.input.appendChild(image);
                this.imagesList.push(image);                
                var image = document.createElement("img");
                image.setAttribute('class','imageStandard');            
            }
            image.remove();
        }
        this.onupdate();
    }
    menu.onupdate = function(){};

    return menu;
}
