'use strict';

(function (window) {
    angular
        .module("bizflow.angular.service",
            [
                'bizflow.angular.context',
                'bizflow.angular.wih',
                'angularFileUpload',
                'inform',
                'blockUI'
            ])
        .factory("AjaxService", ['$http', function ($http) {
            return function AjaxService(url) {
                this.url = url;
                this.data = null;
                this.error = null;
                this.result = null;

                this.reset = function () {
                    this.data = null;
                    this.error = null;
                    this.result = null;
                };

                this.AjaxResult = function (data, status, headers, config) {
                    if (angular.isDefined(data.faultString)) {
                        data = "Fault Code (" + data.faultCode + ") " + data.faultString;
                    }
                    return {
                        data: data,
                        status: status,
                        headers: headers,
                        config: config
                    }
                };

                this.processSuccessAjaxResult = function (data, status, headers, config, callback) {
                    this.result = this.AjaxResult(data, status, headers, config);
                    this.data = (callback && callback.setData) ? callback.setData(data, this) : data;
                    if (callback && callback.success && (angular.isUndefined(callback.stopProcessSuccess) || callback.stopProcessSuccess == false)) {
                        var o =  callback.success(this, data, status, headers, config);
                        return o;
                    }
                };

                this.processErrorAjaxResult = function (data, status, headers, config, callback) {
                    this.error = this.AjaxResult(data, status, headers, config);
                    if (callback && callback.error) {
                        return callback.error(this, data, status, headers, config);
                    }
                };

                this.get = function (url, callback, config) {
                    this.reset();
                    if (url) {
                        var thisObj = this;
                        var promise = $http.get(url, config)
                            .then(
                                function(response){
                                    if (response.data && !response.data.faultCode) {
                                        var o = thisObj.processSuccessAjaxResult(response.data, response.status, response.headers, response.config, callback);
                                        return angular.isUndefined(o) ? response.data : o;
                                    } else {
                                        return thisObj.processErrorAjaxResult(response.data, response.status, response.headers, response.config, callback);
                                    }
                                },
                                function(response) {
                                    return thisObj.processErrorAjaxResult(response.data, response.status, response.headers, response.config, callback);
                                });
                        return promise;
                    } else {
                        //alert("[AjaxService] URL to call is not set");
                        throw new Error("[AjaxService] URL to call is not set");
                    }
                };

                this.post = function (url, formData, callback, config) {
                    this.reset();
                    if (url) {
                        var thisObj = this;
                        var promise = $http.post(url, formData, config)
                            .then(
                                function(response){
                                    if (response.data && !response.data.faultCode) {
                                        var o = thisObj.processSuccessAjaxResult(response.data, response.status, response.headers, response.config, callback);
                                        return angular.isUndefined(o) ? response.data : o;
                                    } else {
                                        return thisObj.processErrorAjaxResult(response.data, response.status, response.headers, response.config, callback);
                                    }
                                },
                                function(response) {
                                    return thisObj.processErrorAjaxResult(response.data, response.status, response.headers, response.config, callback);
                                });
                        return promise;
                    } else {
                        //alert("[AjaxService] URL to call is not set");
                        throw new Error("[AjaxService] URL to call is not set");
                    }
                };

                this.load = function (callback, config) {
                    return this.get(this.url, callback, config);
                };

                this.loadByPost = function (formData, callback, config) {
                    return this.post(this.url, formData, callback, config);
                };

                this.update = function (formData, callback, config) {
                    return this.post(this.url, formData, callback, config);
                };
            }
        }])
        .service("bizflowService", function (bizflowContext, AjaxService, inform, $log) {
            var vm = this;

            vm.actionPost = function (url, formData, callback, config) {
                var ajaxAction = new AjaxService(url);
                if (angular.isDefined(formData.user) == false) {
                    formData.user = {
                        "LOGINID": bizflowContext.custom.LOGINID,
                        "MEMBERID": bizflowContext.custom.MEMBERID,
                        "MEMBERNM": bizflowContext.custom.MEMBERNAME
                    };
                }
                if (!callback.error) {
                    var title = null;
                    if (angular.isDefined(callback.APIName) == true) {
                        title = 'While calling ' + callback.APIName;
                    }
                    callback.error = function (o, data, status, headers, config) {
                        // this.informError cannot be used here.
                        vm.informError(title, formData, data, status, headers, config);
                    };
                }
                return ajaxAction.loadByPost(formData, callback, config);
            };

            vm.actionGet = function (url, callback, config) {
                var ajaxAction = new AjaxService(url);
                if (!callback.error) {
                    var title = null;
                    if (angular.isDefined(callback.APIName)) {
                        title = 'While calling ' + callback.APIName;
                    }
                    callback.error = function (o, data, status, headers, config) {
                        vm.informError(title, null, data, status, headers, config);
                    };
                }
                return ajaxAction.load(callback, config);
            };

            //overwrite angular-bizflow ajaxServiceUtil
            //if (angular.isUndefined(window.ajaxServiceUtil)) window.ajaxServiceUtil = {};
            //window.ajaxServiceUtil.actionPost = vm.actionPost;
            //window.ajaxServiceUtil.actionGet = vm.actionGet;

            vm.informError = function (_title, param, data, status, headers, config) {
                var title = (_title && _title.length > 0) ? _title : 'Unexpected error happened.';
                var faultCode = (data && data.faultCode) ? data.faultCode : null;
                var faultString = (data && data.faultString) ? data.faultString : null;

                var detail = (data && data.faultDetail && data.faultDetail.length > 0) ? ('faultDetail: ' + data.faultDetail + '\n\n') : '';

                if (faultCode) {
                    detail += 'faultCode: ' + faultCode + '\n';
                }
                if (faultString) {
                    detail += 'faultString: ' + faultString + '\n';
                }
                if (param) {
                    detail += 'param: ' + JSON.stringify(param) + '\n';
                }
                if (status) {
                    detail += 'status: ' + status + '\n';
                }

                // Nothing to display headers. headers parameter will be maintained to make similar parameter order.
                // if (headers) {}

                if (config) {
                    if (config.headers && config.headers.Accept && config.headers.Accept.length > 0) {
                        detail += 'config.headers.Accept: ' + config.headers.Accept + '\n';
                    }
                    if (config.headers && config.headers["Content-Type"] && config.headers["Content-Type"].length > 0) {
                        detail += '\nconfig.headers.Content-Type: ' + config.headers["Content-Type"] + '\n';
                    }
                    if (config.method && config.method.length > 0) {
                        detail += '\nconfig.method: ' + config.method + '\n';
                    }
                    if (config.url && config.url.length > 0) {
                        detail += '\nconfig.url: ' + config.url + '\n';
                    }
                }

                var errorHTML = '<span style="font-size:18px;font-weight:bold;color:black">Error: ' + title;
                if (faultCode) {
                    errorHTML += ' (' + faultCode + ') </span><br/>';
                } else {
                    errorHTML += '</span><br/>';
                }

                if (faultString) {
                    errorHTML += '<span style="display:inline-block;font-size:12px;padding-bottom:10px">' + faultString + '</span><br/>'
                }

                if (detail.length > 0) {
                    errorHTML += '<span style="display:inline-block;font-size:12px;font-weight:bold">Contact System Administrator with below error information.</span><br/>';
                    errorHTML += '<textarea rows="10" cols="75" style="font-size:8px;width:400px;">' + detail + '</textarea>';
                }

                inform.add(errorHTML, {ttl: -1, html: true});
            };

            vm.loginDataService = function (sessionInfoXML, callback) {
                var url = bizflowContext.getServiceUrl('/auth/login.json');
                var formData = {
                    TOKEN: sessionInfoXML
                };
                callback.APIName = 'loginDataService';
                return vm.actionPost(url, formData, callback);
            };

            vm.sessionInfo = null;

            vm.initialize = function (sessionInfoXML, callback) {
                if(!sessionInfoXML) {
                    inform.add("Your session is expired. Please login again.", {ttl:3000});
                    return;
                }
                //if sessionInfo exists, it does not make a server call.
                if(vm.sessionInfo) {
                    return vm.sessionInfo
                } else {
                    return this.loginDataService(sessionInfoXML, callback).then(function(data){
                        $log.debug("bizflowService initialize is called");
                        vm.sessionInfo = data;
                    });
                }

            };

            vm.login = function (formData, callback) {
                var url = '/bizflowsrs/services/bizflow/login.json';
                callback.APIName = 'login';
                return vm.actionPost(url, formData, callback);
            };

            vm.startProcess = function(formData, callback) {
                var url = bizflowContext.getServiceUrl('/bizflow/process/create.json');
                callback.APIName = 'startProcess';
                return vm.actionPost(url, formData, callback);
            };

            vm.getProcessVariables = function (processId, callback) {
                var url = bizflowContext.getDataServiceUrl('/get/bf.bf-GetPV.json?PROCESS_ID=' + processId);
                callback = callback || {};
                callback.APIName = 'getProcessVariables';
                callback.setData = function (data, o) {
                    o.dataMap = angularExt.objectToMap(data, "rlvntdataname");
                    return angularExt.objectToArray(data);
                };

                return vm.actionGet(url, callback, config);
            };

            vm.formDataToXmlString = function (formData) {
                var x2js = new X2JS();
                var xmlString = "<DOCUMENT>" + x2js.json2xml_str(formData) + "</DOCUMENT>";
                return angularExt.trimStringBetweenKeys(xmlString, "<$$hashKey>", "</$$hashKey>");
            };

            vm.getAttachments = function (processId, callback, autoLoad) {
                autoLoad = angular.isUndefined(autoLoad) ? true : autoLoad;
                var url = bizflowContext.getDataServiceUrl('/get/bf.GetAttachments.json?PROCESS_ID=' + processId);
                if (callback == null || angular.isDefined(callback) == false) {
                    callback = {};
                }
                callback.APIName = 'getAttachments';

                var ajaxAction = new AjaxService(url);
                if (autoLoad) {
                    ajaxAction.load(callback);
                }
                return ajaxAction;
            };

            vm.deleteAttachment = function (id, callback) {
                //To do List to handle Attachment without WIH
            };

            vm.updateAttachmentDocType = function (attachment, newDocType, metadata, callback) {
                //To do List to handle Attachment without WIH
            };

            vm.transferAttachments = function (processId1, processId2, callback) {
                //To do List to handle Attachment without WIH
            };

            // -----------------------------------------------------------------------------
            // Add custom dataService call below
            // -----------------------------------------------------------------------------
            vm.getContext = function (callback) {
                var url = '/bizflow/solutions/util/getcontext.jsp';
                callback.APIName = 'getContext';
                return vm.actionGet(url, callback);
            };

            vm.getLookupDataByFormData = function(formData, callback) {
                var url = bizflowContext.getDataServiceUrl('/get/coe.getLookup.json');
                callback.APIName = 'getLookupDataByFormData';
                return vm.actionPost(url, formData, callback);
            };

            vm.getDocumentTypeLookupData = function(callback) {
                var formData = {
                    Ltype: "Document Type"
                };
                return vm.getLookupDataByFormData(formData, callback);
            };

            vm.getWorklist = function (formData, callback) {
                var url = '/bizflowsrs/services/coe/getWorkList.json';
                callback.APIName = 'getWorklist';
                return vm.actionPost(url, formData, callback);
            };

            vm.getFormData = function (formData, callback) {
                var url = '/bizflowsrs/services/coe/getFormData.json';
                if(!callback) callback = {};
                callback.APIName = 'getFormData';
                return vm.actionPost(url, formData, callback);
            };

            vm.saveFormData = function (formData, callback) {
                var url = '/bizflowsrs/services/coe/saveFormData.json';
                if(!callback) callback = {};
                callback.APIName = 'saveFormData';
                return vm.actionPost(url, formData, callback);
            };

            vm.searchUserByName = function (formData, callback) {
                var url = '/bizflowsrs/services/data/get/coe.searchUsers.json';
                if(!callback) callback = {};
                callback.APIName = 'searchUserByName';
                return vm.actionPost(url, formData, callback);
            };

            //Lookup Manager
            vm.getTreeNodes = function (url, callback) {
                callback.APIName = 'getTreeNodes';
                return vm.actionGet(url, callback);
            };
            vm.getLookUpList = function (url, callback) {
                callback.APIName = 'getLookUpList';
                return vm.actionGet(url, callback);
            };
            vm.updateLookUp = function (formData, callback) {
                var url = "/bizflowsrs/services/data/save/coe.updateLookUp.json";
                if(!callback) callback = {};
                callback.APIName = 'updateLookUp';
                return vm.actionPost(url, formData, callback);
            };

            //Resource Manager
            vm.getResource = function (url, callback) {
                callback.APIName = 'getResource';
                return vm.actionGet(url, callback);
            };
            vm.updateResource = function (formData, callback) {
                var url = "/bizflowsrs/services/data/save/coe.updateResource.json";
                if(!callback) callback = {};
                callback.APIName = 'updateResource';
                return vm.actionPost(url, formData, callback);
            };

        });
})(window);
