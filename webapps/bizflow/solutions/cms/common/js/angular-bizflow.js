'use strict';

/**
 * Global Objects for BizFlow Interaction.
 * basicWIHActionClient.workitemContext() example
 * @module WorkitemContext
 * @method WorkitemContext
 * @return ObjectExpression
 */
function WorkitemContext() {
    return {
        "User": {
            "Name": null,
            "MemberID": null
        },
        "Activity": {
            "Name": null,
            "Sequence": null
        },
        "SessionInfoXML": null,
        "Process": {
            "Initiator": null,
            "ProcessDefinitionID": null,
            "Name": null,
            "Description": null,
            "CompleteDateTime": null,
            "CreationDateTime": null,
            "InitiatorName": null,
            "ID": null,
            "ProcessState": null
        },
        "Workitem": {
            "StartDateTime": null,
            "DeadlineDateTime": null,
            "State": null,
            "CreationDateTime": null,
            "ParticipantName": null,
            "Sequence": null,
            "ParticipantType": null
        }
    }
}

/**
 * getBasicWIHActionClient.
 * @method getBasicWIHActionClient
 * @return wihActionClient
 */
function getBasicWIHActionClient() {
    var wihActionClient = null;
    try {
        wihActionClient = getWIHActionClient();
    } catch (e) {
        wihActionClient = null;
    }

    if (null == wihActionClient) {
        if (window.opener) {
            wihActionClient = window.opener.getWIHActionClient();
        }
    }
    return wihActionClient;
}

var bizflowWih_completeWithRespondCallback = null;
/**
 * Description
 * @method onWorkitemComplete
 * @param {} basicWih
 */
function onWorkitemComplete(basicWih) {
    if (bizflowWih_completeWithRespondCallback) {
        basicWih.setStop();
        bizflowWih_completeWithRespondCallback(basicWih);
    }
}

var bizflowWih_changeWorkitemAttachmentCallback = null;
var bizflowWih_attachmentCallback = null;
/**
 * Event function that will be fired after attachments in workitem handler are changed.
 * @method onChangeWorkitemAttachment
 * @param {BasicWIH} basicWih
 * @param {Event} action
 */
function onChangeWorkitemAttachment(basicWih, action) {
    if (bizflowWih_changeWorkitemAttachmentCallback) {
        bizflowWih_changeWorkitemAttachmentCallback(basicWih, action);
    }
    if (bizflowWih_attachmentCallback) {
        bizflowWih_attachmentCallback(basicWih, action);
    }
}

/**
 * Description.
 * @method getGlobalWorkitemContext
 * @return workitemContext
 */
function getGlobalWorkitemContext() {
    var workitemContext = null;
    try {
        workitemContext = globalWorkitemContext;
    } catch (e) {
        workitemContext = WorkitemContext();
    }
    return workitemContext;
}

/**
 * Angular Module for BizFlow Workitem Handler.
 * @module "bizflow.angular.wih"
 */


/**
 * Angular Service of BizFlow Workitem Handler.<br>
 * This service is under the angular module "bizflow.angular.wih".
 * @service bizflowWih
 * @memberOf module:"bizflow.angular.wih"
 * @example
 * angular.module("bizflow.app", [
 * 'bizflow.angular.context'
 * ,'bizflow.angular.wih'
 * ,'bizflow.angular.service'
 * ,'bizflow.angular.component'
 * ,'bizflow.app.common'])
 * .controller('CtrlAppMain', function(bizflowContext, bizflowService, bizflowWih) {
 *       var vm = this;
 *       vm.attachments = bizflowWih.getAttachments();
 *   };
 */
