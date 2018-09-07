/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on 'How do I override or clone Hyfinity webapp files such as CSS & javascript?', please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index/solution_id/1113
==================================================================================================== */

// ===================================================================
// Author: Matt Kruse <matt@mattkruse.com>
// WWW: http://www.mattkruse.com/
//
// Author: Hyfinity Limited
// www.hyfinity.com
//
// ===================================================================

// HISTORY
// ------------------------------------------------------------------
// June 2015 : Major rework by Hyfinity to provide better accessibility and
//              time support.  Some unused features removed.
//
// Feb 7, 2005: Fixed a CSS styles to use px unit
// March 29, 2004: Added check in select() method for the form field
//      being disabled. If it is, just return and don't do anything.
// March 24, 2004: Fixed bug - when month name and abbreviations were
//      changed, date format still used original values.
// January 26, 2004: Added support for drop-down month and year
//      navigation (Thanks to Chris Reid for the idea)
// September 22, 2003: Fixed a minor problem in YEAR calendar with
//      CSS prefix.
// August 19, 2003: Renamed the function to get styles, and made it
//      work correctly without an object reference
// August 18, 2003: Changed showYearNavigation and
//      showYearNavigationInput to optionally take an argument of
//      true or false
// July 31, 2003: Added text input option for year navigation.
//      Added a per-calendar CSS prefix option to optionally use
//      different styles for different calendars.
// July 29, 2003: Fixed bug causing the Today link to be clickable
//      even though today falls in a disabled date range.
//      Changed formatting to use pure CSS, allowing greater control
//      over look-and-feel options.
// June 11, 2003: Fixed bug causing the Today link to be unselectable
//      under certain cases when some days of week are disabled
// March 14, 2003: Added ability to disable individual dates or date
//      ranges, display as light gray and strike-through
// March 14, 2003: Removed dependency on graypixel.gif and instead
///     use table border coloring
// March 12, 2003: Modified showCalendar() function to allow optional
//      start-date parameter
// March 11, 2003: Modified select() function to allow optional
//      start-date parameter
/*
DESCRIPTION: This object implements a popup calendar to allow the user to
select a date, month, quarter, or year.

The calendar can be modified to work for any location in the world by
changing which weekday is displayed as the first column, changing the month
names, and changing the column headers for each day.

USAGE:


// Create a new CalendarPopup object of type DIV using the DIV named 'mydiv'
var cal = new CalendarPopup('mydiv');

// Set the type of date select to be used. By default it is 'date'. Supports date, datetime or time.
cal.setDisplayType(type);

// When a date or time is selected, a function is called and
// passed the details. You must write this function, and tell the calendar
// popup what the function name is.
// The function receives parameters for: year, month, day, hour, min, sec
// Depending on the type of calendar, the time or date params might be missing or null.
// The returned time information is always 24 hour format
cal.setReturnFunction(functionname);

// Show the calendar relative to a given anchor
cal.showCalendar(anchorname);

// Hide the calendar. The calendar is set to autoHide automatically
cal.hideCalendar();

// Set the month names to be used. Default are English month names
cal.setMonthNames("January","February","March",...);

// Set the month abbreviations to be used. Default are English month abbreviations
cal.setMonthAbbreviations("Jan","Feb","Mar",...);

// Show navigation for changing by the year, not just one month at a time
cal.showYearNavigation();

// Show month and year dropdowns, for quicker selection of month of dates
cal.showNavigationDropdowns();

// Set the text to be used above each day column. The days start with
// sunday regardless of the value of WeekStartDay
cal.setDayHeaders("S","M","T",...);

// Set the day for the first column in the calendar grid. By default this
// is Sunday (0) but it may be changed to fit the conventions of other
// countries.
cal.setWeekStartDay(1); // week is Monday - Sunday

// Set the weekdays which should be disabled in the 'date' select popup. You can
// then allow someone to only select week end dates, or Tuedays, for example
cal.setDisabledWeekDays(0,1); // To disable selecting the 1st or 2nd days of the week

// Selectively disable individual days or date ranges. Disabled days will not
// be clickable, and show as strike-through text on current browsers.
// Date format is any format recognized by parseDate() in date.js
// Pass a single date to disable:
cal.addDisabledDates("2003-01-01");
// Pass null as the first parameter to mean "anything up to and including" the
// passed date:
cal.addDisabledDates(null, "01/02/03");
// Pass null as the second parameter to mean "including the passed date and
// anything after it:
cal.addDisabledDates("Jan 01, 2003", null);
// Pass two dates to disable all dates inbetween and including the two
cal.addDisabledDates("January 01, 2003", "Dec 31, 2003");

// When the 'year' select is displayed, set the number of years back from the
// current year to start listing years. Default is 2.
// This is also used for year drop-down, to decide how many years +/- to display
cal.setYearSelectStartOffset(2);

// Text for the word "Today" appearing on the calendar
cal.setTodayText("Today");

// The calendar uses CSS classes for formatting. If you want your calendar to
// have unique styles, you can set the prefix that will be added to all the
// classes in the output.
// For example, normal output may have this:
//     <SPAN CLASS="cpTodayTextDisabled">Today<SPAN>
// But if you set the prefix like this:
cal.setCssPrefix("Test");
// The output will then look like:
//     <SPAN CLASS="TestcpTodayTextDisabled">Today<SPAN>
// And you can define that style somewhere in your page.

// When using Year navigation, you can make the year be an input box, so
// the user can manually change it and jump to any year
cal.showYearNavigationInput();


*/

// Quick fix for FF3
function CP_stop(e) {
    if (e) {
        e.cancelBubble = true;
        if (e.preventDefault)
            e.preventDefault();
        if (e.stopPropagation)
            e.stopPropagation();
    }
}

