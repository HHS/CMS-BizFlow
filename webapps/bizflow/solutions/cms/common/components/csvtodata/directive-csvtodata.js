angular.module('bizflow.angular.component')
.directive('bfCsvToData', ['bizflowContext', function (bizflowContext) {
	return {
		restrict : 'EA',
		replace : true,
		scope : {
			bfClass: "@",
			bfTitle: "@",
			bfMerge: "@",
			bfMulti: "@",
			bfFormat: "@",
			bfSource: "@",
			bfDateFormat: "@",
			bfCallback: "="
		},
		templateUrl: bizflowContext.appContextPath + '/common/components/csvtodata/tpl-csvtodata.html',
		controller: "CsvToDataController"
	};
}]).controller("CsvToDataController", function($scope, $uibModal, bizflowContext) {
	$scope.bfSource = ($scope.bfSource) ? $scope.bfSource : "csv";

	$scope.addAttachment = function() {
     	var modalInstance = $uibModal.open({
             templateUrl: bizflowContext.appContextPath + '/common/components/csvtodata/csv-add.html',
             controller: 'UploadCsvController',
             resolve: {
            	 config: function() {
            		return {
            			"merge": ($scope.bfMerge == "true") ? true : false,
            			"multi": ($scope.bfMulti == "true") ? true : false,
            			"source": (/excel|both/.test($scope.bfSource)) ? $scope.bfSource : "csv",
            			"dateFormat": $scope.bfDateFormat
            		}
            	 },
            	 format: function() {
            		 return $scope.bfFormat;
            	 },
                 callback: function() {
                     return $scope.bfCallback;
                 }
             },
             windowClass: 'attachmentAddWindow',
             size: "lg"
         });
     };
}).controller("UploadCsvController", function ($scope, $uibModalInstance, bizflowContext, FileUploader, bizflowWih, callback, format, config) {
	$scope.multiTitle = (config.multi) ? "(s)" : "";
	$scope.source = (config.source == "both") ? "CSV or Excel" : config.source.toUpperCase();
	$scope.regExp = (config.source == "both") ? ".(csv|xls|xlsx)$" : (config.source == "excel") ? ".(xls|xlsx)$" : ".csv$";
	$scope.regExp = new RegExp($scope.regExp, "i");

	$scope.alertMsg = (config.source == "both") ? "CSV or EXCEl file (.csv, .xls, .xlsx)" : (config.source == "excel") ? "EXCEl file (.xls, .xlsx)" : "CSV file (.csv)";
	$scope.showFileList = false;
	$scope.fileSelector = true;
	$scope.mergeData;

	var uploader = $scope.uploader = new FileUploader({
		url: bizflowContext.serviceContextPath + '/file/convert/' + (config.source == "both" ? "csvOrExcel" : config.source) + '.' + format.toLowerCase() + (config.dateFormat ? '?dateFormat=' + encodeURIComponent(config.dateFormat) : ''),
		formData: [
		           {
		        	   attachType: 'file',
		        	   attachUrlName: '',
		        	   attachUrl: '',
		        	   hdmMetaFilePath: '',
		        	   responseType: format.toUpperCase()
		           }
		]
	});

	$scope.init = function() {

	};

	$scope.isReadyToUpload = function () {
		if (uploader.queue.length && uploader.queue.length > 0) {
			if (!config.multi && uploader.queue.length > 1) {
				uploader.clearQueue();
				setTimeout(function() {
					alert("Please select only one file");
				}, 0);
				return;
			};

			var length = uploader.queue.length;
			for (var i = 0; i < length; i ++) {
				var item = uploader.queue[i];
				if (!$scope.regExp.test(item.file.name)) {
					uploader.queue.splice(i, 1);
					if (!config.multi || length == 1) {
						setTimeout(function() {
							alert("Selected file must be a " + $scope.alertMsg);
						}, 0);
						return;
					}
				}
			}
			if (config.multi && uploader.queue.length == 0) {
				alert("Selected file must be a " + $scope.alertMsg);
				return;
			}

			if (uploader.queue.length && uploader.queue.length > 0) {
				if (!config.multi) {
					$scope.fileSelector = (uploader.queue.length == 0);
					$scope.upload();
				}
				$scope.showFileList = true;
				return true;
			}
			$scope.showFileList = false;
			return false;
		}
		return false;
	};

	$scope.upload = function () {
		if (uploader.queue.length == 0) {
			alert("Please Select File(s)");
		} else {
			uploader.uploadAll();
		}
	};

	$scope.cancel = function () {
		uploader.clearQueue();
		$uibModalInstance.dismiss('cancel');
	};

	$scope.queueRemove = function(item) {
		item.remove();
		$scope.showFileList = $scope.uploader.queue.length > 0;
		if (!config.multi) {
			$scope.fileSelector = (uploader.queue.length == 0);
		}
	};

	$scope.makeJson = function(response) {
		if (!$scope.mergeData) {
			$scope.mergeData = [];
		}
		$scope.mergeData = $scope.mergeData.concat(response);
	};

	$scope.makeXML = function(response) {
		// TODO
	};

	uploader.filters.push({
		name: 'customFilter',
		fn: function (item /*{File|FileLikeObject}*/, options) {
			return this.queue.length < 10;
		}
	});

	uploader.onBeforeUploadItem = function (item) {
	};

	uploader.onCompleteItem = function (fileItem, response, status, headers) {
		if (status == "200") {
			if (!config.merge) {
				callback(response);
			} else {
				if (format.toUpperCase() == "JSON") {
					$scope.makeJson(response);
				} else {
					$scope.makeXML(response);
				}
			}
		} else {
			// TODO
		}
	};

	uploader.onCompleteAll = function () {
		uploader.clearQueue();
		if (config.merge) {
			callback($scope.mergeData);
		}
		$uibModalInstance.dismiss('cancel');
	};
 });