angular.module("bizflow.angular.wih", []).service("bizflowWih", function () {
        var vm = this;

        vm.basicWih = getWIHActionClient();
        vm.workitemContext = vm.basicWih ? vm.basicWih.getWorkitemContext() : getGlobalWorkitemContext();

        /**
         * exit
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.exit = function () {
            vm.basicWih.exit();
        };
        /**
         * setStop
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.setStop = function () {
            vm.basicWih.setStop();
        };
        /**
         * setContinue
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.setContinue = function () {
            vm.basicWih.setContinue();
        };
        /**
         * Set the option of Workitem Handler
         * @param {string} name Option name
         * @param {string} value Option value
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.setOption = function (name, value) {
            vm.basicWih.setWIHOption(name, value);
        };
        /**
         * setResponseByName
         * @param {} responseName
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.setResponseByName = function (responseName) {
            vm.basicWih.setResponseByName(responseName);
        };
        /**
         * Complete workitem
         * @param {Callback} callback This callback will be called after wokritem is completed.
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.complete = function (callback) {
            bizflowWih_completeWithRespondCallback = callback;
            vm.basicWih.complete();
        };
        /**
         * respond
         * @param {} responseName
         * @param {} callback
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.respond = function (responseName, callback) {
            bizflowWih_completeWithRespondCallback = callback;
            vm.basicWih.respond(responseName);
        };
        /**
         * completeWithResponse
         * @param {} responseName
         * @param {} callback
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.completeWithResponse = function (responseName, callback) {
            vm.setResponseByName(responseName);
            vm.complete(callback);
        };
        /**
         * completeSilently
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.completeSilently = function () {
            vm.setContinue();
            vm.setOption("completionWindow", false);
            vm.complete();
        };
        /**
         * save
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.save = function () {
            vm.basicWih.save();
        };
        /**
         * forward
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.forward = function () {
            vm.basicWih.forward();
        };
        /**
         * getAttachments
         * @return {Array} Attachments
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.getAttachments = function () {
            return vm.basicWih.getAttachments();
        };
        /**
         * getAttachmentUrl
         * @param {Number} attachmentId
         * @return docUrl
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.getAttachmentUrl = function (attachmentId) {
            var docUrl;
            if (vm.basicWih) {
                docUrl = vm.basicWih.getDocumentURL(vm.workitemContext.Process.ID, attachmentId);
            } else {
                docUrl = "";
            }
            return docUrl;
        };
        /**
         * updateAttachments
         * @param {Array} attachments
         * @return CallExpression
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.updateAttachments = function (attachments) {
            //$timeout(function(){blockUI.start();},1);
            return vm.basicWih.updateAttachments(attachments);
        };
        /**
         * removeAttachment
         * @param {Number} attachmentId
         * @param {Callback} callback
         * @return CallExpression
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.removeAttachment = function (attachmentId, callback) {
            //$timeout(function(){blockUI.start();},1);
            //bizflowWih_attachmentCallback = callback;
            return vm.basicWih.removeAttachment(attachmentId);
        };
        /**
         * reloadAttachments
         * @param {} callback
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.reloadAttachments = function (callback) {
            //bizflowWih_attachmentCallback = callback;
            vm.basicWih.reloadAttachments();
        };
        /**
         * setChangeWorkitemAttachmentCallback
         * @param {} callback
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.setChangeWorkitemAttachmentCallback = function (callback) {
            bizflowWih_changeWorkitemAttachmentCallback = callback;
        };
        /**
         * getBasicWih
         * @return {BasicWIH} basicWih
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.getBasicWih = function () {
            return vm.basicWih;
        };
        /**
         * getBasicWithFrame
         * @return {Element} Basic Workitem Handler frame
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.getBasicWihFrame = function () {
            try {
                if (top != self && top.parent && top.parent.getBasicWIHActionObject) {
                    return top.parent;
                } else {
                    var obj = parent;
                    while (obj) {
                        if (obj.frames && "undefined" != typeof(obj.frames) && top != obj) {
                            if ("undefined" != typeof(obj.getBasicWIHActionObject)) {
                                return obj;
                            } else {
                                obj = obj.parent;
                            }
                        } else {
                            break;
                        }
                    }
                    return undefined;
                }
            }
            catch (e) {
            }
        };
        /**
         * getWihDiscussion
         * @return {Element | undefined} Discussion frame
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.getWihDiscussion = function () {
            var frame = vm.getBasicWihFrame();
            return frame ? frame.wihDiscussion : undefined;
        };
        /**
         * stopRefreshComment
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.stopRefreshComment = function () {
            try {
                setTimeout(function () {
                    var wihDiscussion = vm.getWihDiscussion();
                    if (wihDiscussion) {
                        wihDiscussion.stopAutoFeed();
                    }
                }, 5000);
                // var thisObj = this;
                // setTimeout(function () {
                //     var wihDiscussion = thisObj.getWihDiscussion();
                //     if (wihDiscussion) {
                //         wihDiscussion.stopAutoFeed();
                //     }
                // }, 5000);
            } catch (e) {
            }
        };
        /**
         * getWorkitemContext
         * @return {WorkitemContext} workitem context
         * @memberOf module:"bizflow.angular.wih".bizflowWih
         */
        vm.getWorkitemContext = function () {
            return vm.workitemContext;
        };
    });



