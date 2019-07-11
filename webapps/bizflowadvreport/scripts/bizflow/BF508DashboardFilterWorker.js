(function (window) {

    var BF508DashboardFilterWorker = function() {
        var LOG_ID = "[BF508DashboardFilterWorker] ";
        
        logMessage("file is loaded.");

		function run() {
			
            logMessage("BF508DashboardFilterWorker.run()");
            
			//if(typeof _bf508Enbabled != 'undefined' && _bf508Enbabled == 'y')
			{
				// Single Select Field
				//set readonly to a typeahead field (textbox)
			    jQuery(".sSelect-sSearch > .searchLockup > .wrap input").prop('readonly', true);
				//Hide the textbox (move up the list items)
				jQuery(".sSelect-sSearch > .searchLockup > .wrap").css('height','0px');
				jQuery(".sSelect-listContainer").css('height','0px');
				//jQuery("div[data-componentid='Filter_Group'] div.sSelect").attr("aria-label","To expand list or select an item, use enter key. To change selection arrow key.");
				
				// Date Field
				jQuery("div[data-componentid='Filter_Group'] .ui-datepicker-trigger").remove();
				jQuery("div[data-componentid='Filter_Group'] .button.picker.calTriggerWrapper").remove();				
                //jQuery("div[data-componentid='Filter_Group'] INPUT.date.hasDatepicker").attr("aria-label","Type in date in the format MM/DD/YYYY.");	

                jQuery("div[data-componentid='Filter_Group'] input.hasDatepicker").each(function( index ) {

                    var fieldLabel = jQuery( this ).prev().text();
                    if (typeof fieldLabel === "undefined" || fieldLabel === null) {
                        fieldLabel = "";
                    } else {
                        fieldLabel += ". ";
                    }
                    jQuery(this).attr("aria-label", fieldLabel + " Type in date in the format MM / DD / Y Y Y Y .")
                
                });

                /*                
                //Additional logic for local timezone setting - todo:separate the logic to a different place
                if (jQuery("#TIMEZONE input[type='text'][class]").length > 0) {
                    var userTimezone = "EST";
                    userTimezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
                    logMessage("user local timezone=" + userTimezone);
                    JQuery("#TIMEZONE input[type='text'][class]").val(userTimezone);
                }
                */
				
			}            
		}

		function logMessage(message) {
            console.log(LOG_ID + message);
		}
		
        return {
			run: run
        }
    }

    var _initializer = window.BF508DashboardFilterWorker || (window.BF508DashboardFilterWorker = BF508DashboardFilterWorker());
})(window);
