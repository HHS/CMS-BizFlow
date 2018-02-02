/**
 * AngularJS component showing BizFlow Attachments.<br>
 * This component can be initiated by adding attachments element into HTML.
 * @component attachments
 * @memberOf module:"bizflow.angular.component"
 *
 * @param {int} BizFlow Process ID
 * @param {array} documentTypes document type array
 * @param {boolean} showHideOriginals The flag showing original attachment information or not.
 * @param {boolean} isBulkProcess The flag showing BizFlow Process ID or not.
 * @param {boolean} readOnly The flag hiding buttons (Add Attachment) or not.
 *
 * @example
 *<attachments
 *      process-id="$ctrl.processId"
 *      document-types="$ctrl.documentTypes"
 *      show-hide-originals="$ctrl.showHideOriginals"
 *      is-bulk-process="false"
 *      read-only="false">
 *</attachments>
 */

(function () {
    'use strict';

angular.module('bizflow.angular.component')
	.filter('printCreatorName', function () {
		return function (input) {
			if (input && input.CREATORNAME) {
				if (input.TYPE == 'C'
					|| angular.lowercase(input.CREATORNAME).indexOf('agent') > -1
					|| input.CREATORNAME == 'ERA User') {
					return 'System';
				} else {
					return input.CREATORNAME;
				}
			} else {
				return '';
			}
		};
	});

    angular.module('bizflow.angular.component')
        .component('attachments', {
            templateUrl: function($element, $attrs, bizflowContext) {
                return bizflowContext.appContextPath + '/common/components/attachment/attachments.html';
            },
            bindings: {
                processId: '<',
                documentTypes: '<',
                showHideOriginals: '<?',
                isBulkProcess: '<?',
                readOnly: '<?'
            },
            controller: CtrlAttachments
        });

    function CtrlAttachments(bizflowWih, bizflowContext, bizflowService, inform, $window, $uibModal, blockUI, $scope, $log) {
	var vm = this;
        vm.attachments = [];

	vm.$onInit = function() {
            $log.debug("CtrlAttachments $onInit");
            if(bizflowWih.basicWih) {
                bizflowWih.setChangeWorkitemAttachmentCallback(function () {
                    vm.reloadAttachments();
                });
            }
            vm.loadAttachments();
        };

        vm.$onDestroy = function(){
            $log.debug("CtrlAttachments $onDestroy");
        };

        /**
         * Attachments
         */
        vm.loadAttachments = function () {
            if (bizflowWih && bizflowWih.basicWih) {  // Get attachments from basic WIH
                vm.attachments = bizflowWih.getAttachments();
                if (vm.attachments.length) {
                    for (var i = 0; i < vm.attachments.length; i++) {
                        vm.attachments[i].category = vm.documentTypes.dataMap[vm.attachments[i].CATEGORY];
                    }
                }
            } else {    // Get attachments from DB
                bizflowService.getAttachments(vm.processId, {
                    success: function (o) {
                        for (var i = 0; i < o.data.length; i++) {
                            o.data[i].category = vm.documentTypes.dataMap[o.data[i].CATEGORY];
                        }
                        vm.attachments = o.data;
                    }
                });
            }
        };

        vm.reloadAttachments = function () {
            vm.loadAttachments();
            blockUI.stop();
            $scope.$digest();
	};

	vm.getAttachmentUrl = function (attachmentId) {
		return bizflowWih.getAttachmentUrl(attachmentId);
	};

        vm.deleteAttachment = function (id) {
            bootbox.confirm("Do you want to delete the file?", function (result) {
                if (result) {
                    if(!bizflowWih.basicWih) {
                        alert("Deleting Document Type requires Workitem Handler");
                    } else {
                        bizflowWih.removeAttachment(id, function () {
                            bizflowWih.reloadAttachments();
                            //vm.reloadAttachments();
                        });
                    }
                }
            });
        };

        vm.updateAttachmentDocType = function (attachment, newDocType, metadata) {
            if(!bizflowWih.basicWih) {
                inform.add("Updating Document Type requires Workitem Handler", {ttl: 3000});
            } else {
                attachment.CATEGORY = newDocType;
                if( metadata != undefined ) {
                    attachment.edmsMetadata = metadata;
                }
                bizflowWih.updateAttachments(angularExt.objectToArray(attachment));
                vm.loadAttachments();
            }
        };

        vm.addAttachment = function () {
            $uibModal.open({
                template: '<add-attachment $close="$close(result)" document-types="$ctrl.documentTypes" callback="$ctrl.callback"></add-attachment>',
                backdrop: 'static',
                animation: true,
                size: 'lg',
                windowClass: 'attachmentAddWindow',
                controller: function() {
                    this.documentTypes = vm.documentTypes;
                    this.callback = vm.reloadAttachments;
                },
                controllerAs: '$ctrl'
            }).result.then(function(result) {

            });
        };

        vm.viewAllViewableAttachments = function () {
            $window.getAppScope = function() {
                vm.bizflowWih = bizflowWih;
                return vm;
            };
            $window.open(bizflowContext.appContextPath + "/common/components/attachment/attachment-carousel-viewer-app.html?procid=" + vm.processId, "ViewAttachments", "toolbar=0,resizable=1");
        };

        vm.openModalViewAllViewableAttachments = function () {
            var modalInstance = $uibModal.open({
                templateUrl: '../fragments/attachment-carousel-viewer.html',
                controller: 'viewAttachmentsController',
                resolve: {
                    attachments: function () {
                        return vm.attachments;
                    },
                    callback: function () {
                        return function () {
                        }
                    }
                },
                windowClass: 'attachmentViewWindow',
                size: "lg"
            });
        };
    }

    angular.module('bizflow.angular.component')
    .component('attachmentList', {
		templateUrl: function($element, $attrs, bizflowContext) {
			return bizflowContext.appContextPath + '/common/components/attachment/attachment-list.html';
		},
		bindings: {
			documentTypes: '<',
			showHideOriginals: '<?',
			isBulkProcess: '<?',
			readOnly: '<?',
            attachments: '='
		},
        require: {
            main: '^attachments'
        },
		controller: CtrlAttachmentList
	});

    function CtrlAttachmentList($log) {
        var vm = this;

        vm.$onInit = function() {
            $log.debug("CtrlAttachmentList $onInit");
        };

        vm.$onDestroy = function() {
            $log.debug("CtrlAttachmentList $onDestroy");
        };

}

angular.module('bizflow.angular.component')
	.component('addAttachment', {
		templateUrl: function($element, $attrs, bizflowContext) {
			return bizflowContext.appContextPath + '/common/components/attachment/attachment-add.html';
		},
		bindings: {
			$close: '&',
			documentTypes: '=',
			callback: '='
		},
		controller: CtrlAddAttachment
	});

function CtrlAddAttachment($scope, $timeout, bizflowContext, FileUploader, bizflowWih, blockUI) {
	var vm = this;

    // with or without WIH
    var config;
    if(bizflowWih.basicWih) {
        config = {
            url: bizflowContext.getUrl('/bizcoves/wih/attachUpload.jsp?basicWihReadOnly=n'),
            formData: [
                {
                    attachType: 'file',
                    attachUrlName: '',
                    attachUrl: '',
                    hdmMetaFilePath: '',
                    responseType: 'JSON'
                }
            ]
        };
    } else {
        config = {
            url: bizflowContext.getServiceUrl('/bizflow/attachment/upload.json'),
            formData: [
                {
                    processId: bizflowContext.custom.PROCESSID,
                    responseType: 'JSON'
                }
            ]
        };
    }

	vm.uploader = $scope.uploader = new FileUploader(config);

	vm.isReadyToUpload = function () {
		if (vm.uploader.queue.length && vm.uploader.queue.length > 0) {
			for (var i = 0; i < vm.uploader.queue.length; i++) {
				var item = vm.uploader.queue[i];
				if (angularExt.isInvalidObject(item.category)) {
					return false;
				}
			}
			return true;
		}
		return false;
	};

	vm.upload = function () {
		if (vm.uploader.queue.length == 0) {
			alert("Please Select File(s)");
		} else if (vm.uploader.queue.filter(function (el) {
				return el.category == undefined
			}).length > 0) {
			alert("Please Select Document Type");
		} else {
			$timeout(function(){blockUI.start();},1);
			vm.uploader.uploadAll();
		}
	};

	vm.cancel = function () {
		vm.uploader.clearQueue();
		vm.$close({result: 'cancel'});
	};

	vm.uploader.filters.push({
		name: 'customFilter',
		fn: function (item /*{File|FileLikeObject}*/, options) {
			return this.queue.length < 10;
		}
	});

	vm.uploader.onBeforeUploadItem = function (item) {
		if (item.category) {
			item.error = null;
			var formData = [
				{
					category: item.category.Name,
					description: item.description || "",
					etcInfo: "",
					edmsMetadata: ""
				}
			];
			Array.prototype.push.apply(item.formData, formData);
		}
	};

	vm.uploader.onCompleteAll = function () {
		vm.uploader.clearQueue();
		vm.$close({result: 'cancel'});
		if (bizflowWih && bizflowWih.basicWih) {
			bizflowWih.reloadAttachments();
		}
		if (vm.callback) {
			vm.callback();
		} else {
			blockUI.stop();
		}
	};

	vm.$onInit = function() {
		console.log('CtrlAddAttachment $onInit is called.');
	}
}


function buildViewAttachmentController($scope, attachments, bizflowWih) {
	$scope.attachments = attachments;
	$scope.getDocumentExt = function (attachment) {
		var ext = null;
		var filename = attachment.FILENAME;
		var idx = filename.lastIndexOf(".");
		if (-1 != idx) {
			ext = filename.substring(idx).toLowerCase();
		}

		return ext;
	};
	$scope.getAttachmentUrl = function (attachment) {
		return bizflowWih.getAttachmentUrl(attachment.ID);
	};
	$scope.isImage = function (attachment) {
		var v = false;
		var ext = this.getDocumentExt(attachment);
		if (null != ext) {
			var visibleExts = ".png,.jpg,.jpeg,.gif,";
			v = -1 != visibleExts.indexOf(ext + ",");
		}

		return v;
	};
	$scope.isNotVisibleDocumentInIE = function (ext) {
		var exts = ".pdf,";
		return -1 == exts.indexOf(ext + ",");
	};
	$scope.isVisibleDocument = function (attachment) {
		var v = false;
		var ext = this.getDocumentExt(attachment);
		if (null != ext) {
			var visibleExts = ".pdf,.txt,";
			v = -1 != visibleExts.indexOf(ext + ",");
			//if (v && angularExt.browser.IsIE) {
			//    v = this.isNotVisibleDocumentInIE(ext);
			//}
		}

		return v;
	};
}

angular.module('bizflow.angular.component')
	.controller('viewAttachmentsController', ['$scope', '$uibModalInstance', 'attachments', 'bizflowWih',
		function ($scope, $uibModalInstance, attachments, bizflowWih) {
			buildViewAttachmentController($scope, attachments, bizflowWih);
			$scope.cancel = function () {
				$uibModalInstance.dismiss('cancel');
			};
		}]);

})();
