/*

Name: bfAttachFile, it uploads (a) file(s) to DB

Usage:
    <bf-attach-file name="Attachment" bf-sender="policyNote" bf-entity-id={{row.entity.id}} bf-callback="grid.appScope.ajax.callback.attachFile">
        <div class="btn btn-default btn-xs" style="margin: 5px;" toolTip="attach file" tooltip-append-to-body="true">
            <span class="glyphicon glyphicon-paperclip"></span>
        </div>
    </bf-attach-file>

Attributes
    bfMultiple(optional): false, when uploading a single file, true, when uploading multiple files, default:false
    bfMerge(optional): true, when merging recieved files from the server together, default:false
    bfOutputFormat(optional): as it says, output format, default : json
    bfCallback(optional) : default: no operation
    bfAttachFileType(optional) : it can be pdf,excel,csv / format : "pdf,csv,docx",  default:pdf
    bfEntityId(mandatory) : it should be set when attaching
    bfFileId(optional) : it should be set when updating
    bfSender(optional) : as it implies, the caller of this directive
    bfIsFileAttaching(optional) : true, file attaching / false, file updating
*/

angular.module('bizflow.angular.component')
.directive('bfAttachFile', function ($uibModal, bizflowContext) {
	return {
		restrict : 'EA',
		replace : true,
        transclude: true,
		scope : {
			bfMerge: "@",
			bfMultiple: "@",
			bfAttachFileType: "@",
            bfOutputFormat: "@",
            bfEntityId: "@",
            bfFileId: "@",
            bfSender:"@",
			bfCallback: "=",
            bfIsFileAttaching: "@"
		},
        template: '<a data-ng-click="open()" data-ng-transclude>{{name}}</a>',
        compile: function compile(element, attrs, transclude) {
            attrs.bfAttachFileType = attrs.bfAttachFileType || "pdf";
            attrs.bfOutputFormat = attrs.bfOutputFormat || "json";
            attrs.bfCallback = attrs.bfCallback || angular.noop;
            attrs.bfMultiple = attrs.bfMultiple || false;
            attrs.bfMerge = attrs.bfMerge || false;
            attrs.bfEntityId = attrs.bfEntityId || "";
            attrs.bfFileId = attrs.bfFileId || "";
            attrs.bfSender = attrs.bfSender || "default";
            attrs.bfIsFileAttaching = attrs.bfIsFileAttaching || true;

            return {
                post: function postLink(scope, element, attrs) {
                        scope.open = function () {
                            $uibModal.open({
                                templateUrl: bizflowContext.appContextPath + '/common/components/general-attachment/tpl-attachment.html',
                                controller: 'attachmentController',
                                backdrop: true,
                                resolve: {
                                    config: function () {
                                        return {
                                            "merge": attrs.bfMerge,
                                            "multiple": attrs.bfMultiple,
                                            "supportFileType": attrs.bfAttachFileType,
                                            "format": attrs.bfOutputFormat,
                                            "callback": scope.bfCallback,
                                            "entityId": attrs.bfEntityId,
                                            "fileId": attrs.bfFileId,
                                            "sender": attrs.bfSender,
                                            "fileAttaching" : attrs.bfIsFileAttaching

                                        }
                                    }
                                },
                                windowClass: 'attachmentAddWindow',
                                size: "lg"
                        });
                    }
                }
            };
        }
	};
})
.controller("attachmentController", function ($scope, $uibModalInstance, bizflowContext, FileUploader, bizflowWih, config) {

    $scope.multiTitle = (config.multiple) ? "(s)" : "";
    $scope.showFileList = false;
    $scope.fileSelector = true;

    $scope.mergeData = [];

    $scope.callback = config.callback;
    $scope.format = config.format;
    $scope.title = "";
    $scope.titleOfActionButton = "";

    $scope.fileTypes = config.supportFileType.split(",");
    $scope.extensionToBeFiltered = "";

    var uploader = $scope.uploader = new FileUploader({
        url: bizflowContext.serviceContextPath + '/file/upload-db',
        formData: [
                       {
                           callbackType:'update',
                           callbackID: 'ceips.CEIPS-updatePolicyNoteFile',
                           fileID: config.fileId + "",
                           callbackParams : JSON.stringify({
                               "data":{
                                   "id": config.entityId,
                                   "fileID": config.fileId
                               }
                           }),
                           source: config.sender
                       }
                ]

    });

    $scope.init = function() {
        var numberOfExtension = $scope.fileTypes.length;
        if(numberOfExtension > 0)
        {
            for(var i=0; i< numberOfExtension ; i++) {
                if (i == numberOfExtension - 1)
                    $scope.extensionToBeFiltered += '|' + $scope.fileTypes[i] + '|';
                else
                    $scope.extensionToBeFiltered += '|' + $scope.fileTypes[i];
            }
        }
        else {
            $scope.extensionToBeFiltered = '|' + "pdf" + '|';
        }

        if(config.fileAttaching == true)
        {
            $scope.title = "Attach File";
            $scope.titleOfActionButton = "Upload";
        }
        else{
            $scope.title = "Update File";
            $scope.titleOfActionButton = "Update";
        }
    };

    $scope.isReadyToUpload = function () {
        if (uploader.queue.length && uploader.queue.length > 0) {
            if (!config.multiple && uploader.queue.length > 1) {
                uploader.clearQueue();
                setTimeout(function() {
                    alert("Please select only one file");
                }, 0);
                return;
            }
            if (config.multiple && uploader.queue.length == 0) {
                alert("Selected file must be " + $scope.alertMsg);
                return;
            }

            if (uploader.queue.length && uploader.queue.length > 0) {
                if (!config.multiple)
                {
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
        if (!config.multiple) {
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
        name: 'docFilter',
        fn: function (item /*{File|FileLikeObject}*/, options) {
            var type = $scope.uploader.isHTML5 ? item.type : '/' + item.value.slice(item.value.lastIndexOf('.') + 1);
            type = '|' + type.toLowerCase().slice(type.lastIndexOf('/') + 1) + '|';
            return $scope.extensionToBeFiltered.indexOf(type) !== -1;
        }
    });
    uploader.filters.push({
        name: 'amountFilter',
        fn: function (item /*{File|FileLikeObject}*/, options){
            return this.queue.length < 10;
        }
    });

    uploader.onBeforeUploadItem = function (item) {
    };

    uploader.onCompleteItem = function (fileItem, response, status, headers) {
        if (status == "200")
        {
            if (!config.merge && $scope.callback)
            {
                $scope.callback(fileItem, response, status);
            }
            else
            {
                if ($scope.format.toUpperCase() == "JSON")
                {
                    $scope.makeJson(response);
                }
                else
                {
                    $scope.makeXML(response);
                }
            }
        }
        else
        {
            if($scope.callback) $scope.callback(fileItem, response, status);
        }
    };

    uploader.onCompleteAll = function () {
        uploader.clearQueue();
        if (config.merge && $scope.callback) {
            $scope.callback($scope.mergeData);
        }
        $uibModalInstance.dismiss('cancel');
    };

    uploader.onWhenAddingFileFailed = function(item, filter, options){
        if(item.name)
        {
            alert("Selected file is not supported.");
            return;
        }

    };
    uploader.onAfterAddingFile =  function(item) {
    };
    uploader.onAfterAddingAll =  function(addedItems) {
    };
    uploader.onProgressItem =  function(item,progress) {
    };
    uploader.onProgressAll =  function(progress) {
    };
    uploader.onSuccessItem =  function(item, response, status, headers) {
    };
    uploader.onErrorItem =  function(item, response, status, headers) {
    };
    uploader.onCancelItem =  function(item, response, status, headers) {
    };



});
