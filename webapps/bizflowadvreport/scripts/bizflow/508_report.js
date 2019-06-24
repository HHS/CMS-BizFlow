jQuery( function() {
	if ("y" == _bf508Enbabled || "yes" == _bf508Enbabled) {
		var isIE = /*@cc_on!@*/false || !!document.documentMode;
		var isEdge = !isIE && !!window.StyleMedia;	
		if (isIE || isEdge) {
			BF508ReportProcessor.setBrowserType("IE");
		}
		BF508ReportProcessor.start();
	}
});
