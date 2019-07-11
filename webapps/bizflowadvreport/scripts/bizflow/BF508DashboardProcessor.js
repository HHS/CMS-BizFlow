
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
		var debugLogEnabled = false;

		console.log(LOG_ID + "file is loaded.");
				
		function start() {
			
			logMessage("started (" + (recursion_count + 1) + ")");

			BF508ReportProcessor.setRootContainer(rootContainerId);
			
			BF508ReportProcessor.setBrowserType(browserType);
			
			BF508ReportProcessor.start();

			BF508DashboardFilterScanner.scan();
		}

		function setBrowserType(browserTP) {
			browserType = browserTP;
		}
		
		function getDebugLogEnabled() {
			return debugLogEnabled;
		}
		
		function setDebugLogEnabled(enabled) {
			debugLogEnabled = enabled;
		}

		function logMessage(message, style) {
			if (debugLogEnabled) {			
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
		}

		
        return {
			setBrowserType: setBrowserType
			, getDebugLogEnabled: getDebugLogEnabled
			, setDebugLogEnabled: setDebugLogEnabled
			,start: start
        }
    }

    var _initializer = window.BF508DashboardProcessor || (window.BF508DashboardProcessor = BF508DashboardProcessor());
})(window);
