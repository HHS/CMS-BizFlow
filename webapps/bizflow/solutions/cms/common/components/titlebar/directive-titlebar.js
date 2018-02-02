(function () {
    'use strict';

    /**
     * This component displays title bar with label and action buttons.
     * @directive bfTitlebar
     * @memberOf module:"bizflow.angular.component"
     *
     * @param {String} ngTitle Title string
     * @param {Array} ngModel Titlebar configuration
     *
     * @example
     * <bf-titlebar ng-title="bf-titlebar sample title" ng-model="$ctrl.titleBars"></bf-titlebar>
     *
     * @example
     * vm.titleBars = [{
     *      buttonName: 'Complete',
     *      icon: 'glyphicon-ok-sign',
     *      onClick: '$ctrl.showMessage('Complete')',
     *      visible: true,
     *      disable: false
     *  },{
     *      buttonName: 'Forward',
     *      icon: 'glyphicon-step-forward',
     *      onClick: '$ctrl.showMessage('Forward')',
     *      visible: true,
     *      disable: true
     * },{
     *      buttonName: 'Save',
     *      icon: 'glyphicon-floppy-disk',
     *      onClick: '$ctrl.showMessage('Save')',
     *      visible: false,
     *      disable: false
     * },{
     *      buttonName: 'Exit',
     *      icon: 'glyphicon-log-out',
     *      onClick: '$ctrl.showMessage('Exit')',
     *      visible: true,
     *      disable: false
     * }];
     */

    angular.module('bizflow.angular.component')
    .directive('bfTitlebar', ['$compile', '$parse', '$uibModal', '$http', 'bizflowWih', 'bizflowContext', function ($compile, $parse, $uibModal, $http, bizflowWih, bizflowContext) {
        return {
            restrict: 'E',
            replace: true,
            scope: {
                ngTitle: "@",
                ngModel: "=",
                ngVersion: "="
            },
            templateUrl: bizflowContext.appContextPath + '/common/components/titlebar/tpl-titlebar.html',
            compile: function compile(tElement, tAttrs, transclude) {
                return {
                    pre: function preLink($scope, $elem, $attr, $controller) {
                        $scope.titleBars = $scope.ngModel;
                        $scope.sourceVersion = $scope.ngVersion;

                        $scope.btnClick = function (param) {
                            if (param.indexOf("bizflowWih") === 0) {
                                eval(param);
                            } else if (param && angular.isDefined($scope.$parent.$eval(param))) {
                            }
                        };

                        $scope.btnDisable = function (param) {
                            if (typeof(param) == "boolean") {
                                return param;
                            } else if (typeof(param) == "string") {
                                return $scope.$parent.$eval(param);
                            }
                            return false;
                        };

                        $scope.btnShow = function (param) {
                            if (typeof(param) == "boolean") {
                                return param;
                            } else if (typeof(param) == "string") {
                                return $scope.$parent.$eval(param);
                            }
                            return true;
                        };
                    }
                }
            }
        };
    }]);

})();
