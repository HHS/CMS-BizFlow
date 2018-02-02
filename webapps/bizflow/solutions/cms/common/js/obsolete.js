function makeContents(src) {
	var retObj = {};
	if( src.length > 0 ) {
		var tempObj = {};
		var i = 0, j = 0;
		var flags = [], tempArray = [];
		for( i = 0 ; i < src.length ; i++ ) {
			if( flags[src[i].STP_FLD_CD] ) {
				continue;
			}
			flags[src[i].STP_FLD_CD] = true;
			tempArray.push(src[i].STP_FLD_CD);
		}

		for( i = 0 ; i < src.length ; i++ ) {
			if( src[i].STP_FLD_CD != tempArray[j] ) {
				retObj[tempArray[j]] = tempObj;
				tempObj = {};
				j++;
			}
			tempObj[src[i]["CTT_CD"]] = src[i]["CTT"];
		}
		retObj[tempArray[j]] = tempObj;
	}
	return retObj;
}


function sortByKey(array, key) {
	return array.sort(function(a, b) {
		var x = a[key]; var y = b[key];
		return ((x < y) ? -1 : ((x > y) ? 1 : 0));
	});
}

function UniqueList(keyName) {
	this.list = new Array();
	this.map = new Array();

	this.getKeyValue = function (item) {
		var keyValue = keyName;
		if (Array.isArray(keyName)) {
			keyValue = "";
			for (var i = 0; i < keyName.length; i++) {
				keyValue += "{" + item[keyName[i]] + "}";
			}
		} else {
			keyValue = item[keyName];
		}

		return keyValue;
	};

	this.contain = function (item) {
		var keyValue = this.getKeyValue(item);
		return null != this.map[keyValue];
	};

	this.get = function (keyValue) {
		return this.map[keyValue];
	};

	this.getItem = function (item) {
		var keyValue = this.getKeyValue(item);
		return this.get(keyValue);
	};

	this.indexOf = function (item) {
		var thisObj = this;
		return this.list.map(function (o) {
			return thisObj.getKeyValue(o);
		}).indexOf(this.getKeyValue(item));
	};

	this.add = function (item) {
		var keyValue = this.getKeyValue(item);

		if (null == this.map[keyValue]) {
			this.map[keyValue] = item;
			this.list.push(item);
		}
	};

	this.updateOrAdd = function (item) {
		var idx = this.indexOf(item);
		if (idx >= 0) {
			var keyValue = this.getKeyValue(item);
			this.map[keyValue] = item;
			this.list[idx] = item;
		} else {
			this.add(item);
		}
	};

	this.remove = function (item) {
		var keyValue = this.getKeyValue(item);
		if (null != this.map[keyValue]) {
			this.map[keyValue] = null;
			try {
				delete this.map[keyValue];
			} catch (e) {
			}
			var idx = this.indexOf(item);
			if (-1 != idx) {
				this.list.splice(idx, 1);
			}
		}
	};

	this.size = function () {
		return this.list.length;
	};
}

function NameValueObject(name, value) {
	this.name = name;
	this.value = value;
}

// -- from angular-ext.js
//
// this.echo = function (msg) {
// 	alert(msg);
// };
// this.isArray = function (obj) {
// 	return Array.isArray(obj);
// };
// this.getDateStr = function (dateStr) {
// 	if (angular.isDate(dateStr)) {
// 		return dateStr;
// 	} else {
// 		return new Date(dateStr.replace(/(\d{2})\/(\d{2})\/(\d{4})/, "$2/$1/$3"));
// 	}
//};
// this.getElementPosition = function (element) {
// 	var position = new Object();
// 	position.x = 0;
// 	position.y = 0;
//
// 	while (element != null) {
// 		position.x += element.offsetLeft;
// 		position.y += element.offsetTop;
// 		element = element.offsetParent;
// 	}
//
// 	return position;
// };
// this.getElementPositionById = function (id) {
// 	var element = document.getElementById(id);
// 	return this.getElementPosition(element);
// };
// this.stringReplace = function (string, regex, value) {
// 	return string.replace(regex, value);
// };
// this.createObject = function (parentObject, objName) {
//     var obj = parentObject[objName];
//     if (this.isInvalidObject(obj)) {
//         parentObject[objName] = {};
//     }
//     return parentObject[objName];
// };
// this.setFocus = function (target) {
//     $(target).focus();
// };
// this.fireClick = function (target) {
//     $(target).click();
// };
// this.setCollapseToggleIcon = function (max, min) {
//     $('.collapse').on('shown.bs.collapse', function () {
//         $(this).parent().find("." + min).removeClass(min).addClass(max);
//     }).on('hidden.bs.collapse', function () {
//         $(this).parent().find("." + max).removeClass(max).addClass(min);
//     });
// };

