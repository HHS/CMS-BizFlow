
'use strict';

var app = angular.module('app', [
    'blockUI',
    'bizflow.angular.wih',
    'bizflow.angular.component',
    'bizflow.angular.service'
]);

app.config(function (blockUIConfig) {
    blockUIConfig.autoInjectBodyBlock = true;
});

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

app.controller('appController', ['$scope', '$http', 'blockUI', 'bizflowWih', 'bizflowService', '$window',
    function ($scope, $http, blockUI, bizflowWih, bizflowService, $window) {
        $scope.processId = angularExt.getUrlParameter(location.href, "procid");
        $scope.saveAsAttachment = true;
        if (window.opener) {
            var scope = window.opener.getAppScope();
            if (scope && scope.attachments) {
                $scope.processId = scope.processId;

                bizflowWih = scope.bizflowWih;

                $scope.attachments = {
                    data: scope.attachments,
                    load: function() {
                        this.data = bizflowWih.getAttachments();
                    }
                };
            }
        }

        if (angular.isUndefined($scope.attachments) || null == $scope.attachments) {
            $scope.attachments = bizflowService.getAttachments($scope.processId);
        }

        buildViewAttachmentController($scope, $scope.attachments, bizflowWih);

        $scope.refreshViewAttachments = function () {
            $scope.attachments.load();
        };

        $scope.cancel = function () {
            $window.getAppScope = null;
            $window.close();
        };

        $scope.stopBlock = function () {
            blockUI.stop();
        };
    }]);
