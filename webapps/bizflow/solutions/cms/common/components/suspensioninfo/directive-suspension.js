angular.module('bizflow.angular.component')
	.factory("suspensionService", ['bizflowContext', 'AjaxService', function (bizflowContext, AjaxService) {
	    return {
	        getSuspensionStatus: function(formData, callback) {
				var url = bizflowContext.getDataServiceUrl('/get/fu.FormUtil-getSuspensionStatus.json');
	            var ajaxAction = new AjaxService(url);
	            ajaxAction.loadByPost(formData, callback);
	            return ajaxAction;

			},
	        updateTATWaiting: function(formData, callback) {
				var url = bizflowContext.getDataServiceUrl('/get/fu.FormUtil-updateTATWaiting.json');
	            var ajaxAction = new AjaxService(url);
	            ajaxAction.loadByPost(formData, callback);
	            return ajaxAction;

			},
	        getTATWaiting: function(formData, callback) {
				var url = bizflowContext.getDataServiceUrl('/get/fu.FormUtil-getTATWaiting.json');
	            var ajaxAction = new AjaxService(url);
	            ajaxAction.loadByPost(formData, callback);
	            return ajaxAction;
	        },
            removeDeadLine: function(formData, callback) {
                var url = bizflowContext.getDataServiceUrl('/get/fu.FormUtil-removeDeadLine.json');
	            var ajaxAction = new AjaxService(url);
	            ajaxAction.loadByPost(formData, callback);
	            return ajaxAction;
            }
	    }
	}])
    .directive('suspensionInfo',  ['$compile', 'bizflowContext', 'suspensionService', function ($compile, bizflowContext, suspensionService) {
        return {
            restrict: 'E',
            templateUrl: bizflowContext.appContextPath + '/common/components/suspensioninfo/tpl-suspensionTable.html',
            compile: function compile(tElement, tAttrs, transclude) {
                return {
                    pre: function preLink($scope, $elem, $attr, $controller) {

                    	if( $scope.$parent.isBulkProcess != true ) {
							var urlParams = {
								Region: $scope.$parent.region,
								ProcID: $scope.$parent.processId,
								ActSeq: $scope.$parent.activitySequence
							}

							suspensionService.getTATWaiting(urlParams, {
								success: function(o, data, status, headers, config) {
									if(data.length > 0) {
										$scope.suspendResumeInfos = data;
									}
								},
								error: function (o, data, status, headers, config) {
									alert('error: ' + status + ' - ' + data);
								}
							});
                    	}
                    }
                }
            }
        };
    }])

    .controller('SuspendReasonController', ['$scope', '$http', '$uibModalInstance', 'suspensionService', 'inform', function ($scope, $http, $uibModalInstance, suspensionService, inform) {

    	$scope.suspendItem = function (suspensionReasonInfo, closeModal) {

            var urlParams =  {
						"ReturnType": "JSON",
						"ID": 0,
                        "ProcID": $scope.processId,
                        "ActSeq": $scope.activitySequence,
                        "WitemSeq": $scope.workitemSequence,
                        "UpdatedBy": $scope.memberId,
                        "PreStatus": "",
                        "Comment": $scope.suspensionReasonInfo.Reason,
						"OtherDesc": $scope.suspensionReasonInfo.Other
                    };

            suspensionService.updateTATWaiting(urlParams, {
                success: function (o, data, status, headers, config) {
                    if(data.length > 0) {

                        $scope.$parent.saveFormDataProc($http, 'suspend');
                    }
                },
                error: function (o,  data, status, headers, config) {
                    //$scope.bfCommand = '';
                    alert('error: ' + status + ' - ' + data);
                }
            });

            if (closeModal) {
                $uibModalInstance.close();
            }
        };

        $scope.cancel = function () {
        	if( $scope.suspensionReasonInfo != undefined ) {
	            $scope.suspensionReasonInfo.Reason = '';
	            $scope.suspensionReasonInfo.Other = '';
        	}
            $uibModalInstance.dismiss('cancel');
        };

        $scope.onChangeSuspensionReasion = function() {
        	if( $scope.$parent.onChangeSuspensionReasion != undefined ) {
        		$scope.$parent.onChangeSuspensionReasion($scope.suspensionReasonInfo.Reason);
        	}
        }

    }]);
