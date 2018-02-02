(function (window, document, undefined) {
    'use strict';

    /**
     * BizFlow Angular Extension API<br>
     * Include [bizflowproject]/common/js/angular-ext.js and it will automatically initiate angular-ext extension.<br>
     * This extension contains common utility API.
     *
     * @class angularExt
     */
    function AngularExtension() {

        /**
         * Convert object to array.<br>
         * If given object is not array, then this function will return array having given object.<br/>
         * If given object is null, then this function will return empty array.
         * @param {object} obj The object to be converted to array
         * @returns {Array} Array object
         * @memberOf angularExt
         * @memberOfName angularExt.objectToArray
         * @example
         * var myArray = angularExt.objectToArray({id:1, key: 'name', value: 'peter'});
         * console.log(myArray);
         * @example
         * [ { id: 1, key: 'name', value: 'peter' } ]
         */
        this.objectToArray = function (obj) {
            if (obj) {
                if (!Array.isArray(obj)) {
                    var array = new Array();
                    array[0] = obj;
                    return array;
                } else {
                    return obj;
                }
            }

            return [];
        };

        /**
         * Convert object to map object with given key.
         * @param {string} obj
         * @param keyName
         * @returns {Array}
         * @memberOf angularExt
         * @memberOfName angularExt.objectToMap
         * @example
         * var myObject = {memberID: '0000001001', name: 'Peter', loginID: 'peter'};
         * console.log(angularExt.objectToMap(myObject, 'name'))
         * @example
         * [ Peter: { memberID: '0000001001', name: 'Peter', loginID: 'peter' } ]

         */
        this.objectToMap = function (obj, keyName) {
            var array = angularExt.objectToArray(obj);
            var map = new Array();
            for (var a = 0; a < array.length; a++) {
                var item = array[a];
                map[item[keyName]] = item;
            }

            return map;
        };
        /**
         * Check given object whether it is valid object or not
         * @param {object} obj
         * @returns {boolean} true if given object is valid, false if it is null or undefined
         * @see module:angularExt.isInvalidObject
         * @memberOf angularExt
         * @memberOfName angularExt.isValidObject
         * @example
         * var invalidObject1;
         * var invalidObject2 = null;
         * console.log(angularExt.isValidObject(invalidObject1));
         * console.log(angularExt.isValidObject(invalidObject2));
         * @example
         * false
         * false
         */
        this.isValidObject = function (obj) {
            return typeof obj !== 'undefined' && null != obj;
        };

        /**
         * Check given object whether it is valid object or not
         * @param {object} obj
         * @returns {boolean} true if given object is null or undefined, false if it is valid object
         * @see module:angularExt.isValidObject
         * @memberOf angularExt
         * @example
         * var invalidObject1;
         * var invalidObject2 = null;
         * console.log(angularExt.isInvalidObject(invalidObject1));
         * console.log(angularExt.isInvalidObject(invalidObject2));
         * @example
         * true
         * true

         */
        this.isInvalidObject = function (obj) {
            return typeof obj === 'undefined' || null == obj;
        };

        this.makeDate = function (date) {
            return angular.isDate(date) ? date : new Date(date);
        };

        /**
         * Make given string upper case
         * @param {string} str
         * @returns {*} Upper case string. If given string is not valid object, the given string will be returned without processing.
         * @memberOf angularExt
         * @memberOfName angularExt.toLowerCase
         */
        this.toLowerCase = function (str) {
            if (this.isValidObject(str)) {
                str = str.toLowerCase();
            }
            return str;
        };

        /**
         * Make given string lower case.
         * @param {string} str
         * @returns {*} Lowewr case string. If given string is not valid object, the given string will be returned without processing.
         * @memberOf angularExt
         * @memberOfName angularExt.toUpperCase
         */
        this.toUpperCase = function (str) {
            if (this.isValidObject(str)) {
                str = str.toUpperCase();
            }
            return str;
        };

        /**
         * Make safe HTML id.<br>
         * This function will replace (colon) :, (slash) / to (underscore) _.
         * @param {string} id ID string
         * @returns {string} Safe ID
         * @memberOf angularExt
         * @example
         * console.log(angularExt.makeSafeId("name-bizflow"));
         * console.log(angularExt.makeSafeId("name://bizflow"));
         * @example
         * name-bizflow
         * name___bizflow
         */

        this.makeSafeId = function (id) {
            if (id) {
                var safeId = id.replace(/[:\/]/g, '_');
                return safeId;
            }
            return id;
        };

        /**
         * Trim string
         * @param {string} stringObj
         * @returns {string} Trimmed string
         * @description This function will remove beginning/ending white spaces.
         * @memberOf angularExt
         * @memberOfName angularExt.trimStr
         */
        this.trimStr = function (stringObj) {
            if (typeof(stringObj) == 'string') {
                return stringObj.replace(/^\s+|\s+$/g, "");
            } else {
                return stringObj;
            }
        };

        this.trimStringBetweenKeys = function (string, start, end) {
            if (this.isValidObject(string) && typeof(string) === 'string')
            {
                var idx1 = -1;
                var idx2 = -1;

                if (this.isValidObject(start) && typeof(start) === 'string' && start.length > 0) {
                    idx1 = string.indexOf(start);
                }

                if (idx1 != -1 && this.isValidObject(end) && typeof(end) === 'string' && end.length > 0) {
                    idx2 = string.indexOf(end, idx1 + start.length);
                }

                if (-1 != idx1 && -1 != idx2) {
                    string = string.substring(0, idx1) + string.substring(idx2 + end.length);
                    string = this.trimStringBetweenKeys(string, start, end);
                }
            }
            return string;
        };

        /**
         * Return the value of given parameter from given URL.
         * @param {string} href URL
         * @param {string} name Parameter name
         * @returns {string} The value of given parameter.
         * @memberOf angularExt
         * @example
         * console.log(angularExt.getUrlParameter('http://host:3000/app?a=1&b=2&c=3', a));
         * console.log(angularExt.getUrlParameter('http://host:3000/app?a=1&b=2&c=3', b));
         * console.log(angularExt.getUrlParameter('http://host:3000/app?a=1&b=2&c=3', c));
         * @example
         * 1
         * 2
         * 3
         */
        this.getUrlParameter = function (href, name) {
            href = "" + href;
            var value = null;
            var key = "?" + name + "=";
            var idx = href.indexOf(key);
            if (-1 == idx) {
                key = "&" + name + "=";
                idx = href.indexOf(key);
            }

            if (-1 != idx) {
                var idx2 = href.indexOf("&", idx + key.length);
                if (-1 != idx2) {
                    value = href.substring(idx + key.length, idx2);
                } else {
                    value = href.substring(idx + key.length);
                }
            }
            return value;
        };

        /**
         * Make XML object with given XML string
         * @param {string} xmlString XML string
         * @returns {object} XML object
         * @memberOf angularExt
         * @example
         * var xmlString = '<?xml version="1.0" encoding="UTF-8"?><a id="123"><b>abc</b></a>';
         * var xmlObject = angularExt.stringToXML(xmlString);
         * console.log(xmlObject.childNodes[0].tagName);
         * console.log(xmlObject.childNodes[0].childNodes[0].tagName);
         * console.log(xmlObject.childNodes[0].attributes[0].name);
         * console.log(xmlObject.childNodes[0].attributes[0].value);
         * @example
         * a
         * b
         * id
         * 123
         */
        this.stringToXML = function (xmlString) {
            if (window.ActiveXObject) { //code for IE
                var oXML = new ActiveXObject("Microsoft.XMLDOM");
                oXML.loadXML(xmlString);
                return oXML;
            }
            else { // code for Chrome, Safari, Firefox, Opera, etc.
                return (new DOMParser()).parseFromString(xmlString, "text/xml");
            }
        };

        /**
         * Return true if the content of given parameter is a number.<br>
         * angular.isNumber will return false if the given value is "123" in string.<br>
         * But this function will check the content and will return true.<br>
         * If the given parameter is invalid object, then this function will return false.
         * @memberOf angularExt
         * @param {Number|String} value
         * @returns {boolean} true if given parameter is a number, otherwise false.
         * @example
         * console.log(angularExt.isNumber(123));
         * console.log(angularExt.isNumber('123'));
         * @example
         * true
         * true
         */
        this.isNumber = function (value) {
            var isNumber = false;
            if (angularExt.isValidObject(value) == true) {
                isNumber = angular.isNumber(value);
                if (!isNumber) {
                    isNumber = true;
                    var validChars = "0123456789.";
                    for (var i = 0; i < value.length && isNumber == true; i++) {
                        var char = value.charAt(i);
                        if (validChars.indexOf(char) == -1) {
                            isNumber = false;
                        }
                    }
                }
            }
            return isNumber;
        };

        /**
         * Return given string with given length.<br>
         * @param {string} sourceString
         * @param {number} length
         * @returns {string}
         * @memberOf angularExt
         * @example
         * console.log(angularExt.cutStringByLength('1234567890', 5));
         * @example
         * 12345
         */
        this.cutStringByLength = function (sourceString, length) {
            var strLength = 0;
            var cutString = "";
            var strPiece = "";

            for (var i = 0; i < sourceString.length; i++){
                var code = sourceString.charCodeAt(i);
                var ch = sourceString.substr(i, 1).toUpperCase();
                strPiece = sourceString.substr(i, 1);

                code = parseInt(code);

                if ((ch < "0" || ch > "9") && (ch < "A" || ch > "Z") && ((code > 255) || (code < 0))) {
                    strLength = strLength + 3;
                } else {
                    strLength = strLength + 1;
                }

                if (strLength > length) {
                    break;
                } else {
                    cutString = cutString + strPiece;
                }
            }
            return cutString;
        };

        if (this.isValidObject(navigator) && this.isValidObject(navigator.userAgent)) {
            var ua = navigator.userAgent;

            this.browser = {};

            /**
             * True if current browser is FireFox.
             * @memberOf angularExt
             */
            this.browser.IsFireFox = ua.indexOf('Firefox') != -1;

            /**
             * True if current browser is Opera.
             * @memberOf angularExt
             */
            this.browser.IsOpera = ua.indexOf('Opera') != -1;

            /**
             * True if current browser is Chrome.
             * @memberOf angularExt
             */
            this.browser.IsChrome = ua.indexOf('Chrome') != -1;

            /**
             * True if current browser is Safari.
             * @memberOf angularExt
             */
            this.browser.IsSafari = ua.indexOf('Safari') != -1 && !this.browser.IsChrome;

            /**
             * True if current browser is Webkit.
             * @memberOf angularExt
             */
            this.browser.IsWebkit = ua.indexOf('WebKit') != -1;

            /**
             * True if current browser is Internet Explorer.
             * @memberOf angularExt
             */
            this.browser.IsIE = ua.indexOf('Trident') > 0 || ua.indexOf('MSIE') > 0;

            /**
             * True if current browser is Internet Explorer 6.
             * @memberOf angularExt
             */
            this.browser.IsIE6 = ua.indexOf('MSIE 6') > 0;

            /**
             * True if current browser is Internet Explorer 7.
             * @memberOf angularExt
             */
            this.browser.IsIE7 = ua.indexOf('MSIE 7') > 0;

            /**
             * True if current browser is Internet Explorer 8.
             * @memberOf angularExt
             */
            this.browser.IsIE8 = ua.indexOf('MSIE 8') > 0;

            /**
             * True if current browser is Internet Explorer 9.
             * @memberOf angularExt
             */
            this.browser.IsIE9 = ua.indexOf('MSIE 9') > 0;

            /**
             * True if current browser is Internet Explorer 10.
             * @memberOf angularExt
             */
            this.browser.IsIE10 = ua.indexOf('MSIE 10') > 0;

            /**
             * True if current browser is Internet Explorer 8 or below.
             * @memberOf angularExt
             */
            this.browser.IsOldIE = this.browser.IsIE6 || this.browser.IsIE7 || this.browser.IsIE8;

            /**
             * True if current browser is Internet Explorer 11 or higher.
             * @memberOf angularExt
             */
            this.browser.IsIE11Up = ua.indexOf('MSIE') == -1 && ua.indexOf('Trident') > 0;

            /**
             * True if current browser is Internet Explorer 10 or higher.
             * @memberOf angularExt
             */
            this.browser.IsIE10Up = this.browser.IsIE10 || this.browser.IsIE11Up;

            /**
             * True if current browser is Internet Explorer 9 or higher.
             * @memberOf angularExt
             */
            this.browser.IsIE9Up = this.browser.IsIE9 || this.browser.IsIE10Up;
        }

    }

    var angularExt = window.angularExt || (window.angularExt = new AngularExtension());

})(window, document);

//
//*************************************** Etc **********************************************
//
if (!window.console) console = {
    log: function () {
    }
};

// for router error in IE
if (!String.prototype.startsWith) {
    String.prototype.startsWith = function(searchString, position) {
        position = position || 0;
        return this.indexOf(searchString, position) === position;
    };
}

var GLOBAL_CONSTANT = {
    'RESPONSE_LAG': {
        "enabled": true,
        "timeoutMin": 200,
        "timeoutMax": 1000
    }
};

function setResponseLagConfig(responseLagConfig, enabled, timeoutMin, timeoutMax) {
    // Enable or disable the module
    responseLagConfig.enabled = enabled;
    // Minimum response delay (default: 200)
    responseLagConfig.timeout.min = timeoutMin;
    // Maximum response delay (default: 1500)
    responseLagConfig.timeout.max = timeoutMax;
}

function setBlockUIConfig(blockUIConfig) {

    blockUIConfig.autoBlock = true;
    blockUIConfig.delay = 0;
    blockUIConfig.message = "Please Wait...";

    // Disable auto body block(This is important! if it's value is true then browser will be flickering on ie 9 and ie 10)
    blockUIConfig.autoInjectBodyBlock = false;
}
