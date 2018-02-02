(function () {
    'use strict';

    angular
        .module( 'bizflow.app.common',
            [
                'bizflow.angular.context',
                'bizflow.angular.wih',
                'angularFileUpload',
                'blockUI',
                'ui.select',
                'ngSanitize',
                'angularFileUpload',
                'bizflow.angular.component',
                'bizflow.angular.service'
            ]
        );
})();
