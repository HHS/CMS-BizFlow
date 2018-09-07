/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project. 
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product. 
* For guidance on 'How do I override or clone Hyfinity webapp files such as CSS & javascript?', please read the following relevant FAQ entry: 
* http://www.hyfinity.net/faq/index/solution_id/1113
==================================================================================================== */

/**
 * combobox.js
 * Javascript functions to create a select box with editable entries
 *
 * Tested to work in IE6 and NS6.2
 *
 * company : hyfinity
 * @author Gerard Smyth
 */
 
 
/*
 *In order for this to work, the following global variables need to be setup for each drop down
 *
 *   var <select_box_name>_selectedIndex = <select_box_selected_index>;
 *   var <select_box_name>_changeCause = 'MANUAL_CLICK';
 *
 *The following event handlers also need to be initalised for each drop down
 *
 *   <drop_down>.onkeypress = comboBoxKeyPress;
 *   <drop_down>.onkeyup = comboBoxKeyUp;
 *   <drop_down>.onkeydown = comboBoxKeyDown;
 *   <drop_down>.onchange = comboBoxChange;
 *   <drop_down>.onmousedown = comboBoxMouseDown;
 *
 *Each entry in the drop down that you wish to be editable must have the following extra attributes
 *
 *   _editable = 'true'
 *   _initialValue = <default value first shown in the editable entry>
 *   
 */



function comboBoxChangeHandler(dropdown, keycode)
{

    var previousIndex = eval(dropdown.name+'_selectedIndex');
  
    eval(dropdown.name+'_selectedIndex = dropdown.selectedIndex;' );
    
    //alert("checking change cause "+eval(dropdown.name+'_changeCause'));
    //alert("old index: "+previousIndex+" new: "+eval(dropdown.name+'_selectedIndex'));
    //alert("editable: "+dropdown.options[previousIndex].getAttribute("_editable"));
        
 
    if ((dropdown.options[previousIndex].getAttribute("_editable") == "true") && (eval(dropdown.name+'_selectedIndex') != (-1)) && (eval(dropdown.name+'_changeCause') != 'MANUAL_CLICK'))     
    {
        //alert("recovering from automatic change");
        dropdown.options[previousIndex].selected = true;            
        eval(dropdown.name+'_selectedIndex = dropdown.selectedIndex;' );
        eval(dropdown.name+'_changeCause = "MANUAL_CLICK";');                     
    }
}





function comboBoxKeyPressHandler(dropdown, keycode)
{
    //check dropdown not empty
    if(dropdown.options.length != 0)
    {
        //alert(dropdown.options[dropdown.selectedIndex].name);
        
        
        if (dropdown.options[dropdown.selectedIndex].getAttribute("_editable") == 'true')        
        {
            /*if option is an Editable field  */
          
            var EditString = dropdown.options[dropdown.selectedIndex].text;    
            /* Contents of Editable Option */
            //alert(EditString);
            if (EditString == dropdown.options[dropdown.selectedIndex].getAttribute("_initialValue"))                            
                EditString = "";
            
            //alert(EditString);

            //check if backspace was pressed
            if ((keycode==8 || keycode==127)) 
            {
                EditString = EditString.substring(0,EditString.length-1); 
                /* Decrease length of string by one from right */
            }
            
            /* Check for allowable Characters  */                                    
            if ((keycode==46) || (keycode>47 && keycode<59)||(keycode>62 && keycode<127) ||(keycode==32))                 
            {
                EditString+=String.fromCharCode(keycode);                                                
            }
            
            /*Set new value of edited string into the Editable field */                
            dropdown.options[dropdown.selectedIndex].text = EditString;
            dropdown.options[dropdown.selectedIndex].value = EditString;
            return false;
        }
        return true;
    }
}


function comboBoxDelete(dropdown)
{
    if(dropdown.options.length != 0)
    {
        /*if dropdown is not empty*/
        if (dropdown.options[dropdown.selectedIndex].getAttribute("_editable") == 'true')             
        {
			dropdown.options[dropdown.selectedIndex].text = '';
        }
    }
}



function comboBoxKeyDown(e)
{
    //alert("keydown");
    var evt;
    var target;
    var keycode;    
    if (!e)
    {
        evt = window.event;
        target = window.event.srcElement;
        keycode = window.event.keyCode;
    }
    else
    {
        evt = e;
        target = e.target;
        keycode = e.which;
    }
    
    //alert(keycode);
    //alert(eval(target.name+'_changeCause'));
            
    if ((keycode == 38) || (keycode == 40))
        eval(target.name+'_changeCause = "MANUAL_CLICK";'); 
    else
        eval(target.name+'_changeCause = "AUTO_SYSTEM";');
        
    //alert(eval(target.name+'_changeCause'));
    /* if(keycode == 37)
    {
        fnLeftToRight(target);
    }
    if(keycode == 39)
    {
        fnRightToLeft(target);
    } */            
    if(keycode == 46)
    {
        comboBoxDelete(target);
    }
    if(keycode == 8 || keycode==127)
    {
        if (window.event)
            window.event.keyCode = '';
        return true;
    }
    /* if(keycode == 9)
    {
        fnLeftToRight(target);
    } */
    
    
}


function comboBoxKeyUp(e)
{
    //alert("keyup");
    return false; 
}

function comboBoxKeyPress(e)
{
    //alert("keypress");
    var evt;
    var target;
    var keycode;    
    if (!e)
    {
        evt = window.event;
        target = window.event.srcElement;
        keycode = window.event.keyCode;
    }
    else
    {
        evt = e;
        target = e.target;
        keycode = e.which;
    }
    
    //just ignore arrow key presses
    //alert(keycode);
    if ((keycode == 39) || (keycode == 37) || (keycode == 38) || (keycode == 40) || (keycode == 0))
    {
        return true;   
    }
    comboBoxKeyPressHandler(target, keycode);
}

function comboBoxChange(e)
{
    //alert("change");    
    var evt;
    var target;
    var keycode;    
    if (!e)
    {
        evt = window.event;
        target = window.event.srcElement;
        keycode = window.event.keyCode;
    }
    else
    {
        evt = e;
        target = e.target;
        keycode = e.which;
    }
    comboBoxChangeHandler(target, keycode);
}

function comboBoxMouseDown(e)
{
    var evt;
    var target;
    var keycode;    
    if (!e)
    {
        evt = window.event;
        target = window.event.srcElement;
        keycode = window.event.keyCode;
    }
    else
    {
        evt = e;
        target = e.target;
        keycode = e.which;
    }
    eval(target.name+'_changeCause = "MANUAL_CLICK";'); 
}
