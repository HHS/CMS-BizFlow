(function () {
    'use strict';

    /**
     * This component displays label with icon and data.<br>
     *
     * @component bfInfobar
     * @memberOf module:"bizflow.angular.component"
     *
     * @param {Array} ngModel Inforbar configuration
     *
     * @example
     * <bf-infobar ng-model="$ctrl.infoBars"></bf-infobar>
     *
     * @example
     * vm.infoBars = [
     *    {labelName: 'Label1', icon: 'glyphicon-transfer', size: 'col-md-2', value: 'Hello'},
     *    {labelName: 'Label2', icon: 'glyphicon-barcode',  size: 'col-md-3', value: 'There'},
     *    {labelName: 'Label3', icon: 'glyphicon-calendar', size: 'col-md-3', value: '12345'}
     *];
     */
    angular
        .module( 'bizflow.angular.component')
        .component('bfInfobar', {
            templateUrl: function ($element, $attrs, bizflowContext) {
                return bizflowContext.appContextPath + '/common/components/infobar/tpl-infobar.html';
            },
            bindings: {
                ngModel:"<?"
            },
            controller: Ctrl
        });

    function Ctrl($log) {
        var vm = this;

        vm.$onInit = function(){
            $log.debug('bfInfobar $onInit is called');
        };

        vm.$onDestroy = function(){
            $log.debug('bfInfobar $onDestroy is called');
        };
    }

})();
