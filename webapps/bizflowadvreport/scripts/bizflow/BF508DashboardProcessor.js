
(function (window) {

    var BF508DashboardProcessor = function() {
		var LOG_ID = "[BF508DashboardProcessor] ";
		var RECURSION_INTERVAL = 5000;
		var MAX_RECURSION_COUNT = 100;
		var rootContainerId = "display";
		var initialized = false;
		var recursion_count = 0;
		var reportTables = new Object();
		var browserType = "";
		
		logMessage("file is loaded.");
				
		function start() {
			
			window.BF508ReportProcessor.setRootContainer(rootContainerId);
			
			window.BF508ReportProcessor.setBrowserType(browserType);
			
			logMessage("BF508DashboardProcessor.start()");
			window.BF508ReportProcessor.start();
			/*
			setTimeout(function(){ 
				window.BF508DashboardProcessor.start(); 
			}, interval);
			*/
		}

		function setBrowserType(browserTP) {
			browserType = browserTP;
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
			setBrowserType: setBrowserType
			,start: start
        }
    }

    var _initializer = window.BF508DashboardProcessor || (window.BF508DashboardProcessor = BF508DashboardProcessor());
})(window);
