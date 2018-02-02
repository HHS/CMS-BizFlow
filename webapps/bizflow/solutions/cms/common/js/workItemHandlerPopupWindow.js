var isForcedModal = true;

// GLOBAL variable for close work item modal popup
var workflowController = null;

function getModalPopupTop() {
    var _top = null;
    try {
        if (null != top && "undefined" != typeof(top)) {
            if ("undefined" != typeof(top.getUserClientType) && "undefined" != typeof(top.openModalPopupWindow)) {
                _top = top;
            } else if (null != top.opener && "undefined" != typeof(top.opener)) {
                if ("undefined" != typeof(top.opener.getUserClientType) && "undefined" != typeof(top.opener.openModalPopupWindow)) {
                    _top = top.opener;
                } else if (null != top.opener.top && "undefined" != typeof(top.opener.top)) {
                    if ("undefined" != typeof(top.opener.top.getUserClientType) && "undefined" != typeof(top.opener.top.openModalPopupWindow)) {
                        _top = top.opener.top;
                    }
                }
            }
        } else if (parent) {
            if (null != parent.top && "undefined" != typeof(parent.top)) {
                if (typeof(parent.top.getUserClientType) != "undefined" && "undefined" != typeof(parent.top.openModalPopupWindow)) {
                    _top = parent.top;
                } else if (null != parent.top.opener && "undefined" != typeof(parent.top.opener)) {
                    if ("undefined" != typeof(parent.top.opener.getUserClientType) && "undefined" != typeof(parent.top.opener.openModalPopupWindow)) {
                        _top = parent.top.opener;
                    } else if (null != parent.top.opener.top && "undefined" != typeof(parent.top.opener.top)) {
                        if ("undefined" != typeof(parent.top.opener.top.getUserClientType) && "undefined" != typeof(parent.top.opener.top.openModalPopupWindow)) {
                            _top = parent.top.opener.top;
                        }
                    }
                }
            }
        }

        if (null == _top) {
            if (top && "undefined" != typeof(top.WIH_information)) {
                _top = top.WIH_information;
            }
        }
    } catch (e) {
    }

    return _top;
}

function openWIHPopup(url, title, windowName, width, height, resizable, scrollbar, statusbar, toolbar, caller, sFeatures) {
    if (typeof(caller) == "undefined") {
        caller = this;
    }

    url = urlValueReplace(url, "_t", new Date().getTime());

    var windowOpen;
    /*if (isModalWIHMode()) */{
        this.focus();
        windowOpen = openNewWindow(caller, url, title, width, height, sFeatures);
    }
    /*    else {
     windowOpen = openNonPopup(url, windowName, width, height, resizable, scrollbar, statusbar, toolbar);
     if ((width == "100%" && height == "100%") || (width == window.screen.availWidth && height == window.screen.availHeight)) {
     maximizeWindow(windowOpen);
     }
     }*/
    return windowOpen;
}

// function _reviseFeatures(sFeatures, left, top)
// {
//     var features = parseFeatures(sFeatures);
//
//     sFeatures = features.string;
//     sFeatures = reviseFeatures(sFeatures, "left", left);
//     sFeatures = reviseFeatures(sFeatures, "top", top);
//
//     return sFeatures;
// }


// function openModalPopupWindowEx(caller, sURL, title, width, height, sFeatures, left, top)
// {
//     sFeatures = _reviseFeatures(sFeatures, left, top);
//     return openModalPopupWindow(caller, sURL, title, width, height, sFeatures);
// }

function _newWindowOpen(url, name, w, h, opt, left, top) {
    var l = screen.width / 2 - w / 2;
    var t = screen.height / 2 - h / 2;

    if ("undefined" != typeof(left) && null != left) {
        l = left;
    }

    if ("undefined" != typeof(top) && null != top) {
        t = top;
    }

    if (name) {
        name = name.replace(/ /g, "_");
        name = name.replace(/;/g, "");
        name = name.replace(/&/g, "");
    }

    var _win = window.open(url, name, "left=" + l + ",top=" + t + ",width=" + w + ",height=" + h + "," + opt);
    return _win;
}

