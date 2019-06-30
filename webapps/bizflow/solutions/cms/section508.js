(function (window) {

    
    var Section508 = function() {
        var _accessibilityOn = undefined;

        function getBizFlowModalPopupTop() {
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

        function isSection508User() {
            var top = getBizFlowModalPopupTop();
            if (top != null) {
                var workAreaFrame = top.document.getElementById("workAreaFrame");
                if (workAreaFrame != null) {
                    var doc = workAreaFrame.contentWindow.document || workAreaFrame.document;
                    if (doc != null) {
                        var imgs = doc.getElementsByTagName("img");
                        if (imgs != null) {
                            for (var i = 0; i < imgs.length; i++) {
                                var src = "" + imgs[i].src;
                                if (src.indexOf("icon_user_dis.gif") !== -1) {
                                    return true;
                                }
                            }
                        }
                    }
                }
            }

            return false;
        }
        
        
        return {
            isSection508User: isSection508User
        }
    }

    var _initializer = window.Section508 || (window.Section508 = Section508());
})(window);