Date.prototype.format = function (format, utc){
    return formatDate(this, format, utc);
};
function formatDate(date, format, utc){
    var MMMM = ["\x00", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    var MMM = ["\x01", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    var dddd = ["\x02", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    var ddd = ["\x03", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    function ii(i, len) { var s = i + ""; len = len || 2; while (s.length < len) s = "0" + s; return s; }

    var y = utc ? date.getUTCFullYear() : date.getFullYear();
    format = format.replace(/(^|[^\\])yyyy+/g, "$1" + y);
    format = format.replace(/(^|[^\\])yy/g, "$1" + y.toString().substr(2, 2));
    format = format.replace(/(^|[^\\])y/g, "$1" + y);

    var M = (utc ? date.getUTCMonth() : date.getMonth()) + 1;
    format = format.replace(/(^|[^\\])MMMM+/g, "$1" + MMMM[0]);
    format = format.replace(/(^|[^\\])MMM/g, "$1" + MMM[0]);
    format = format.replace(/(^|[^\\])MM/g, "$1" + ii(M));
    format = format.replace(/(^|[^\\])M/g, "$1" + M);

    var d = utc ? date.getUTCDate() : date.getDate();
    format = format.replace(/(^|[^\\])dddd+/g, "$1" + dddd[0]);
    format = format.replace(/(^|[^\\])ddd/g, "$1" + ddd[0]);
    format = format.replace(/(^|[^\\])dd/g, "$1" + ii(d));
    format = format.replace(/(^|[^\\])d/g, "$1" + d);

    var H = utc ? date.getUTCHours() : date.getHours();
    format = format.replace(/(^|[^\\])HH+/g, "$1" + ii(H));
    format = format.replace(/(^|[^\\])H/g, "$1" + H);

    var h = H > 12 ? H - 12 : H == 0 ? 12 : H;
    format = format.replace(/(^|[^\\])hh+/g, "$1" + ii(h));
    format = format.replace(/(^|[^\\])h/g, "$1" + h);

    var m = utc ? date.getUTCMinutes() : date.getMinutes();
    format = format.replace(/(^|[^\\])mm+/g, "$1" + ii(m));
    format = format.replace(/(^|[^\\])m/g, "$1" + m);

    var s = utc ? date.getUTCSeconds() : date.getSeconds();
    format = format.replace(/(^|[^\\])ss+/g, "$1" + ii(s));
    format = format.replace(/(^|[^\\])s/g, "$1" + s);

    var f = utc ? date.getUTCMilliseconds() : date.getMilliseconds();
    format = format.replace(/(^|[^\\])fff+/g, "$1" + ii(f, 3));
    f = Math.round(f / 10);
    format = format.replace(/(^|[^\\])ff/g, "$1" + ii(f));
    f = Math.round(f / 10);
    format = format.replace(/(^|[^\\])f/g, "$1" + f);

    var T = H < 12 ? "AM" : "PM";
    format = format.replace(/(^|[^\\])TT+/g, "$1" + T);
    format = format.replace(/(^|[^\\])T/g, "$1" + T.charAt(0));

    var t = T.toLowerCase();
    format = format.replace(/(^|[^\\])tt+/g, "$1" + t);
    format = format.replace(/(^|[^\\])t/g, "$1" + t.charAt(0));

    var tz = -date.getTimezoneOffset();
    var K = utc || !tz ? "Z" : tz > 0 ? "+" : "-";
    if (!utc)
    {
        tz = Math.abs(tz);
        var tzHrs = Math.floor(tz / 60);
        var tzMin = tz % 60;
        K += ii(tzHrs) + ":" + ii(tzMin);
    }
    format = format.replace(/(^|[^\\])K/g, "$1" + K);

    var day = (utc ? date.getUTCDay() : date.getDay()) + 1;
    format = format.replace(new RegExp(dddd[0], "g"), dddd[day]);
    format = format.replace(new RegExp(ddd[0], "g"), ddd[day]);

    format = format.replace(new RegExp(MMMM[0], "g"), MMMM[M]);
    format = format.replace(new RegExp(MMM[0], "g"), MMM[M]);

    format = format.replace(/\\(.)/g, "$1");

    return format;
}

//*************************************** URL Parameter **********************************************//
function UrlParameter(currentUrl) {
	this.paramObj = {};
	this.parseUrlParamValue = function () {
		var strIndex = currentUrl.indexOf('?');
		if (strIndex > 0) {
			var paramStr = currentUrl.substring(strIndex + 1).split('&');
			for (var i = 0; i < paramStr.length; i++) {
				if (paramStr[i].indexOf('#') > 0) {
					paramStr[i] = paramStr[i].split('#');
					paramStr[i] = paramStr[i][0];
				}
				var paramKeyVal = paramStr[i].split('=');
				this.paramObj[paramKeyVal[0]] = decodeURIComponent(paramKeyVal[1].replace(/\+/g, " "));
			}
		}
	};

	this.getParameterValue = function (paramKeyName) {
		var returnValue = this.paramObj[paramKeyName];
		if (returnValue == undefined) {
			returnValue = "";
		}
		return returnValue;
	};

	this.parseUrlParamValue();
}
