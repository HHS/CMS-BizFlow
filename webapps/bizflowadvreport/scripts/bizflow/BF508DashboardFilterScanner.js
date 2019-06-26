(function (window) {

    var BF508DashboardFilterScanner = function() {
        var LOG_ID = "[BF508DashboardFilterScanner] ";
        var recursion_count = 0;
		var RECURSION_INTERVAL = 3000;
		var MAX_RECURSION_COUNT = 1000000;
        var searchFiterFullyLoaded = false;
        var searchFilterProcessed = false;

		logMessage("file is loaded.");
				
		function scan() {
            logMessage("BF508DashboardFilterScanner.scan (" + recursion_count + ")");
            
            if (!searchFiterFullyLoaded) {
                searchFiterFullyLoaded = checkFilterFullyLoaded();
            }

            if (searchFiterFullyLoaded) {
                if (!searchFilterProcessed) {
                    searchFilterProcessed = BF508DashboardFilterWorker.run();
                }
            } else {
                setTimeout(function(){
                    recursion_count++;
                    if (recursion_count < MAX_RECURSION_COUNT) {
                        window.BF508DashboardFilterScanner.scan(); 
                    }
                }, RECURSION_INTERVAL);	
            }
		}

        function checkFilterFullyLoaded() {
            var cnt = jQuery("div[data-componentid='Filter_Group'] button[title='Apply']").length;
            var fullyLoaded = (cnt > 0);
            return fullyLoaded;
        }

		function logMessage(message, style) {
			if (typeof style !== "undefined") {
				if (browserType !== "IE") {
					console.log("%c" + LOG_ID + message, style);
				} else {
					console.log(LOG_ID + message);
				}
			} else {
				console.log(LOG_ID + message);
			}				
		}
		
        return {
			scan: scan
        }
    }

    var _initializer = window.BF508DashboardFilterScanner || (window.BF508DashboardFilterScanner = BF508DashboardFilterScanner());
})(window);
