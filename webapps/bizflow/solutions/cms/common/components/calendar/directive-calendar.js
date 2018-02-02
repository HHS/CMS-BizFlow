/**
 * Calendar directive.
 *
 * @directive bfCalendar
 * @memberOf module:"bizflow.angular.component"
 *
 * @param {Date} ngModel Date variable
 * @param {String} format Date format string.<br>Refer {@link https://angular-ui.github.io/bootstrap/|ui.bootstrap.dateparser}
 * @param {Boolean} ngDisabled Disabled or not
 * @param {Boolean} ngRequired Required or not
 * @param {Function} ngChange Callback function triggering when the date is changed.
 *
 * @example
 * <bf-calendar ng-model="$ctrl.bfCalendarVariable"></bf-calendar>
 *
 * <bf-calendar ng-model="$ctrl.bfCalendarVariable"
 *              format="yyyy/mm/dd"></bf-calendar>
 *
 * <bf-calendar ng-model="$ctrl.bfCalendarVariable"
 *              format="yyyy/mm/dd"
 *              ng-disabled="true"></bf-calendar>
 */
angular.module('bizflow.angular.component')
    .directive('bfCalendar', ['$compile', '$parse', 'bizflowContext', function ($compile, $parse, bizflowContext) {

        return {
            restrict: 'E',
            replace: true,
            scope: {
                ngModel: "=",
                format: "@",
                ngDisabled: "=",
                ngRequired: "=",
                ngChange: "="
            },
            templateUrl: bizflowContext.appContextPath + '/common/components/calendar/tpl-calendar.html',
            compile: function compile(tElement, tAttrs, transclude) {
                return {
                    pre: function preLink($scope, $elem, $attr, $controller) {
                        var point = $attr.ngModel.lastIndexOf(".");
                        if (point > 0)
                            $scope.ngModelName = $attr.ngModel.substring(point + 1, $attr.ngModel.length);
                        else
                            $scope.ngModelName = $attr.ngModel;

                        $scope.modelFlagName = $scope.$eval($scope.ngModelName + "OpenedTo");

                        $scope.modelFlagName = false;

                        if (angular.isUndefined($attr.minimumdate)) {
                            $scope.minDate = null;
                        } else {
                            $scope.minDate = new Date();
                        }

                        if (angular.isUndefined($attr.maximumdate)) {
                            $scope.maxDate = null;
                        } else {
                            $scope.maxDate = new Date();
                        }

                        $scope.datepickerPopup = function ($event, opened) {
                            $scope.ngModel = $scope.ngModel || "";

                            $event.preventDefault();
                            $event.stopPropagation();
                            $scope.modelFlagName = true;
                        }
                    }
                }
            }
        };
    }]);

