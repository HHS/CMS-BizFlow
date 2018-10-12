/* global $ CMS_REPORT_FILTER */

(function (angular) {
    'use strict';

angular.module('bizflow.app', [
    'ngRoute',
     'ngSanitize',
     'blockUI',
    //  'ngAria',
     'ngAnimate',
     'ngCookies',
     'inform',
     'inform-exception',
     'ui.bootstrap',
    //  'ui.select',
     'selectize',
     'ui.grid',
     'ui.grid.selection',
     'ui.grid.pagination',
     'ui.grid.autoResize',
     'ui.grid.resizeColumns',
     // 'jsonFormatter',
     'ngMessages',
     'bizflow.angular.context',
     'bizflow.angular.wih',
     'bizflow.angular.service',
     'bizflow.angular.component',
     'bizflow.app.common'])
    .factory('timeoutHttpIntercept', function (inform) {
        return {
            'request': function (config) {
                config.timeout = 600000; // increase timeout for Excel download operation
                return config;
            },
            'responseError': function (responseError) {
                if (responseError.status === -1 || responseError.status === 499 || responseError.status === 598 || responseError.status === 599) {
                    inform.add('Error: Time out', {type: 'danger'})
                }
                return responseError;
            }
        };
    })
    .config(['$httpProvider', 'blockUIConfig', 'bizflowContextProvider', 'informProvider', '$compileProvider',
                '$routeProvider', '$logProvider', '$locationProvider', // 'JSONFormatterConfigProvider'
        function ($httpProvider, blockUIConfig, bizflowContextProvider, informProvider, $compileProvider,
                    $routeProvider, $logProvider, $locationProvider /* JSONFormatterConfigProvider */) {
            // https://stackoverflow.com/questions/41211875/angularjs-1-6-0-latest-now-routes-not-working
            $locationProvider.hashPrefix('');

            // Turn on or off debugging message
            $logProvider.debugEnabled(true);
            bizflowContextProvider.custom.debugEnabled = $logProvider.debugEnabled();
            bizflowContextProvider.custom.formStyle = 'tab';

            // Enable the hover preview feature
            // JSONFormatterConfigProvider.hoverPreviewEnabled = true;

            $httpProvider.interceptors.push('timeoutHttpIntercept');

            blockUIConfig.autoBlock = true;
            blockUIConfig.delay = 0;
            blockUIConfig.message = 'Please Wait...';
            // Disable auto body block(This is important! if it's value is true then browser will be flickering on ie 9 and ie 10)
            blockUIConfig.autoInjectBodyBlock = false;
            // ... don't block it.
            blockUIConfig.requestFilter = function (config) {
            };

            // $locationProvider.html5Mode(true);//it doesn't work for IE10

            // Need to change bizflowsrs context patch if it is not default value bizflowsrs
            bizflowContextProvider.setServiceContextPath('/bizflowsrs/services');
            bizflowContextProvider.setDataServiceContextPath('/bizflowsrs/services');
            bizflowContextProvider.setAppContextPath('/bizflow/solutions/cms');

            informProvider.defaults({ttl: 0, type: 'danger'});

            // need to set as false for PRODUCTION SERVER to speed up
            // https://docs.angularjs.org/guide/production
            $compileProvider.debugInfoEnabled(false);

            $routeProvider
                .when('/reportFilter', {
                    template: '<report-filter></report-filter>'
                })
                .when('/incentiveReportFilter', {
                    template: '<incentive-report-filter></incentive-report-filter>'
                })
                .otherwise({
                    template: '<h1>None</h1><p>Invalid Path Name.</p>'
                });
        }
    ])
    .controller('CtrlAppMain', function ($route, $scope, $location, bizflowContext, bizflowService, $document, $window, $rootScope, $log, bizflowWih) {
        var vm = this;
        vm.bizflowContext = bizflowContext;

        $scope.$ctrl = vm;
        $scope.isContextLoaded = true;

        // trigger destroy events for all children when window is switched or closed
        $window.onbeforeunload = function () {
            $rootScope.$destroy();
        };
        $scope.$on('$destroy', function () {
            $log.info('CtrlAppMain $scope $destroy');
        });

        vm.preventBackspace = function () {
            // Prevent backspace from navigating back in AngularJS in IE
            $document.on('keydown', function (event) {
                if (event.keyCode === 8) {
                    var doPrevent = true;
                    var types = ['text', 'password', 'file', 'search', 'email', 'number', 'date', 'color', 'datetime', 'datetime-local', 'month', 'range', 'search', 'tel', 'time', 'url', 'week'];
                    var d = $(event.srcElement || event.target);
                    var disabled = d.prop('readonly') || d.prop('disabled');
                    if (!disabled) {
                        if (d[0].isContentEditable) {
                            doPrevent = false;
                        } else if (d.is('input')) {
                            var type = d.attr('type');
                            if (type) {
                                type = type.toLowerCase();
                            }
                            if (types.indexOf(type) > -1) {
                                doPrevent = false;
                            } else if (d[0].outerHTML.indexOf('textbox') > -1) {
                                doPrevent = false;
                            } else if (d[0].outerHTML.indexOf('text-box') > -1) {
                                doPrevent = false;
                            }
                        } else if (d.is('textarea')) {
                            doPrevent = false;
                        }
                    }
                    if (doPrevent) {
                        event.preventDefault();
                    }
                }
            });
        }

        vm.init = function () {
            $log.info('app.main init is called');

            $log.debug('CURUSERID [' + CMS_REPORT_FILTER.CURUSERID + ']');
            $log.debug('CURUSERNAME [' + CMS_REPORT_FILTER.CURUSERNAME + ']');
            // $log.debug(CMS_REPORT_FILTER.SESSION + ']');
            $log.debug('REPORTNAME [' + CMS_REPORT_FILTER.REPORTNAME + ']');
            $log.debug('GROUPS [' + CMS_REPORT_FILTER.GROUPS + ']');
            $log.debug('REPORTPATH [' + CMS_REPORT_FILTER.REPORTPATH + ']');
            $log.debug('OPTION [' + CMS_REPORT_FILTER.OPTION + ']');

            vm.preventBackspace();

            if (angular.isUndefined(bizflowContext.custom)) bizflowContext.custom = {};
            bizflowContext.custom.SESSIONINFO = CMS_REPORT_FILTER.SESSION;
            bizflowContext.custom.MEMBERID = CMS_REPORT_FILTER.CURUSERID;
            bizflowContext.custom.MEMBERNAME = CMS_REPORT_FILTER.CURUSERNAME;
        };

        vm.init();
    });
})(window.angular);
