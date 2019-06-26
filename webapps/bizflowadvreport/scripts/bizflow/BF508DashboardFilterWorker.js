(function (window) {

    var BF508DashboardFilterWorker = function() {
        var LOG_ID = "[BF508DashboardFilterWorker] ";
        
        logMessage("file is loaded.");

		function run() {
			
            logMessage("BF508DashboardFilterWorker.run()");
            
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