/**
 * Angular Module for BizFlow Context
 * @module "bizflow.angular.context"
 */

angular.module('bizflow.angular.context', [])
    /**
     * Angular Provider for BizFlow Context
     * @provider bizflowContext
     * @memberOf module:"bizflow.angular.context"
     */
    .provider("bizflowContext", function () {
        /**
         * Context path of BizFlow Web Application
         * @default /bizflow
         * @memberOf module:"bizflow.angular.context".bizflowContext
         */
        this.contextPath = "/bizflow";

        /**
         * Service Context path of BizFlow SRS
         * @default /bizflowsrs/services
         * @memberOf module:"bizflow.angular.context".bizflowContext
         */
        this.serviceContextPath = "/bizflowsrs/services";

        /**
         * Application Context Path
         * @default
         * @memberOf module:"bizflow.angular.context".bizflowContext
         */
        this.appContextPath = '';

        /**
         * Data Context Path of BizFlow SRS
         * @default /data
         * @memberOf module:"bizflow.angular.context".bizflowContext
         */
        this.dataServiceContextPath = this.serviceContextPath + "/data";

        /**
         * Custom Context
         * @memberOf module:"bizflow.angular.context".bizflowContext
         * @example
         * angular.module("bizflow.app", [
         * ,'bizflow.angular.context'
         * ,'bizflow.angular.wih'
         * ,'bizflow.angular.service'
         * ,'bizflow.angular.component'
         * ,'bizflow.app.common'])
         * .config(['bizflowContextProvider','$logProvider'
         * function (bizflowContextProvider, $logProvider) {
         *    //Turn on or off debugging message
         *    $logProvider.debugEnabled(true);
         *    bizflowContextProvider.custom.debugEnabled = $logProvider.debugEnabled();
         *    bizflowContextProvider.custom.formStyle = "wizard";
         *
         *    //Need to change bizflowsrs context patch if it is not default value bizflowsrs
         *    bizflowContextProvider.setServiceContextPath("/bizflowsrs/services");
         *    bizflowContextProvider.setDataServiceContextPath("/bizflowsrs/services");
         *    bizflowContextProvider.setAppContextPath("/app");
         *
         *    ...
         *    ...

         */
        this.custom = {};

        var offset = location.href.indexOf(location.host) + location.host.length;
        this.appContextPath = location.href.substring(offset, location.href.indexOf('/', offset + 1));

        /**
         * Set context path
         * @param {URL} contextPath
         * @memberOf module:"bizflow.angular.context".bizflowContext
         * */
        this.setContextPath = function (contextPath) {
            this.contextPath = contextPath;
        };

        /**
         * Set service context path
         * @param {URL} serviceContextPath
         * @memberOf module:"bizflow.angular.context".bizflowContext
         * @see {@link custom} for example
         */
        this.setServiceContextPath = function (serviceContextPath) {
            this.serviceContextPath = serviceContextPath;
        };

        /**
         * Set data service context path
         * @param {URL} dataContextPath
         * @memberOf module:"bizflow.angular.context".bizflowContext
         */
        this.setDataServiceContextPath = function (dataContextPath) {
            this.dataServiceContextPath = dataContextPath + "/data";
        };

        /**
         * Set application context path
         * @param {URL} appContextPath
         * @memberOf module:"bizflow.angular.context".bizflowContext
         */
        this.setAppContextPath = function (appContextPath) {
            this.appContextPath = appContextPath;
        };

        /**
         * This function will add given URL to context path and return the URL
         * @param {URL} url
         * @returns {URL} url
         * @memberOf module:"bizflow.angular.context".bizflowContext
         */
        this.getUrl = function (url) {
            return this.contextPath + url;
        };

        /**
         * This function will add given URL to service context path and return the URL
         * @param {URL} url
         * @returns {URL} url
         * @memberOf module:"bizflow.angular.context".bizflowContext
         */
        this.getServiceUrl = function (url) {
            return this.serviceContextPath + url;
        };

        /**
         * This function will add given URL to data context path and return the URL
         * @param {URL} url
         * @returns {URL}
         * @memberOf module:"bizflow.angular.context".bizflowContext
         */
        this.getDataServiceUrl = function (url) {
            return this.dataServiceContextPath + url;
        };

        this.$get = function () {
            return this
        }
    });
