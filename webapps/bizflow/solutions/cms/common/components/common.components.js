(function () {
    'use strict';

    angular
        .module( 'bizflow.angular.component',
            [
                'bizflow.angular.context',
                'bizflow.angular.wih',
                'angularFileUpload',
                'blockUI',
                'ui.select',
                'ngSanitize'
            ]
        );
})();
