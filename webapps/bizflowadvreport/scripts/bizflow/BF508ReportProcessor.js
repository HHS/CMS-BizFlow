(function (window) {

    var BF508ReportProcessor = function() {
		var LOG_ID = "[BF508ReportProcessor] ";
		var RECURSION_INTERVAL = 3000;
		var MAX_RECURSION_COUNT = 10000000;
		var rootContainerId = "reportContainer";
		var initialized = false;
		var recursion_count = 0;
		var reportTables = new Object();
		var browserType = "";
		
		logMessage("file is loaded.");
		
		function start() {
			logMessage("BF508ReportProcessor started (" + (recursion_count + 1) + ")");
			
			scanReportTables(rootContainerId);
			
			if (jQuery("#" + rootContainerId + " table.jrPage[_bf508status]" ).length > 0) {
				processAll(rootContainerId);
			}
			
			setTimeout(function(){
				recursion_count++;
				if (recursion_count < MAX_RECURSION_COUNT) {
					window.BF508ReportProcessor.start(); 
				}
			}, RECURSION_INTERVAL);			
		}

		//Report table is dynamically changed to a new table 
		//when to navigate page by clicking on the page navigation toolbar button.
		//therefore, we need to scan tables again.
		function scanReportTables(rootId) {
			logMessage("scanning report tables under #" + rootId);
			//finding tables that the 508 processor has not found.
			jQuery("#" + rootId + " table.jrPage:not([id])" ).each(function( index ) {				
				//set ID if no ID exists
				var tableId = jQuery( this ).attr("id");
				if (typeof tableId === "undefined") {
					tableId = "_bftable_" + Math.floor(Math.random() * 1000000000);
					
					jQuery(this).attr("id", tableId);			
					var tableContent = jQuery(this).text()
					//Do not process Disclaimer sections
					if ((tableContent.indexOf("Disclaimer") < 0) 
							&& (jQuery("#" + tableId + " tr").length > 2 )
							&& (jQuery("#" + tableId + " img").length <= 0)){
						jQuery(this).attr("_bf508status", "marked");
					}
				}
			});			
		}
		
		function registerReportTable(tableId, isDashlet, isInitialized) {
			logMessage("regitering a table [" + tableId + "]");
			var tableInfo = reportTables[tableId];
			if (null == tableInfo || typeof tableInfo == "undefined") {
				tableInfo = {};
				tableInfo.tableId = tableId;
				tableInfo.isDashlet = isDashlet;
				tableInfo.initialized = isInitialized;	
				reportTables[tableId] = tableInfo;				
			}
			logMessage(JSON.stringify(tableInfo));	
		}

		function processAll(rootId) {
			logMessage("processing all registered tables. ");

			jQuery("#" + rootId + " table.jrPage[_bf508status]" ).each(function( index ) {
				var _bf508status = jQuery(this).attr("_bf508status");
				var tableId = jQuery(this).attr("id");
				if (_bf508status === "marked") {
					process(tableId);
				} else {
					if (jQuery("#" + tableId + "[role='application']").length > 0) {
						cleanAriaAttributes(tableId);
					}					
				}
				
			});
		}
		
		function process(tableId) {
			//var tableInfo  = reportTables[tableId];
			registerReportTable(tableId, false, false);
			
			logMessage("processing " + tableId, "color:green;");
			
			if (!isTableInitialized(tableId)) {
				initReportViewer();
			}

			cleanAriaAttributes(tableId);
			
			trimEmptyRowsInTables(tableId);

			var tableInfo = reportTables[tableId];
			var tblCaption = getReportCaption(tableId);
			if (typeof tblCaption !== "undefined") {
				tableInfo.tableCaption = tblCaption;
				addTableCaption(tableId, tblCaption);
			}
			
			if (rootContainerId == "reportContainer") {
				var tblSummary = getReportSummmary(tableId);
				if (typeof tblSummary !== "undefined") {
					tableInfo.tableSummary = tblSummary;
					addTableSummary(tableId, tblSummary);
				}
			}
			//trimDuplicateReportCaptionSummary(tableId);
			
			//convertTDToTH(tableId);
			
			setReportClickable(tableId);

			setHeadMargin("10px");		

			jQuery("#" + tableId).attr("_bf508status", "processed");
		}
		
		function isTableInitialized(tableId) {
			var tbl = reportTables[tableId];
			var initialized = false;
			try {
				if (tbl != null) {
				
					if (typeof tbl.initialized === "boolean") {
						initialized = tbl.initialized;
					}
				}
			} catch (e) {
				console.log(e);
			} finally {
				console.log("initialized="+ initialized);
			}
			return initialized;
		}
		
		function initReportViewer() {
			logMessage("initializing section 508 in the report");
			
			if ("y" == _bf508Enbabled || "yes" == _bf508Enbabled) {
				
				jQuery("#dataRefreshButton_508").show();
				jQuery("#dataRefreshButton").hide();
				
				logMessage("hiding report zoom toolbar buttons");
				jQuery("#viewerToolbar.toolbar ul.buttonSet").hide();
				
				jQuery("#viewerToolbar #reportZoom").hide();
				jQuery("#viewerToolbar #reportSearch").hide();
				
				jQuery("#pagination #page_first").attr('aria-label', 'move to the first page');
				jQuery("#pagination #page_prev").attr('aria-label', 'move to the previous page');
				jQuery("#pagination #page_next").attr('aria-label', 'move to the next page');
				jQuery("#pagination #page_last").attr('aria-label', 'move to the last page');
				jQuery("#pagination #page_current").attr('aria-label', 'current report page number');
				
				//Toolbar button - Refersh
				if (jQuery("#dataRefreshButton_508").length == 0) {
					var reportTitle = jQuery("#reportViewFrame div.title").text();
					if (reportTitle == null) reportTitle = "";
					reportTitle = reportTitle.trim();
					var reportUpdatedDTime = jQuery("#dataTimestampMessage").text();
					
					jQuery("#viewerToolbar.toolbar").append(
						'&nbsp;&nbsp;&nbsp;<span style="display:;"><button id="dataRefreshButton_508" '
						+ ' aria-label="Refresh ' + reportTitle + '  with latest data. ' + reportUpdatedDTime + '"' 
						+ ' style="width:100px;height:30px;"'
						+ ' tabindex="0" '
						+ ' onclick="window.BF508ReportProcessor.refreshCurrentReport()">'
						+ 'Refresh</button>'
						+ ' </span>');
				}

				//Toolbar button - Export PDF
				if (jQuery("#Export_PDF").length == 0) {
					jQuery("#viewerToolbar.toolbar").append(
						'<span style="display:;"><button id="Export_PDF"'
							+ ' style="width:100px;height:30px;"'
							+ ' tabindex="0" '
							+ ' aria-label="Export the report to a PDF file"'
							+ ' onclick="window.BF508ReportProcessor.exportReport(\'pdf\');">'
							+ ' Export PDF</button>'
						+ ' </span>');
				}

				//Toolbar button - Export EXCEL
				if (jQuery("#Export_EXCEL").length == 0) {
					jQuery("#viewerToolbar.toolbar").append(
						'<span style="display:;"><button id="Export_EXCEL"'
							+ ' style="width:100px;height:30px;"'
							+ ' aria-label="Export the report to an excel file"'
							+ ' onclick="window.BF508ReportProcessor.exportReport(\'xlsx\');">'
							+ ' Export Excel</button>'
						+ ' </span>');
				}

				//Toolbar button - Option
				if (jQuery("#ICDialog_508").length == 0) {
					jQuery("#viewerToolbar.toolbar").append(
						'<span style="display:;"><button id="ICDialog_508"'
							+ ' style="width:100px;height:30px;"'
							+ ' tabindex="0" '
							+ ' aria-label="Open the report options dialog"'
							+ ' onclick="window.BF508ReportProcessor.showReportOption();">'
							+ 'Option</button>'
						+ ' </span>');
				}				
			}
		}

		function setReportClickable(tableId) {
			logMessage("making the report clickable.");
			jQuery("#" + tableId).removeAttr("tabindex");
		}
		
		function setTabindices(tableId) {
			logMessage("adding tabindex to span");
			jQuery("#" + tableId + " span:not(:empty)" ).each(function( index ) {
				jQuery( this ).attr("tabindex", "0");
			});
		}

		function cleanAriaAttributes(tableId) {
			//------------------------------
			//Removing ARIA attributes which prevent screen reader software from recognizing HTML tables in a report.
			//
			//	The application role indicates to assistive technologies 
			//	that an element and all of its children should be treated similar to a desktop application
			//	, and no traditional HTML interpretation techniques should be used. 
			//	This role should only be used to define very dynamic and desktop-like web applications.		
			//------------------------------
			logMessage("removing role attribute tableId=" + tableId, "color:blue;");
			jQuery("#" + tableId).removeAttr("role");
			jQuery("#" + tableId).removeAttr("aria-label");
			jQuery("#" + tableId).attr("role", "table");	

			//remove new line <BR> tag so that Jaws does not stop reading content of the cell at new line <BR> tag.
			jQuery("#" + tableId + " td[role='gridcell'] br").remove();
			/*
			try {
				jQuery("#" + tableId).css("transform", "");
				jQuery("#" + tableId).css("transform-origin", "");
			} catch (e) {
				
			}
			*/
		}
	
		function trimEmptyRowsInTables(tableId) {
			//------------------------------
			//Trimming empty rows from tables
			//------------------------------
			logMessage("removing empty rows from tables for screen reader software to read and naviagte tables easily. tableId=" + tableId);
			jQuery("#" + tableId + " tr[style] td[colspan]" ).each(function( index ) {
				if ((jQuery( this ).text() == "\n" || jQuery( this ).text() == "\r") && jQuery( this ).siblings().length == 0) {
					logMessage(">>" + index + ": " + jQuery( this ).prop("tagName") + '=' + jQuery( this ).text() + ". siblings=" + jQuery( this ).siblings().length);
					if (index >= 0) {
						jQuery( this ).parent().remove();
					}
				}
			});
			
			//first and last colums having no data
			/*
			jQuery("#" + tableId + " tr[style] td:first" ).each(function( index ) {
				if ((jQuery( this ).text() == "\n" || jQuery( this ).text() == "\r")) {
					logMessage("removing first empty column>" + index + ": " + jQuery( this ).prop("tagName") + '=' + jQuery( this ).text() + ". siblings=" + jQuery( this ).siblings().length, "color:red;");
					if (index >= 0) {
						jQuery( this ).remove();
					}
				}
			});			

			jQuery("#" + tableId + " tr[style] td:last" ).each(function( index ) {
				if ((jQuery( this ).text() == "\n" || jQuery( this ).text() == "\r")) {
					logMessage("removing last empty column>" + index + ": " + jQuery( this ).prop("tagName") + '=' + jQuery( this ).text() + ". siblings=" + jQuery( this ).siblings().length, "color:red;");
					if (index >= 0) {
						jQuery( this ).remove();
					}
				}
			});	
			*/
		
			
			jQuery("#" + tableId + " tr[style='height:0']").remove(); 
			//for IE
			
			jQuery("#" + tableId + " tr[style]" ).each(function( index ) {
				if (jQuery( this ).css('height') == "0px" || jQuery( this ).css('height') == "0") {
					jQuery( this ).remove();
				}
			});
			
			
			//jQuery("#" + tableId + " tr[style][role='row'][style='height: 0px']").remove(); 
			
			jQuery("#" + tableId + " td[role='gridcell']").filter(function(index) {
				return (jQuery( this ).text() == "\n" || jQuery( this ).text() == "\r");
			}).remove();
			
		}
		
		function trimDuplicateReportCaptionSummary(tableId) {
			jQuery("#" + tableId + " tr[role='row']:first").remove(); 
			jQuery("#" + tableId + " tr[role='row']:first").remove(); 
		}
		
		function addTableSummary(tableId, summary) {
			//------------------------------
			//Adding a summary to a report table
			//------------------------------
			logMessage("adding a table summary. " + summary);
			jQuery("#" + tableId + ":first").attr("summary", summary);
		}
		
		function addTableCaption(tableId, caption) {
			//------------------------------
			//Adding caption to a reqport table
			//------------------------------
			logMessage("adding a table caption. " + caption);
			if (jQuery("#" + tableId + " caption").length == 0) {
				//var title = jQuery("#" + tableId + " div.header div.title").text();
				//title = title.trim();
				jQuery("<caption style='display:none'>" + caption + "</caption>").prependTo("#" + tableId);
			}
		}
		
		function convertTDToTH(tableId) {
			jQuery("#" + tableId + " td[style]").each(function(index) {
				//jQuery(this).css("background-color")
			  //jQuery(this).replaceWith('<th>' + jQuery(this).text() + '</th>'); 
			});
		}

		function setHeadMargin(height) {
			if (jQuery("#_508headroom").length == 0) {
				logMessage("adding head room");
				jQuery( "<DIV id='_508headroom' style='height:" + height + ";' role='application'></DIV>" ).prependTo("#reportContainer");
			}
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

		function setRootContainer(rootId) {
			rootContainerId = rootId;
		}
		
		function getRootContainer() {
			return rootContainerId;
		}
		
		function setBrowserType(browserTP) {
			browserType = browserTP;
		}
		
		function getBrowserType() {
			return browserType;
		}

		function getReportCaption(tableId) {
			var caption = "";
			var objTable = reportTables[tableId];
			if (objTable != null && typeof objTable !== "undefined") {
				caption = objTable.tableCaption;
			}
			if (null == caption || caption === "" || typeof caption === "undefined") {
				if (rootContainerId == "reportContainer") {
					caption = jQuery("#" + tableId + " tr[role='row'] td[role='gridcell'] span:first").text();
				} else {
					caption = jQuery("#" + tableId + " tr td span:first").text();
				}
			}
			return caption;
		}
		
		function getReportSummmary(tableId) {
			var summary = "";
			var objTable = reportTables[tableId];
			if (objTable != null && typeof objTable !== "undefined") {
				summary = objTable.tableSummary;
			}
			if (null == summary || summary === "" || typeof summary === "undefined") {
				if (rootContainerId == "reportContainer") {
					summary = jQuery("#" + tableId + " tr[role='row']:nth-child(2)").text();
				} else {
					summary = jQuery("#" + tableId + " tr:nth-child(2)").text();
				}
			}
			if (null != summary && typeof summary !== "undefined") {
				summary = summary.trim();
			}
			return summary;		
		}
		
		function refreshCurrentReport() {
			//refresh report
			viewer.jive && viewer.jive.hide();
			if ((typeof Controls !== "undefined")) {
				var selectedData = Controls.viewModel.get('selection');
				var controlsUri = ControlsBase.buildSelectedDataUri(selectedData);
				Report.refreshReport({freshData: true}, null, controlsUri ? '&' + controlsUri : '');
			} else {
				Report.refreshReport({freshData: true}, null, '');
			}
		}
		
		function showReportOption() {
            if (Controls.controlDialog){
                Controls.controlDialog.show();
            }				
		}
		
		function exportReport(fileFormat) {
			if (fileFormat == null) fileFormat = "";
			var reportUnitURI = Report.reportUnitURI;
			var idx = reportUnitURI.lastIndexOf("/");
			reportUnitURI = reportUnitURI.substr(idx);
			reportUnitURI = "/bizflowadvreport/flow.html/flowFile/" + reportUnitURI + "." + fileFormat;
			alert("We are currently implementing " + reportUnitURI  + " export feature in accessibility mode.");
			Report.exportReport(fileFormat, reportUnitURI)
		}
		
        return {
			start: start
			,process: process
			,scanReportTables: scanReportTables
			
			//setter
			,setBrowserType: setBrowserType
			,getBrowserType: getBrowserType
			,setRootContainer: setRootContainer
			,registerReportTable: registerReportTable
			
			,isTableInitialized: isTableInitialized
			
			,setReportClickable: setReportClickable
			,cleanAriaAttributes: cleanAriaAttributes
			,setTabindices: setTabindices
			,trimEmptyRowsInTables: trimEmptyRowsInTables
			,addTableSummary: addTableSummary
			,addTableCaption: addTableCaption
			//Report Toolbar button
			,refreshCurrentReport: refreshCurrentReport
			,showReportOption: showReportOption
			,exportReport: exportReport

        }
    }

    var _initializer = window.BF508ReportProcessor || (window.BF508ReportProcessor = BF508ReportProcessor());
})(window);