function getModalTop() {
    try {
        if ("undefined" != typeof(top.openModalPopupWindow)) {
            return top;
        }
        else if (parent && "undefined" != typeof(parent.top.openModalPopupWindow)) {
            return parent.top;
        }
        else {
            if (top && "undefined" != typeof(top.WIH_information)) {
                return top.WIH_information;
            }
        }
    } catch (e) {

    }

    if ("undefined" != typeof(getModalPopupTop)) {
        return getModalPopupTop();
    } else {
        return null;
    }
}

function openNewWindow(caller, sURL, title, width, height, sFeatures, left, top, isForcedModal) {
    if (typeof isForcedModal == "undefined") {
        isForcedModal = false;
    }
    if (typeof sFeatures == "undefined") {
        sFeatures = "";
    }

    var _modalWin = null;
    var _top = getModalTop();

    if(null != _top && isForcedModal){	// force to modal popup
        _modalWin = _top.openModalPopupWindowEx(caller, sURL, title, width, height, sFeatures, left, top);
    }
    else {
        if (null != _top && true) {
            _modalWin = _top.openModalPopupWindowEx(caller, sURL, title, width, height, sFeatures, left, top);
        }
        else {
            _modalWin = _newWindowOpen(sURL, title, width, height, sFeatures);
        }
    }

    return _modalWin;
}

function urlValueReplace(url, name, value)
{
    var prefix = name + "=";
    var newUrl=url;

    var idx = url.indexOf("&" + prefix);
    if(-1 == idx)
    {
        idx = url.indexOf("?" + prefix);
        if(idx != -1)
        {
            prefix = "?" + prefix;
        }

    }else prefix = "&" + prefix;

    if(idx >= 0)
    {
        newUrl = url.substring(0, idx) + prefix + value;

        idx = url.indexOf("&", idx+prefix.length);
        if(idx >= 0)
        {
            newUrl += url.substring(idx);
        }
    }else
    {
        if(url.indexOf("?") != -1) newUrl += "&";
        else newUrl+= "?";

        newUrl += name + "=" + value;
    }

    return newUrl;
}

var openWorklist = function(proid, actseq, witemseq) {

    var iWidth = "99%";
    var iHeight = "99%";

    //http://coe1/bizflow/work/wih.jsp?sid=0000001001&pid=292&seq=102&asq=6&pro=100&rid=0&time=1481212941197&openpage=page&wihinfo=undefined&bizcovecall=y&isbizflow=n&currow=0&bizcoveid=1000022&_t=1481212941198
    //var sUrl = "/bizflow/work/wih.jsp?sid=" + "0000001001" + "&pid=" + proid + "&asq=" + actseq + "&seq=" + witemseq + "&mode=" + "complete" + "&openpage=page";
    var sUrl =  "/bizflow/work/wih.jsp?sid=0000001001&pid=" + proid + "&seq=" + witemseq + "&asq=" + actseq  + "&pro=F&rid=&time=" + new Date().getTime()
        + "&openpage=page&wihinfo=&bizcovecall=n&isbizflow=n&currow=&bizcoveid=";
    openWIHPopup(sUrl, "", "Complete", iWidth, iHeight, true, true, true, false);

    //return wndWIH;//It will make the parent window reload in ie.
};


// reloadPage is automatically called when workitem has some updates and closed.
var reloadPage = function(){
//need to implement in order to reload work list after workitem is closed

    //var grid = $(".k-grid.k-widget").data("kendoGrid");
    //if Kendo holds the latest transport, we can refresh with this way if we cannot have Triwest component Table Refresh
    //grid.dataSource.query();
    //alert("reloadPage!!! need to finish server side work first then call grid refresh");

};

var callbackCrmProviderUpdate = function(providerName, providerNpi){
    if(!!workflowController) {
        workflowController.callbackCrmProviderUpdate(providerName, providerNpi);
    }
};