// CONSTRUCTOR for the CalendarPopup Object
function CalendarPopup(divName, calId) {
    var c = {};

    c.divName = divName;
    c.index = calId
    // Calendar-specific properties
    c.monthNames = new Array("January","February","March","April","May","June","July","August","September","October","November","December");
    c.monthAbbreviations = new Array("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
    c.dayHeaders = new Array("S","M","T","W","T","F","S");
    c.dayNames = new Array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
    c.returnFunction = "CP_tmpReturnFunction";
    c.returnMonthFunction = "CP_tmpReturnMonthFunction";
    c.returnQuarterFunction = "CP_tmpReturnQuarterFunction";
    c.returnYearFunction = "CP_tmpReturnYearFunction";
    c.weekStartDay = 0;
    c.isShowYearNavigation = false;
    c.displayType = "date";
    c.disabledWeekDays = new Object();
    c.disabledDatesExpression = "";
    c.yearSelectStartOffset = 2;
    c.currentDate = null;
    c.todayText="Today";
    c.cssPrefix="";
    c.isShowNavigationDropdowns=false;
    c.isShowYearNavigationInput=false;
    c.isShowSeconds=false;
    c.is12Hour=false;
    c.nowText="Now";
    c.selectText="Select";
    c.timeText = 'Time:';
    c.timeNames = ['Hours', 'Minutes', 'Seconds'];
    // Method mappings
    c.copyMonthNamesToWindow = CP_copyMonthNamesToWindow;
    c.setReturnFunction = CP_setReturnFunction;
    c.setMonthNames = CP_setMonthNames;
    c.setMonthAbbreviations = CP_setMonthAbbreviations;
    c.setDayHeaders = CP_setDayHeaders;
    c.setDayNames = CP_setDayNames;
    c.setTimeNames = CP_setTimeNames;
    c.setWeekStartDay = CP_setWeekStartDay;
    c.setDisplayType = CP_setDisplayType;
    c.setDisabledWeekDays = CP_setDisabledWeekDays;
    c.addDisabledDates = CP_addDisabledDates;
    c.setYearSelectStartOffset = CP_setYearSelectStartOffset;
    c.setTodayText = CP_setTodayText;
    c.setNowText = CP_setNowText;
    c.setTimeText = CP_setTimeText;
    c.setSelectText = CP_setSelectText;
    c.showYearNavigation = CP_showYearNavigation;
    c.setCssPrefix = CP_setCssPrefix;
    c.showNavigationDropdowns = CP_showNavigationDropdowns;
    c.showYearNavigationInput = CP_showYearNavigationInput;
    c.showSeconds = CP_showSeconds;
    c.set12HourMode = CP_set12HourMode;

    c.showCalendar = CP_showCalendar;
    c.hideCalendar = CP_hideCalendar;
    c.refreshCalendar = CP_refreshCalendar;
    c.getCalendar = CP_getCalendar;
    c.getCalendarDateGridBody = CP_getCalendarDateGridBody;
    c.getTodayLink = CP_getTodayLink;

    c.initEvents = CP_initEvents;
    c.releaseEvents = CP_releaseEvents;



    c.copyMonthNamesToWindow();
    // Return the object
    return c;
    }
function CP_copyMonthNamesToWindow() {
    // Copy these values over to the date.js
    if (typeof(window.MONTH_NAMES)!="undefined" && window.MONTH_NAMES!=null) {
        window.MONTH_NAMES = new Array();
        for (var i=0; i<this.monthNames.length; i++) {
            window.MONTH_NAMES[window.MONTH_NAMES.length] = this.monthNames[i];
        }
        for (var i=0; i<this.monthAbbreviations.length; i++) {
            window.MONTH_NAMES[window.MONTH_NAMES.length] = this.monthAbbreviations[i];
        }
    }
}
// Temporary default functions to be called when items clicked, so no error is thrown
function CP_tmpReturnFunction(y,m,d) {
    alert('Use setReturnFunction() to define which function will get the clicked results!');
    }

// Set the name of the functions to call to get the clicked item
function CP_setReturnFunction(name) { this.returnFunction = name; }

// Over-ride the built-in month names
function CP_setMonthNames() {
    for (var i=0; i<arguments.length; i++) { this.monthNames[i] = arguments[i]; }
    this.copyMonthNamesToWindow();
    }

// Over-ride the built-in month abbreviations
function CP_setMonthAbbreviations() {
    for (var i=0; i<arguments.length; i++) { this.monthAbbreviations[i] = arguments[i]; }
    this.copyMonthNamesToWindow();
    }

// Over-ride the built-in column headers for each day
function CP_setDayHeaders() {
    for (var i=0; i<arguments.length; i++) { this.dayHeaders[i] = arguments[i]; }
    }
function CP_setDayNames() {
    for (var i=0; i<arguments.length; i++) { this.dayNames[i] = arguments[i]; }
    }

// Set the day of the week (0-7) that the calendar display starts on
// This is for countries other than the US whose calendar displays start on Monday(1), for example
function CP_setWeekStartDay(day) { this.weekStartDay = day; }

// Show next/last year navigation links
function CP_showYearNavigation() { this.isShowYearNavigation = (arguments.length>0)?arguments[0]:true; }

// Which type of calendar to display - date, datetime or time
function CP_setDisplayType(type) {
    this.displayType=type;
    }

// How many years back to start by default for year display
function CP_setYearSelectStartOffset(num) { this.yearSelectStartOffset=num; }

// Set which weekdays should not be clickable
function CP_setDisabledWeekDays() {
    this.disabledWeekDays = new Object();
    for (var i=0; i<arguments.length; i++) { this.disabledWeekDays[arguments[i]] = true; }
    }

// Disable individual dates or ranges
// Builds an internal logical test which is run via eval() for efficiency
function CP_addDisabledDates(start, end) {
    if (arguments.length==1) { end=start; }
    if (start==null && end==null) { return; }
    if (this.disabledDatesExpression!="") { this.disabledDatesExpression+= "||"; }
    if (start!=null) { start = parseDate(start); start=""+start.getFullYear()+LZ(start.getMonth()+1)+LZ(start.getDate());}
    if (end!=null) { end=parseDate(end); end=""+end.getFullYear()+LZ(end.getMonth()+1)+LZ(end.getDate());}
    if (start==null) { this.disabledDatesExpression+="(ds<="+end+")"; }
    else if (end  ==null) { this.disabledDatesExpression+="(ds>="+start+")"; }
    else { this.disabledDatesExpression+="(ds>="+start+"&&ds<="+end+")"; }
    }

// Set the text to use for the "Today" link
function CP_setTodayText(text) {
    this.todayText = text;
    }
// Set the text to use for the 'Select' button on a datetime or time calendar
function CP_setSelectText(text) { this.selectText = text; }
// Set the text to use for the 'Now' link on a datetime or time calendar
function CP_setNowText(text) { this.nowText = text; }
// Set the text to use for the 'Time:' label on a datetime or time calendar
function CP_setTimeText(text) { this.timeText = text; }

function CP_setTimeNames() {
    for (var i=0; i<arguments.length; i++) { this.timeNames[i] = arguments[i]; }
    }

// Set the prefix to be added to all CSS classes when writing output
function CP_setCssPrefix(val) {
    this.cssPrefix = val;
    }

// Show the navigation as an dropdowns that can be manually changed
function CP_showNavigationDropdowns() { this.isShowNavigationDropdowns = (arguments.length>0)?arguments[0]:true; }

// Show the year navigation as an input box that can be manually changed
function CP_showYearNavigationInput() { this.isShowYearNavigationInput = (arguments.length>0)?arguments[0]:true; }

//show the seconds option on the time section if it is enabled
function CP_showSeconds() { this.isShowSeconds = (arguments.length>0)?arguments[0]:true; }

//sets whether the time section should be in 12 hour mode instead of the default 24 hour mode.
function CP_set12HourMode() { this.is12Hour = (arguments.length>0) ? arguments[0] : true; }

// Hide a calendar object
function CP_hideCalendar() {
    var calObject;
    if (arguments.length > 0) {
        calObject = hyf.calendar.config[arguments[0]].calendar;
    }
    else {
        calObject = this;
    }

    hyf.util.hideComponent(dojo.byId(calObject.divName));

    calObject.releaseEvents();

    if (calObject.sourceAnchor && dojo.byId(calObject.sourceAnchor))
    {
        setTimeout(function() {
                dojo.byId(calObject.sourceAnchor).focus();
                calObject.sourceAnchor = null;
        }, 5);
    }
    else
        calObject.sourceAnchor = null;
}

/**
 * Refresh the contents of the calendar display
 * @param newMonth (Optional) month number for the new month to show, starting from 1. 1 = jan, 2 = feb, etc
 *              Alterntiavely, this can contain one of the four strings 'LastMonth', 'NextMonth', 'LastYear', 'NextYear'
 * @param newYear (Optional) number of the new year to show
 */
function CP_refreshCalendar(index, newMonth, newYear) {
    //var calObject = window.popupWindowObjects[index];
    var calObject
    if (this !== window)
        calObject = this;
    else if (index)
        calObject = hyf.calendar.config[index].calendar;

    if ((typeof(newYear) != 'undefined') && (newYear != null))
    {
        calObject.currentDate.setFullYear(newYear)
    }
    if ((typeof(newMonth) != 'undefined') && (newMonth != null))
    {
        if (newMonth == 'LastMonth')
            calObject.currentDate.setMonth(calObject.currentDate.getMonth() - 1);
        else if (newMonth == 'NextMonth')
            calObject.currentDate.setMonth(calObject.currentDate.getMonth() + 1);
        else if (newMonth == 'LastYear')
            calObject.currentDate.setFullYear(calObject.currentDate.getFullYear() - 1);
        else if (newMonth == 'NextYear')
            calObject.currentDate.setFullYear(calObject.currentDate.getFullYear() + 1);
        else
            calObject.currentDate.setMonth(newMonth - 1)
    }


    require(["dojo/query", 'dojo/dom-construct', "dojo/NodeList-manipulate"], function(query, domConstruct) {

            //update the main date grid
            query("#cpCalGrid > tbody" ).forEach(domConstruct.empty);
            var newGridContents = calObject.getCalendarDateGridBody();
            query("#cpCalGrid > tbody" ).append(newGridContents);

            //update the heading information
            var month = calObject.currentDate.getMonth()+1;
            var year = calObject.currentDate.getFullYear();

            if (calObject.isShowNavigationDropdowns)
            {
                query('#cpMonthSelect').val(month);
                query('#cpYearSelect').val(year);
                //ensure correct year options in dropdown
                hyf.calendar.refreshYearDropDown(dojo.byId('cpYearSelect'), false);
            }
            else
            {
                if (calObject.isShowYearNavigation)
                {
                    query('#cpMonthSelect').text(calObject.monthNames[month-1]);

                    if (calObject.isShowYearNavigationInput)
                        query('#cpYearSelect').val(year);
                    else
                        query('#cpYearSelect').text(year);
                }
                else
                {
                    query('#cpMonthSelect').text(calObject.monthNames[month-1] + ' ' + year);
                }
            }

    });



}

/**
 * Populate the calendar and display it.
 * @param anchorname The ID of the anchor that the calendr has been triggered from.
 * @param initialDate (Optional) date string to use as the initial date value. (must be in y-M-d format)
 * @param initialtime (Optional) time string to use as the initial time value. (must be in 24 hour HH:mm:ss format)
 */
function CP_showCalendar(anchorname, initialDate, initialTime)
{
    this.currentDate = null;

    if ((typeof(initialDate) != 'undefined') && (initialDate != null))
        this.currentDate = parseDate(initialDate);

    if ((typeof(this.currentDate) == 'undefined') || (this.currentDate == null))
        this.currentDate = new Date();


    if ((typeof(initialTime) != 'undefined') && (initialTime != null))
    {
        var timeDate = new Date(getDateFromFormat(initialTime, 'HH:mm:ss'));

        this.currentDate.setHours(timeDate.getHours());
        this.currentDate.setMinutes(timeDate.getMinutes());
        this.currentDate.setSeconds(timeDate.getSeconds());
    }

    this.sourceAnchor = anchorname;

    document.getElementById(this.divName).innerHTML = this.getCalendar();

    var cal = this;

    require(["dijit/place"], function(place){
        place.around(dojo.byId(cal.divName), dojo.byId(anchorname), ["below-centered", "above-centered"], true);

        hyf.util.showComponent(dojo.byId(cal.divName));

        if ((cal.displayType == 'datetime') || (cal.displayType == 'date'))
            dojo.byId('cpCalGrid').focus();
        else
            dojo.query('#cpTimeEntry *[tabindex]')[0].focus();
    });

    this.initEvents();
}

/**
 * Global util function called when a date is selected on the calendar.
 * Depending on the type of calendar this may return the information directly,
 * or move on to the time section.
 * If the date details are not provided, then the calendars currentDate param will be used instead.
 * @param index The id of the relevant calendar.
 * @param year (Optional) The selected year.
 * @param month (Optional) The selected month.
 * @param day (Optional) The selected day.
 * @private
 */
function CP_dateSelected(index, year, month, day)
{

    var calObject = hyf.calendar.config[index].calendar;

    if (arguments.length == 1)
    {
        year = calObject.currentDate.getFullYear();
        month = calObject.currentDate.getMonth() + 1;
        day = calObject.currentDate.getDate();
    }

    //make sure the current date is allowed to be selected
    var disabled = false;
    if (calObject.disabledDatesExpression!="")
    {
        var ds = "" + year + LZ(month) + LZ(day);
        eval("disabled = ("+calObject.disabledDatesExpression+")");
    }

    if (disabled) //cant select this date so stop processing.
        return;

    if (calObject.displayType == 'date')
    {
        //need to return the info
        if (calObject.returnFunction)
        {
            eval(calObject.returnFunction + '(' + year + ', ' + month + ', ' + day + ')');
            calObject.hideCalendar();
        }
    }
    else
    {
        //make sure the current data object represents the selected date
        calObject.currentDate.setFullYear(year);
        calObject.currentDate.setMonth(month - 1);
        calObject.currentDate.setDate(day);

        //refresh calendar display for selected date, and focus on time controls
        calObject.refreshCalendar();

        dojo.query('#cpTimeEntry *[tabindex]')[0].focus();

    }
}

/**
 * Called when clicking now in a time calendar to set the dropdowns to the current time.
 * @param index The id of the relevant calendar.
 */
function CP_nowSelected(index)
{
    var calObject = hyf.calendar.config[index].calendar;
    var now = new Date();

    var setHour = nowHour = now.getHours();
    if (calObject.is12Hour)
    {
        setHour = CP_24To12Hour(setHour);
        if (nowHour > 12)
            dojo.byId('cpAMPM').value = 'PM';
        else
            dojo.byId('cpAMPM').value = 'AM';
    }

    dojo.byId('cpHours').value = LZ(setHour);
    dojo.byId('cpMinutes').value = LZ(now.getMinutes());
    if (calObject.isShowSeconds)
        dojo.byId('cpSeconds').value = LZ(now.getSeconds());

}

/**
 * Converts an hour value from a 24 hour clock
 * to the equivalent number for a 12 hour display.
 * eg 17 returns 5, 9 returns 9, 0 returns 12
 * @param hour 24 hour value
 * @return 12 hour value
 */
function CP_24To12Hour(hour)
{
    if (hour > 12)
        hour = hour - 12;
    if (hour == 0)
        hour = 12;

    return hour;
}

/**
 * Called when the 'select' button has been clicked from a time or datetime calendar.
 * This will not apply to a date only calendar.
 * This should return the required information to the return function, and close the calendar.
 * @param index The id of the relevant calendar.
 */
function CP_detailsConfirmed(index)
{
    var calObject = hyf.calendar.config[index].calendar;

    if (calObject.returnFunction)
    {

        var hours = dojo.byId('cpHours').value;
        var mins = dojo.byId('cpMinutes').value;
        var secs = null;
        if (calObject.isShowSeconds)
            secs = dojo.byId('cpSeconds').value;

        if (calObject.is12Hour)
        {
            if (dojo.byId('cpAMPM').value == 'PM')
            {
                if (hours != 12)
                    hours = Number(hours) + 12;
            }
            else
            {
                if (hours == 12)
                    hours = 0;
            }
        }

        if (calObject.displayType == 'datetime')
        {
            var year = calObject.currentDate.getFullYear();
            var month = calObject.currentDate.getMonth() + 1;
            var day = calObject.currentDate.getDate();

            //make sure the current date is allowed to be selected
            var disabled = false;
            if (calObject.disabledDatesExpression!="")
            {
                var ds = "" + year + LZ(month) + LZ(day);
                eval("disabled = ("+calObject.disabledDatesExpression+")");
            }

            if (disabled) //cant select this date so stop processing.
                return;

            eval(calObject.returnFunction + '(' + year + ', ' + month + ', ' + day + ', ' + hours + ', ' + mins + ', ' + secs + ')');
        }
        else
        {
            eval(calObject.returnFunction + '(null, null, null, ' + hours + ', ' + mins + ', ' + secs + ')');
        }

        calObject.hideCalendar();
    }
}

/**
 * Adds all the requried event handlers to the calendar display.
 * This should be called as sson as a new calendar has been created/shown.
 */
function CP_initEvents() {

    if (this.events != null)
        this.releaseEvents();

    var cal = this;

    this.events = {};

    this.events.docClick = hyf.attachEventHandler(document, 'mouseup', function(e) {

            if (!document.getElementById(cal.divName).contains(e.target)) {
                cal.hideCalendar();
            }
    });

    var calGrid = document.getElementById('cpCalGrid');
    var controls = dojo.query('#cpCalControls *[tabindex]', dojo.byId(cal.divName));
    var today = dojo.query('a.'+cal.cssPrefix+'cpTodayText', dojo.byId(cal.divName));
    var timeControls = dojo.query('.'+cal.cssPrefix+'cpTimeControls *[tabindex]', dojo.byId(cal.divName));
    var selectBtn = dojo.query('a.'+cal.cssPrefix+'cpSelectBtn', dojo.byId(cal.divName));

    //detect ESC any where on the calendar to close it
    this.events.calendarKeyDown = hyf.attachEventHandler(document.getElementById(cal.divName), 'keydown', function(e) {

            if (e.altKey) {
                return true;
            }

            switch(e.keyCode) {

                case dojo.keys.ESCAPE: {
                        cal.hideCalendar();
                        CP_stop(e);
                        return false;
                }
            }
            return true;

    });


    if (calGrid)
    {

        this.events.gridKeyDown = hyf.attachEventHandler(calGrid, 'keydown', function(e) {

                if (e.altKey) {
                    return true;
                }

                switch(e.keyCode) {
                    case dojo.keys.TAB: {

                            if (e.shiftKey) {
                                controls[controls.length - 1].focus();
                            }
                            else {
                                if (timeControls.length > 0)
                                {
                                    timeControls[0].focus();
                                }
                                else if (today.length > 0)
                                {
                                    today[0].focus();
                                }
                                else
                                {
                                    controls[0].focus();
                                }
                            }
                            CP_stop(e);
                            return false;
                    }
                    case dojo.keys.ENTER:
                    case dojo.keys.SPACE: {
                            CP_dateSelected(cal.index);
                            CP_stop(e);
                            return false;
                    };
                    case dojo.keys.LEFT_ARROW: {
                            cal.currentDate.setDate(cal.currentDate.getDate() - 1);
                            cal.refreshCalendar();
                            CP_stop(e);
                            return false;
                    }
                    case dojo.keys.RIGHT_ARROW: {
                            cal.currentDate.setDate(cal.currentDate.getDate() + 1);
                            cal.refreshCalendar();
                            CP_stop(e);
                            return false;
                    }
                    case dojo.keys.UP_ARROW: {
                            cal.currentDate.setDate(cal.currentDate.getDate() - 7);
                            cal.refreshCalendar();
                            CP_stop(e);
                            return false;
                    }
                    case dojo.keys.DOWN_ARROW: {
                            cal.currentDate.setDate(cal.currentDate.getDate() + 7);
                            cal.refreshCalendar();
                            CP_stop(e);
                            return false;
                    }
                    case dojo.keys.PAGE_UP: {
                            cal.currentDate.setMonth(cal.currentDate.getMonth() - 1);
                            cal.refreshCalendar();
                            CP_stop(e);
                            return false;
                    }
                    case dojo.keys.PAGE_DOWN: {
                            cal.currentDate.setMonth(cal.currentDate.getMonth() + 1);
                            cal.refreshCalendar();
                            CP_stop(e);
                            return false;
                    }
                }

                return true;
        });

        this.events.gridKeyPress = hyf.attachEventHandler(calGrid, 'keypress', function(e) {

                if (e.altKey) {
                    return true;
                }

                switch(e.keyCode) {
                    case dojo.keys.TAB:
                    case dojo.keys.ENTER:
                    case dojo.keys.SPACE:
                    case dojo.keys.LEFT_ARROW:
                    case dojo.keys.RIGHT_ARROW:
                    case dojo.keys.UP_ARROW:
                    case dojo.keys.DOWN_ARROW:
                    case dojo.keys.PAGE_UP:
                    case dojo.keys.PAGE_DOWN: {
                            CP_stop(e);
                            return false;
                    }
                }

                return true;

        });
    }

    if (controls.length > 0)
    {
        //make sure shift tab on first control goes back round to bottom of popup
        this.events.firstControlKeyDown = hyf.attachEventHandler(controls[0], 'keydown', function(e) {

                switch(e.keyCode) {
                    case dojo.keys.TAB: {

                            if (e.shiftKey) {

                                if (selectBtn.length > 0) //datetime calendar
                                {
                                    selectBtn[0].focus();
                                }
                                else if (today.length > 0) //standard date calendar
                                {
                                    today[0].focus();
                                }
                                else //date calendar with today disabled
                                {
                                    calGrid.focus();
                                }
                                CP_stop(e);
                                return false;
                            }

                    }
                }

                return true;
        });
    }


    //in date only mode, want today link to tab back round to first control
    if ((cal.displayType == 'date') && (today.length > 0))
    {
        this.events.todayKeyDown = hyf.attachEventHandler(today[0], 'keydown', function(e) {

                switch(e.keyCode) {
                    case dojo.keys.TAB: {

                            var firstControl = controls[0];

                            var grid = document.getElementById('cpCalGrid');

                            if (e.shiftKey) {
                                grid.focus();
                            }
                            else {
                                firstControl.focus();
                            }
                            CP_stop(e);
                            return false;
                    }
                }

                return true;
        });
    }

    //select button should tab back round to first cal or time control
    if (selectBtn.length > 0)
    {
        this.events.selectKeyDown = hyf.attachEventHandler(selectBtn[0], 'keydown', function(e) {

                switch(e.keyCode) {
                    case dojo.keys.TAB: {



                            if (!e.shiftKey) {

                                if (controls.length > 0) {
                                    controls[0].focus();
                                }
                                else if (timeControls.length > 0) {
                                    timeControls[0].focus();
                                }

                                CP_stop(e);
                                return false;
                            }
                    }
                }

                return true;
        });
    }


    if (timeControls.length > 0)
    {
        this.events.firstTimeControlKeyDown = hyf.attachEventHandler(timeControls[0], 'keydown', function(e) {

                switch(e.keyCode) {
                    case dojo.keys.TAB: {

                            if (e.shiftKey) {

                                if (cal.displayType == 'datetime') {
                                    calGrid.focus();
                                }
                                else {
                                    selectBtn[0].focus();
                                }
                                CP_stop(e);
                                return false;
                            }
                    }
                }

                return true;
        });
    }

}

/**
 * remove any events handlers added to the calendar.
 * This will be called on hide.
 */
function CP_releaseEvents()
{
    if (this.events != null)
    {
        for (ev in this.events)
        {
            hyf.detachEventHandler(this.events[ev]);
        }

        this.events = null;
    }
}


// Return a string containing all the calendar code to be displayed
// This should be called once to get the initial HTMl to display.
// Any future updates should be done via the refresh method above.
function CP_getCalendar()
{
    var result = '<TABLE CLASS="'+this.cssPrefix+'cpBorder cpType-' + this.displayType + '" WIDTH=144 BORDER=1 BORDERWIDTH=1 CELLSPACING=0 CELLPADDING=1>\n';
    result += '<TR><TD ALIGN=CENTER>\n';
    result += '<CENTER>\n';

    // Code for DATE display (default)
    // -------------------------------
    if (this.displayType=="date" || this.displayType=="datetime") {
        if (this.currentDate==null) { this.currentDate = new Date(); }

        var month = this.currentDate.getMonth()+1;
        var year = this.currentDate.getFullYear();

        //calendar header + controls
        result += '<TABLE id="cpCalControls" WIDTH=144 BORDER=0 BORDERWIDTH=0 CELLSPACING=0 CELLPADDING=0>';
        result += '<TR>\n';
        var refresh = 'CP_refreshCalendar';
        var refreshLink = 'javascript:' + refresh;
        if (this.isShowNavigationDropdowns) {
            result += '<TD CLASS="'+this.cssPrefix+'cpMonthNavigation" WIDTH="78" COLSPAN="3"><select id="cpMonthSelect" tabindex="0" CLASS="'+this.cssPrefix+'cpMonthNavigation" name="cpMonth" onmouseup="CP_stop(event)" onChange="'+refresh+'(\''+this.index+'\',this.options[this.selectedIndex].value-0);">';
            for( var monthCounter=1; monthCounter<=12; monthCounter++ ) {
                var selected = (monthCounter==month) ? 'SELECTED' : '';
                result += '<option value="'+monthCounter+'" '+selected+'>'+this.monthNames[monthCounter-1]+'</option>';
                }
            result += '</select></TD>';
            result += '<TD CLASS="'+this.cssPrefix+'cpMonthNavigation" WIDTH="10">&nbsp;</TD>';

            result += '<TD CLASS="'+this.cssPrefix+'cpYearNavigation" WIDTH="56" COLSPAN="3"><select id="cpYearSelect" tabindex="0" CLASS="'+this.cssPrefix+'cpYearNavigation" name="cpYear" onmouseup="CP_stop(event)" onChange="'+refresh+'(\''+this.index+'\',null ,this.options[this.selectedIndex].value-0);">';
            for( var yearCounter=year-this.yearSelectStartOffset; yearCounter<=year+this.yearSelectStartOffset; yearCounter++ ) {
                var selected = (yearCounter==year) ? 'SELECTED' : '';
                result += '<option value="'+yearCounter+'" '+selected+'>'+yearCounter+'</option>';
                }
            result += '</select></TD>';
            }
        else {
            if (this.isShowYearNavigation) {
                result += '<TD CLASS="'+this.cssPrefix+'cpMonthNavigation" WIDTH="10"><A CLASS="'+this.cssPrefix+'cpMonthNavigation" HREF="'+refreshLink+'(\''+this.index+'\', \'LastMonth\');" tabindex="0">&lt;</A></TD>';
                result += '<TD CLASS="'+this.cssPrefix+'cpMonthNavigation" WIDTH="75"><SPAN id="cpMonthSelect" CLASS="'+this.cssPrefix+'cpMonthNavigation">'+this.monthNames[month-1]+'</SPAN></TD>';
                result += '<TD CLASS="'+this.cssPrefix+'cpMonthNavigation" WIDTH="10"><A CLASS="'+this.cssPrefix+'cpMonthNavigation" HREF="'+refreshLink+'(\''+this.index+'\', \'NextMonth\');" tabindex="0">&gt;</A></TD>';
                result += '<TD CLASS="'+this.cssPrefix+'cpMonthNavigation" WIDTH="10">&nbsp;</TD>';

                result += '<TD CLASS="'+this.cssPrefix+'cpYearNavigation" WIDTH="10"><A CLASS="'+this.cssPrefix+'cpYearNavigation" HREF="'+refreshLink+'(\''+this.index+'\', \'LastYear\');" tabindex="0">&lt;</A></TD>';
                if (this.isShowYearNavigationInput) {
                    result += '<TD CLASS="'+this.cssPrefix+'cpYearNavigation" WIDTH="30"><INPUT id="cpYearSelect" NAME="cpYear" CLASS="'+this.cssPrefix+'cpYearNavigation" SIZE="4" MAXLENGTH="4" VALUE="'+year+'" onBlur="'+refresh+'(\''+this.index+'\',null,this.value-0);" tabindex="0"></TD>';
                    }
                else {
                    result += '<TD CLASS="'+this.cssPrefix+'cpYearNavigation" WIDTH="30"><SPAN id="cpYearSelect" CLASS="'+this.cssPrefix+'cpYearNavigation">'+year+'</SPAN></TD>';
                    }
                result += '<TD CLASS="'+this.cssPrefix+'cpYearNavigation" WIDTH="10"><A CLASS="'+this.cssPrefix+'cpYearNavigation" HREF="'+refreshLink+'(\''+this.index+'\', \'NextYear\');" tabindex="0">&gt;</A></TD>';
                }
            else {
                result += '<TD CLASS="'+this.cssPrefix+'cpMonthNavigation" WIDTH="22"><A CLASS="'+this.cssPrefix+'cpMonthNavigation" HREF="'+refreshLink+'(\''+this.index+'\', \'LastMonth\');" tabindex="0">&lt;&lt;</A></TD>\n';
                result += '<TD CLASS="'+this.cssPrefix+'cpMonthNavigation" WIDTH="100"><SPAN id="cpMonthSelect" CLASS="'+this.cssPrefix+'cpMonthNavigation">'+this.monthNames[month-1]+' '+year+'</SPAN></TD>\n';
                result += '<TD CLASS="'+this.cssPrefix+'cpMonthNavigation" WIDTH="22"><A CLASS="'+this.cssPrefix+'cpMonthNavigation" HREF="'+refreshLink+'(\''+this.index+'\', \'NextMonth\');" tabindex="0">&gt;&gt;</A></TD>\n';
                }
            }
        result += '</TR></TABLE>\n';

        //calendar date grid
        result += '<TABLE WIDTH=120 BORDER=0 CELLSPACING=0 CELLPADDING=1 ALIGN=CENTER id="cpCalGrid" role="grid" aria-labelledby="cpMonthSelect';
        if (this.isShowNavigationDropdowns || this.isShowYearNavigation)
            result += ' cpYearSelect';
        result += '" tabindex="0">\n';
        result += '<thead><TR>\n';
        for (var j=0; j<7; j++) {

            result += '<TD CLASS="'+this.cssPrefix+'cpDayColumnHeader" WIDTH="14%" scope="col"><SPAN CLASS="'+this.cssPrefix+'cpDayColumnHeader" title="'+this.dayNames[(this.weekStartDay+j)%7]+'">'+this.dayHeaders[(this.weekStartDay+j)%7]+'</TD>\n';
            }
        result += '</TR></thead><tbody>\n';

        result += this.getCalendarDateGridBody();

        result += '</tbody></TABLE>';

        //today option
        if (this.displayType == 'date')
        {
            result += this.getTodayLink();
        }

        result += '</CENTER></TD></TR>';
    }



    if ((this.displayType == 'datetime') || (this.displayType == 'time'))
    {
        result += '<tr><td><div id="cpTimeEntry" class="'+this.cssPrefix+'cpTimeEntry">';

        result += '<span id="cpTimeLabel" class="'+this.cssPrefix+'cpTimeLabel">' + this.timeText + '</span>';

        result += '<span class="'+this.cssPrefix+'cpTimeControls" aria-labelledby="cpTimeLabel">';

        //hours
        result += '<span class="'+this.cssPrefix+'cpHoursContainer"><select title="' + this.timeNames[0] + '" tabindex="0" id="cpHours" class="'+this.cssPrefix+'cpHours">';

        var setHour = currentHour = this.currentDate.getHours()
        var startHour = 0, endHour = 23;
        if (this.is12Hour)
        {
            startHour = 1;
            endHour = 12;
            setHour = CP_24To12Hour(setHour);
        }

        for (var i = startHour; i <= endHour; ++i) {
            var v = (i<10) ? '0' + i : i;
            result+= '<option value="'+v+'"';
            if (setHour == i)
                result += ' selected="selected"';
            result += '>'+v+'</option>';
        }
        result += '</select></span>';

        result += ':';

        //mins
        result += '<span class="'+this.cssPrefix+'cpMinutesContainer"><select title="' + this.timeNames[1] + '" tabindex="0" id="cpMinutes" class="'+this.cssPrefix+'cpMinutes">';
        for (var i = 0; i < 60; ++i) {
            var v = (i<10) ? '0' + i : i;
            result+= '<option value="'+v+'"';
            if (this.currentDate.getMinutes() == i)
                result += ' selected="selected"';
            result += '>'+v+'</option>';
        }
        result += '</select></span>';

        //seconds
        if (this.isShowSeconds)
        {
            result += ':<span class="'+this.cssPrefix+'cpSecondsContainer"><select title="' + this.timeNames[2] + '" tabindex="0" id="cpSeconds" class="'+this.cssPrefix+'cpSeconds">';
            for (var i = 0; i < 60; ++i) {
                var v = (i<10) ? '0' + i : i;
                result+= '<option value="'+v+'"';
                if (this.currentDate.getSeconds() == i)
                    result += ' selected="selected"';
                result += '>'+v+'</option>';
            }
            result += '</select></span>';
        }

        //am/pm selector
        if (this.is12Hour)
        {
            result += '<span class="'+this.cssPrefix+'cpAMPMContainer"><select tabindex="0" id="cpAMPM" class="'+this.cssPrefix+'cpAMPM">';
            result+= '<option value="AM"';
                if (currentHour <= 12)
                    result += ' selected="selected"';
                result += '>AM</option>';
            result+= '<option value="PM"';
                if (currentHour > 12)
                    result += ' selected="selected"';
                result += '>PM</option>';
            result += '</select></span>';
        }

        result += '</span></div>';

        if (this.displayType == 'datetime')
        {
            result += this.getTodayLink();
        }

        result += '<div class="'+this.cssPrefix+'cpNowTextContainer"><a tabindex="0" class="'+this.cssPrefix+'cpNowText" href="javascript:CP_nowSelected(\''+this.index+'\');">' + this.nowText + '</a></div>';


        result += '<div class="'+this.cssPrefix+'cpSelectBtnContainer"><a tabindex="0" class="'+this.cssPrefix+'cpSelectBtn" href="javascript:CP_detailsConfirmed(\''+this.index+'\')">' + this.selectText + '</a></div>';

        result +='</td></tr>';
    }


    result += '</TABLE>';

    return result;
}

/**
 * Returns an HTML string containing all the rows needed
 * to show the calendar grid for the current month.
 */
function CP_getCalendarDateGridBody() {

    var month = this.currentDate.getMonth()+1;
    var year = this.currentDate.getFullYear();
    var daysinmonth= new Array(0,31,28,31,30,31,30,31,31,30,31,30,31);
    if ( ( (year%4 == 0)&&(year%100 != 0) ) || (year%400 == 0) ) {
        daysinmonth[2] = 29;
        }
    var current_month = new Date(year,month-1,1);
    if (year < 100) //the date constructor maps 2 digit years to the 19 hundreds
        current_month.setFullYear(year);
    var display_year = year;
    var display_month = month;
    var display_date = 1;
    var weekday= current_month.getDay();
    var offset = 0;

    offset = (weekday >= this.weekStartDay) ? weekday-this.weekStartDay : 7-this.weekStartDay+weekday ;
    if (offset > 0) {
        display_month--;
        if (display_month < 1) { display_month = 12; display_year--; }
        display_date = daysinmonth[display_month]-offset+1;
        }

    var date_class;


    var result = '';

    for (var row=1; row<=6; row++) {
        result += '<TR>\n';
        for (var col=1; col<=7; col++) {
            var disabled=false;
            if (this.disabledDatesExpression!="") {
                var ds=""+display_year+LZ(display_month)+LZ(display_date);
                eval("disabled=("+this.disabledDatesExpression+")");
                }
            var dateClass = "";
            if ((display_month == this.currentDate.getMonth()+1) && (display_date==this.currentDate.getDate()) && (display_year==this.currentDate.getFullYear())) {
                dateClass = "cpCurrentDate";
                }
            else if (display_month == month) {
                dateClass = "cpCurrentMonthDate";
                }
            else {
                dateClass = "cpOtherMonthDate";
                }
            if (disabled || this.disabledWeekDays[col-1]) {
                result += '	<TD role="gridcell" CLASS="'+this.cssPrefix+dateClass+'"><SPAN CLASS="'+this.cssPrefix+dateClass+'Disabled">'+display_date+'</SPAN></TD>\n';
                }
            else {
                var selected_date = display_date;
                var selected_month = display_month;
                var selected_year = display_year;
                result += '	<TD role="gridcell" CLASS="'+this.cssPrefix+dateClass+'"><A HREF="javascript:CP_dateSelected(\''+this.index+'\', '+selected_year+','+selected_month+','+selected_date+');" CLASS="'+this.cssPrefix+dateClass+'">'+display_date+'</A></TD>\n';
                }
            display_date++;
            if (display_date > daysinmonth[display_month]) {
                display_date=1;
                display_month++;
                }
            if (display_month > 12) {
                display_month=1;
                display_year++;
                }
            }
        result += '</TR>';
        }

    return result;
}

/**
 * Returns the HTML to show on the calendar for a 'today' link
 */
function CP_getTodayLink()
{
    var result = '';

    var now = new Date();
    var current_weekday = now.getDay() - this.weekStartDay;
    if (current_weekday < 0) {
        current_weekday += 7;
        }
    result += '<div CLASS="'+this.cssPrefix+'cpTodayTextContainer">\n';
    var disabled = false;
    if (this.disabledDatesExpression!="") {
        var ds=""+now.getFullYear()+LZ(now.getMonth()+1)+LZ(now.getDate());
        eval("disabled=("+this.disabledDatesExpression+")");
        }
    if (disabled || this.disabledWeekDays[current_weekday+1]) {
        result += '<SPAN CLASS="'+this.cssPrefix+'cpTodayTextDisabled">'+this.todayText+'</SPAN>\n';
        }
    else {
        result += '<A tabindex="0" CLASS="'+this.cssPrefix+'cpTodayText" HREF="javascript:CP_dateSelected(\''+this.index+'\', \''+now.getFullYear()+'\',\''+(now.getMonth()+1)+'\',\''+now.getDate()+'\');">'+this.todayText+'</A>\n';
        }
    result += '</div>';

    return result;
}
