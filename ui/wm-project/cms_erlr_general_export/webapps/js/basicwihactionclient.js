/**
 * basicwihactionclient.js
 * @version 12.2
 */

/**
 * Returns the current BasicWIHAction object.
 * @return {BasicWIHAction}
 * @deprecated
 * @access private
 */
function getBasicWIHActionObject()
{
	try
	{
		if(top != self && top.parent && top.parent.getBasicWIHActionObject)
		{
			return top.parent.getBasicWIHActionObject();
		}
		else
	    {
	        //in case of a modal window mode, find WIH_action frame going up to parent frame
	        var obj = parent;
	        while(obj)
	        {
	            if (obj.frames && "undefined" != typeof(obj.frames) && top != obj)
	            {
	                if("undefined" != typeof(obj.getBasicWIHActionObject))
	                {
	                    return obj.getBasicWIHActionObject();
	                }
	                else
	                {
	                    obj = obj.parent;
	                }
	            }else
	            {
	                break;
	            }
	        }
		    return undefined;
	    }
	}
	catch(e)
	{
		if(window.console) console.log("WARN> " + e);
	}
}
/**
 * Returns the current WIHActionClient object.
 * @return {WIHActionClient}
 * @access private
 */
function getWIHActionClient()
{
	try
	{
		if(top != self && top.parent && top.parent.getWIHActionClient)
		{
			return top.parent.getWIHActionClient();
		}
		else
	    {
	        //in case of a modal window mode, find WIH_action frame going up to parent frame
	        var obj = parent;
	        while(obj)
	        {
	            if (obj.frames && "undefined" != typeof(obj.frames) && top != obj)
	            {
	                if("undefined" != typeof(obj.getWIHActionClient))
	                {
	                    return obj.getWIHActionClient();
	                }
	                else
	                {
	                    obj = obj.parent;
	                }
	            }else
	            {
	                break;
	            }
	        }
		    return undefined;
	    }
	}
	catch(e)
	{
		if(window.console) console.log("WARN> " + e);
	}
}

/**
 * Reserved variable for access to WIHActionClient object.
 * @type {WIHActionClient}
 */
var basicWIHActionClient = getWIHActionClient();