
(function (angular) {
    'use strict';
    /**
     * bizflow.angular.component
     * @module "bizflow.angular.component"
     */

    /**
     * This directive can be added to modal dialog and enable modal dialog to move.
     * @directive draggable
     * @memberOf module:"bizflow.angular.component"
     * @example
     * vm.openCallProvider = function (e, dataItem) {
     *       $uibModal.open({
     *           template: '<provider-assessment ' +
     *                           'draggable ' +
     *                           '$close="$close(result)" ' +
     *                           'form-details="$ctrl.formDetails" ' +
     *                           'selected-provider="$ctrl.selectedProvider" >' +
     *                       '</provider-assessment>'
     *           , backdrop: 'static'
     *           , keyboard  : false
     *           , animation: true
     *           , size: 'lg'
     *           , controller: function () {  // Modal controller's attribute.
     *               this.loc = vm.loc;
     *               this.formDetails = vm.formDetails;
     *               this.selectedProvider = angular.isDefined(dataItem) ? dataItem : null
     *           }
     *           , controllerAs: '$ctrl'
     *       }).result.then(function (result) {
     *           if (result) {
     *               // Step5 doesn't have provider grid.
     *               if (vm.isStep3 == true || vm.isStep4 == true) {
     *                   dataItem.isChecked = 'Y';
     *                   vm.clickSelected(dataItem);
     *               }
     *               vm.updateButtons();
     *           }
     *       });
     *   };
     *
     */
    angular.module('bizflow.angular.component').directive('draggable', function() {
        return {
            restrict: 'EA',
            link: function() {
                $(".modal-dialog").draggable({
                    scroll: false,
                    handle:".draggable-screen-title"
                });
            }
        }
    });

    /**
     * This directive can set maximum size of text for textarea or input.
     * @directive limitTo
     * @memberOf module:"bizflow.angular.component"
     * @example
     * <textarea limit-to="5" ng-model="$ctrl.textAreaVariable"></textarea>
     */
    angular.module('bizflow.angular.component').directive('limitTo', function () {
        return {
            restrict: "A",
            require: 'ngModel',
            link: function (scope, element, attrs, ctrl) {
                attrs.$set("ngTrim", "false");
                scope.setMaxLength = function() {
                    var maxLength = parseInt(attrs.limitTo, 10);
                    ctrl.$parsers.push(function (value) {
                        if (value.replace(/[\0-\x7f]|([0-\u07ff]|(.))/g,"$&$1$2").length > maxLength) {
                            value = angularExt.cutStringByLength(value, maxLength);
                            ctrl.$setViewValue(value);
                            ctrl.$render();
                        }
                        return value;
                    });
                };

                attrs.$observe('limitTo', function(newMaxLength) {
                    ctrl.$parsers = [];
                    scope.setMaxLength();
                });
            }
        };
    });

    /**
     * This directive can set event handler for key "Enter".
     * @directive ngEnter
     * @memberOf module:"bizflow.angular.component"
     * @example
     * <input type="text" ng-enter="$ctrl.doEnterKey()">
     * </input>&nbsp;
     * <span ng-if="$ctrl.enterPressed == true" class="glyphicon glyphicon-flag"></span>
     * @example
     * vm.enterPressed = false;
     * vm.doEnterKey = function() {
     *    vm.enterPressed = true;
     *    alert('Detected Enter key pressed!');
     * };
     */
    angular.module('bizflow.angular.component').directive('ngEnter', function () {
            return {
                restrict: "A",
                link: function (scope, element, attrs) {
                    element.on("keydown keypress", function (event) {
                        if (event.which === 13) {
                            scope.$apply(function () {
                                scope.$eval(attrs.ngEnter);
                            });
                            event.preventDefault();
                        }
                    });
                }
            }
        });

    angular.module('bizflow.angular.component').directive('iframeSetMaxHeightOnload', ['$interval', function ($interval) {
            return {
                restrict: 'A',
                link: function (scope, element, attrs) {
                    element.on('load', function () {
                        $interval(function () {
                            var winHeight = $(window).height();
                            var offset = attrs["maxHeightOffset"] || 0;
                            var newHeight = winHeight - parseInt(offset);
                            element.css('height', newHeight);
                        }, 500);
                    })
                }
            }
        }]);

    angular.module('bizflow.angular.component').directive('setMaxHeight', function ($window) {
            return {
                restrict: 'A',
                link: function (scope, elem, attrs) {
                    var winHeight = $(window).height();
                    var offset = attrs["maxHeightOffset"] || 0;
                    elem.css('height', winHeight - offset + 'px');
                    elem.css('overflow', attrs["overflow"] || 'auto');
                }
            };
        });

    /**
     * This directive can make the element with this directive focused on loading.
     * @directive focusMe
     * @memberOf module:"bizflow.angular.component"
     * @example
     * <input type="text" focus-me="true"></input>
     */
    angular.module('bizflow.angular.component').directive('focusMe', function ($timeout) {
            return {
                scope: {trigger: '@focusMe'},
                link: function (scope, element) {
                    scope.$watch('trigger', function (value) {
                        if (value === "true") {
                            $timeout(function () {
                                element[0].focus();
                            });
                        }
                    });
                }
            };
        });

    angular.module('bizflow.angular.component')
        .directive('errorDetail', ['bizflowContext', function (bizflowContext) {
            return {
                restrict: 'EA',
                scope: {
                    name: '=',
                    message: '=',
                    error: '=data',
                    retry: '='
                },
                templateUrl: bizflowContext.appContextPath + '/common/components/html/error-detail.html',
                controller: function ($scope, $element) {
                    $scope.id = angularExt.makeSafeId($scope.name);
                }
            };
        }]);


    /**
     * Change object to number.
     * @filter objectToNumber
     * @memberOf module:"bizflow.angular.component"
     */
    angular.module('bizflow.angular.component')
        .filter('objectToNumber', function () {
            return function (item) {
                return Number(item);
            };
        });

    /**
     * Generate safe ID by replacing the characters, colon(:), (slash)/, (back-slash)\ to underscore (_).
     * @filter makeSafeId
     * @memberOf module:"bizflow.angular.component"
     * @example
     * <span>{{'a12/34' | makeSafeId}}</span>
     * @example
     * output: a12_34
     */
    angular.module('bizflow.angular.component')
        .filter('makeSafeId', function () {
            return function (id) {
                return angularExt.makeSafeId(id);
            };
        });

    /**
     * Replace string.
     * @filter replaceString
     * @memberOf module:"bizflow.angular.component"
     * @example
     * <span>{{'123abc789' | replaceString:'abc':'456'}}</span>
     * @example
     * output: 123456789
     */
    angular.module('bizflow.angular.component')
        .filter('replaceString', function () {
            return function (item, a, b) {
                if (item && item.replace) {
                    item = item.replace(new RegExp(a, "g"), b);
                }

                return item;
            };
        });

    angular.module('bizflow.angular.component')
        .filter('trustAsResourceUrl', ['$sce', function ($sce) {
            return function (val) {
                return $sce.trustAsResourceUrl(val);
            };
        }]);

    angular.module('bizflow.angular.component')
        .filter('makeDate', function () {
            return function (val) {
                return angular.isDate(val) ? val : new Date(val);
            };
        });

    angular.module('bizflow.angular.component')
        .filter('ifInvalid', function () {
            return function (input, defaultValue) {
                if (angular.isUndefined(input) || input === null || input === '' || (input instanceof Date && "Invalid Date" == input.toString())) {
                    return defaultValue;
                }
                return input;
            }
        });

})(window.angular);
