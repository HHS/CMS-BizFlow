/* ===================================================================================================
* WARNING - This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on 'How do I override or clone Hyfinity webapp files such as CSS & javascript?', please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index/solution_id/1113
==================================================================================================== */

/*
 * FMActions.js
 *
 * Provides implementations of the builtin actions provided by FormMaker
 * Hyfinity Limited
 * Copyright (c) 2009
 * Version 1.1
 *
 */
hyf.FMAction =
{
    version: '1.1',
    desc: 'Contains all the functions that implement the set of inbuilt FormMaker actions'
}

/**
 * Performs a full page submission of the form.
 * Example: <b>"hyf.FMAction.handleFormSubmission( {name: ‘Action’, option: ‘Static’, value: ‘my_action’}, {name: ‘Validate’, option: ‘Static’, value: ‘true’})"</b>
 * @param actionParam {object} A param object specifies the action to call. Supported option types: ‘Static’. e.g. <b>{name: ‘Action’, option: ‘Static’, value: ‘my_action’}</b>
 * @param validateParam {object} A param object indicates whether to validate first. Supported option types: ‘Static’. e.g. <b>{name: ‘Validate’, option: ‘Static’, value: ‘true’}</b>
 * The value property must contain true for validation to occurr.
 *
 * @return {boolean} true if the form was submitted.
 *
 * @author Hyfinity Limited
 */
hyf.FMAction.handleFormSubmission = function(actionParam, validateParam)
{
    var fv = hyf.FMAction.getFormValidator();
    var f = fv.getForm();
    var action = f.action;
    if (actionParam != null && (typeof(actionParam) != 'undefined'))
    {
        action = actionParam.value + '.do';
    }

    if ((validateParam != null) && (typeof(validateParam) != 'undefined') &&
        ((validateParam.value == true) || (validateParam.value == 'true')))
    {
        if (hyf.validation.validateForm())
        {
            f.action = action;
            if (typeof(f.onsubmit) == 'function')
            {
                var resp = f.onsubmit();
                if ((typeof(resp) == 'boolean') && (resp == false))
                    return false;
            }
            f.submit();
            return true;
        }
        else
            return false;
    }
    else
    {
        f.action = action;
        if (typeof(f.onsubmit) == 'function')
        {
            var resp = f.onsubmit();
            if ((typeof(resp) == 'boolean') && (resp == false))
                return false;
        }
        f.submit();
        return true;
    }
}

/**
 * Performs an Ajax Partial Page submission of some data.
 * Example: <b>"hyf.FMAction.handleAJAXSubmission( {name: ‘Action’, option: ‘Static’, value: ‘my_action’}, {name: ‘Source’, option: ‘AllFormData’, value: ‘’}, {name: ‘Target’, option: ‘PageGroup’, value: ‘my_group_name’}, {name: ‘Validate’, option: ‘Static’, value: ‘true’})"</b>
 * @param actionParam {object} A param object specifies the action to call. Supported option types: ‘Static’. e.g. <b>{name: ‘Action’, option: ‘Static’, value: ‘my_action’}</b>
 * @param sourceParam {object} A param object indicates whether to send all the data on the page or just the data within a particular group. Supported option types: ‘AllFormData’, ‘PageGroup’. e.g. <b>{name: ‘Source’, option: ‘AllFormData’, value: ‘’}</b>
 * @param targetParam {object} A param object indicates which group to place the results into. Supported option types: ‘PageGroup’. e.g. <b>{name: ‘Target’, option: ‘PageGroup’, value: ‘my_group_name’}</b>
 * @param validateParam {object} A param object indicates whether to validate first. Supported option types: ‘Static’. The value must be true for validation to occurr. e.g. <b>{name: ‘Validate’, option: ‘Static’, value: ‘true’}</b>
 * @return {boolean} true depending on whether the partial page form was submitted.
 * Note: Partial Page submissions are fired independently, so that it will not be known if it completed.
 *
 * @author Hyfinity Limited
 */
hyf.FMAction.handleAjaxSubmission = function(actionParam, sourceParam, targetParam, validateParam, eventSourceParam)
{
    var targetGroup = targetParam.value;
    if ((typeof(targetParam.repeatId) != 'undefined') && (targetParam.repeatId != ''))
        targetGroup = targetParam.repeatId + targetGroup;

    var sourceGroup = null;
    if (sourceParam.option != 'AllFormData')
    {
        sourceGroup = sourceParam.value;
        if ((typeof(sourceParam.repeatId) != 'undefined') && (sourceParam.repeatId != ''))
            sourceGroup = sourceParam.repeatId + sourceGroup;
    }

    var functionPrefix = '';
    if (eventSourceParam.value)
        functionPrefix = eventSourceParam.value;


    if ((validateParam.value == true) || (validateParam.value == 'true'))
        hyf.FMAction.subSectionSubmit(actionParam.value, targetGroup, sourceGroup, functionPrefix, true);
    else
        hyf.FMAction.subSectionSubmit(actionParam.value, targetGroup, sourceGroup, functionPrefix, false);
}

/**
 * Sets the value of the specified field to the indicated value.
 * @param targetParam {object} A param object indicating the field whose value should be changed.
 * @param valueParam {object} A param object either containing the value to set, or specifiying which
 *                   field to get the new value from.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleSetValue = function(targetParam, valueParam, objEventSource)
{
    var targetId = targetParam.value;
    if ((typeof(targetParam.repeatId) != 'undefined') && (targetParam.repeatId != ''))
        targetId = targetParam.repeatId + targetId;

    var newValue = hyf.FMAction.getParameterValue(valueParam, objEventSource);

    if (newValue != null)
    {
        hyf.util.setFieldValue(targetId, newValue);
    }
}

/**
 * Returns the value that should be used from the given parameter object.
 * This handles the different types of values, eg from page field, script fragment
 * static value, etc.
 * This also deals with concating params that provide multiple values.
 * @param param {object} The parameter object to get the value from.
 * @return The value for the param.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.getParameterValue = function(param, objEventSource)
{
    var newValue = null;

    if (param.multiple)
    {
        newValue = '';
        var valArray = param.value;
        for (var i = 0; i < valArray.length; ++i)
        {
            newValue += hyf.FMAction.getValueFromParamObject(valArray[i], objEventSource);
        }
    }
    else
    {
        newValue = hyf.FMAction.getValueFromParamObject(param, objEventSource);
    }

    return newValue;
}

hyf.FMAction.getValueFromParamObject = function(obj, objEventSource)
{
    var val = '';
    if (obj.option == 'PageField')
    {
        var sourceId = obj.value;
        var getDisplayValue = false;

        if (sourceId.indexOf('**display_text') != -1)
        {
            sourceId = sourceId.substring(0, sourceId.indexOf('**display_text'));
            getDisplayValue = true;
        }

        if ((typeof(obj.repeatId) != 'undefined') && (obj.repeatId != ''))
            sourceId = obj.repeatId + sourceId;

        val = hyf.util.getFieldValue(sourceId, getDisplayValue);
    }
    else if (obj.option == 'Script')
    {
        val = dojo.hitch(objEventSource.field, function(){
                return eval(obj.value);
            })();
    }
    else if (obj.option == 'DisplayVariable')
    {
        val = hyf.util.getDisplayVariableValue(obj.value);
    }
    else if (obj.option == 'Boolean')
    {
        val = false;
        if (obj.value == "true")
        {
            val = true; //Note, even creating new Boolean with string "false" it returns Boolean true!!!
        }
    }
    else if (obj.option == 'NullValue')
    {
        val = null;
    }
    else if ((obj.option == 'PageFieldName') || (obj.option == 'PageGroup') || (obj.option == 'RepeatName'))
    {
        val = obj.value;
        if ((typeof(obj.repeatId) != 'undefined') && (obj.repeatId != ''))
            val = obj.repeatId + val;
    }
    else
        val = obj.value;

    return val;
}

/**
 * Toggles the visibility of the specified group.
 * @param groupParam {object} A param object indicating which group should be toggled.
 * @param animateParam {object} A param object specifying whether to animate the showing/hiding of the group.
 *                     This object's value property must be 'true' for animation to occur.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleGroupToggle = function(groupParam, animateParam)
{
    var groupId = groupParam.value;
    if ((typeof(groupParam.repeatId) != 'undefined') && (groupParam.repeatId != ''))
        groupId = groupParam.repeatId + groupId;

    //check if this is actually a dijit dialog
    if ((typeof(dijit) != 'undefined') && (typeof(dijit.byId) == 'function') && (dijit.byId(groupId)))
    {
        var w = dijit.byId(groupId);
        if (w.declaredClass == 'dijit.Dialog')
        {
            if (w.attr('open'))
                w.hide();
            else
                w.show();
            return;
        }
    }

    if (animateParam.value == 'true')
        hyf.util.toggleComponent(groupId, null, true);
    else
        hyf.util.toggleComponent(groupId, null, false);
}

/**
 * Evalautes the given custom script.
 * This is not used, as the script is just output directly into the generated function.
 * @param scriptParam {object} A param object whose value property contains the javascript string to evalaute.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleCustomScript = function(scriptParam)
{
    eval(scriptParam.value);
}

/**
 * Resets the form controls in the specific container.
 * @param containerParam {object} A param object indicating the container whose controls should be reset.
 * @param modeParam {object} A param object specifying which type of reset to perform.  The option property
 *                      of this object should be either 'reset' or 'clear'
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleContainerReset = function(containerParam, modeParam)
{
    var container = null;
    if (containerParam.option == 'Form')
        container = hyf.FMAction.getFormValidator().getForm();
    else
    {
        var contId = containerParam.value;
        if ((typeof(containerParam.repeatId) != 'undefined') && (containerParam.repeatId != ''))
            contId = containerParam.repeatId + contId;

        container = document.getElementById(contId);
    }

    hyf.util.resetContainer(container, modeParam.option);
}


/**
 * Displays an alert message with the specified content.
 * @param messageParam {object} A param object indicating the message text to display, or the
 *          script to evalaute to get the message.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleAlert = function(messageParam, objEventSource)
{
    var msg = hyf.FMAction.getParameterValue(messageParam, objEventSource);
    alert(msg);
}

/**
 * Handles calling a specified function, with a number of parameters
 * @param nameParam {object} Parameter object whose value should contain the name of the function to call.
 * @param paramsParam {object} Parameter object containing all the params to pass to the funciton when called.
 * @return The response from the function.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleFunctionCall = function(nameParam, paramsParam, objEventSource)
{
    var funcName = nameParam.value;
    var fn = eval(funcName);
    if (typeof(fn) == 'function')
    {
        var functionParams = new Array();
        if (paramsParam.multiple)
        {
            var valArray = paramsParam.value;
            for (var i = 0; i < valArray.length; ++i)
            {
                functionParams[functionParams.length] = hyf.FMAction.getValueFromParamObject(valArray[i], objEventSource);
            }
        }
        else
        {
            if (paramsParam.option != '')
                functionParams[functionParams.length] = hyf.FMAction.getValueFromParamObject(paramsParam, objEventSource);
        }

        return fn.apply(this, functionParams);
    }
}

/**
 * Package for the funcitonality related to raise custom errors
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.raiseError = {};
/**
 * Event handler for the raise error action.
 * This creates a new valdiation error for the specified field, and initialises the custom
 * message produce function so that the required message will be displayed.
 * @param errorFieldParam {object} The param object indicating which field to raise the error against.
 * @param messageParam {object} The param object indicating the custom error message to display
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.raiseError.handle = function(errorFieldParam, messageParam, objEventSource)
{
    var targetId = errorFieldParam.value;
    if ((typeof(errorFieldParam.repeatId) != 'undefined') && (errorFieldParam.repeatId != ''))
        targetId = errorFieldParam.repeatId + targetId;

    var target = document.getElementById(targetId);
    if (target != null)
    {
        //check if our custom message handler has already been registered
        if (!hyf.FMAction.raiseError.producerRegistered)
        {
            hyf.validation.DisplayMessages.addMessageProducer(hyf.FMAction.raiseError.messageProducer);
            hyf.FMAction.raiseError.producerRegistered = true;
        }

        //store the message details for future use.
        target._raiseErrorMsg = hyf.FMAction.getValueFromParamObject(messageParam, objEventSource);

        //create and register the error
        var newError = new hyf.validation.ValidationError(target, hyf.FMAction.raiseError.code);
        hyf.FMAction.getErrorDisplay().addError(newError);
    }
}

//The code used for validation errors created for custom errors
hyf.FMAction.raiseError.code = 80;
//Boolean flag used to keep track of wether or not the custom message producer function has been registered yet
hyf.FMAction.raiseError.producerRegistered = false;

/**
 * Custom message producer function for the raise error action.
 * This checks if the provided error is for the correct code,
 * and then looks for a raise error message on the field.
 * If found, this is returned as the display message to use in the valdiation process.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.raiseError.messageProducer = function(field, errorCode)
{
    if (errorCode == hyf.FMAction.raiseError.code)
    {
        if (typeof(field._raiseErrorMsg != 'undefined'))
        {
            return '' + field._raiseErrorMsg;
        }
    }
}


/**
 * Handler for the change style FM action.  This supports adding, removing or toggling a CSS
 * class name on a specific component.
 * @param targetParam {object} The param object detailing the target to chaneg the class on.
 * @param modeParam {object} The option property of this param object indicates which type of action to perform,
 *                      'add', 'remove', or 'toggle'
 * @param valueParam This provides the name of the CSS class
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleChangeStyle = function(targetParam, modeParam, valueParam, objEventSource)
{
    var targets = [];

    if (targetParam.option == 'CSSSelector')
        targets = dojo.query(targetParam.value)
    else
    {
        var targetId = targetParam.value;
        if ((typeof(targetParam.repeatId) != 'undefined') && (targetParam.repeatId != ''))
            targetId = targetParam.repeatId + targetId;

        if (targetParam.option == 'PageFieldBackground')
            targetId += '_container';
        else if ((targetParam.option == 'PageFieldLabel') || (targetParam.option == 'PageGroupLabel'))
            targetId += '_label';
        else if ((targetParam.option == 'PageFieldLabelBackground') || (targetParam.option == 'PageGroupLabelBackground'))
            targetId += '_label_container';

        if (document.getElementById(targetId))
            targets = new dojo.NodeList(document.getElementById(targetId));
    }

    if (targets.length > 0)
    {
        var className = hyf.FMAction.getParameterValue(valueParam, objEventSource);

        switch (modeParam.option)
        {
            case 'add'  :   targets.addClass(className); break;
            case 'remove':  targets.removeClass(className); break;
            case 'toggle':  targets.toggleClass(className); break;
        }
    }
}

/**
 * Sets the text content of the label for the provided field.
 * @param targetParam {object} A param object indicating the field whose label value should be changed.
 * @param valueParam {object} A param object specifying the value to use for the label.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleSetLabel = function(targetParam, valueParam, objEventSource)
{
    var targetId = targetParam.value + '_label';
    if ((typeof(targetParam.repeatId) != 'undefined') && (targetParam.repeatId != ''))
        targetId = targetParam.repeatId + targetId;

    var target = document.getElementById(targetId);

    //if target is null, try without the repeat information for the situation where we are changing
    //the label of a field in a table.
    if ((target == null) && (typeof(targetParam.repeatId) != 'undefined') && (targetParam.repeatId != ''))
    {
        targetId = targetParam.value + '_label';
        target = document.getElementById(targetId);
    }

    if (target != null)
    {
        var newValue = hyf.FMAction.getParameterValue(valueParam, objEventSource);

        if (newValue != null)
        {
            hyf.util.setFieldValue(targetId, newValue);
        }
    }
}

/**
 * Updates the value of the specified display variable.
 * @param targetParam {object} A param object indicating the display variable to update.
 * @param valueParam {object} A param object specifying the new value to use.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleSetDisplayVariable = function(targetParam, valueParam, objEventSource)
{
    var dvName = targetParam.value;
    var newValue = hyf.FMAction.getParameterValue(valueParam, objEventSource);
    hyf.util.setDisplayVariableValue(dvName, newValue);
}

/**
 * Generates the return value that should be used for the terminate action.
 * @param valueParam {object} the param object indicating the return value.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleTerminate = function(valueParam, objEventSource)
{
    var returnValue = hyf.FMAction.getParameterValue(valueParam, objEventSource);

    //convert true or false as a string to the actual boolean values.
    if (returnValue == 'true')
        return true;
    else if (returnValue == 'false')
        return false;
    return returnValue;
}

/**
 * Implements the calculation action which can calculate the addition/subtraction/multiplication/division of a number of values
 * and place the result into either a field or display variable.
 * @param targetParam {object} Param object inidicating where the result of the calculation should be placed (either field or display variable)
 * @param operatorParam {object} Param object indicating which operation should be performed. This will be determined by the option value of the object
 * @param valuesParam {object} Param object specifying all the values to process.
 * @param formatParam {object} Param specifying the format to apply to the resulting value (optional)
 * @param objEventSource
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleCalculation = function(targetParam, operatorParam, valuesParam, formatParam, objEventSource)
{
    var sourceValues = hyf.FMAction.handleCalculationFindValues(valuesParam, objEventSource);
    var op = operatorParam.option;

    var result = 0;
    if ((sourceValues[0] != null) && (typeof(sourceValues[0]) != 'undefined') && (sourceValues[0] != '') && !isNaN(sourceValues[0]))
        result = Number(sourceValues[0]);

    for( var i = 1; i < sourceValues.length; ++i)
    {
        if ((sourceValues[i] == null) || (typeof(sourceValues[i]) == 'undefined') || (sourceValues[i] == '') || isNaN(sourceValues[i]))
        {
            continue;
        }

        switch (op)
        {
            case '+' : result += Number(sourceValues[i]); break;
            case '-' : result -= Number(sourceValues[i]); break;
            case '*' : result = result * Number(sourceValues[i]); break;
            case '/' : result = result / Number(sourceValues[i]); break;
        }
    }

    //check if any format pattern has been defined
    if (formatParam.option != '')
    {
        result = dojo.number.format(result, {pattern: formatParam.value});
    }

    //check whether to update a field or display variable
    if (targetParam.option == 'PageField')
    {
        var targetId = targetParam.value;
        if ((typeof(targetParam.repeatId) != 'undefined') && (targetParam.repeatId != ''))
            targetId = targetParam.repeatId + targetId;
        hyf.util.setFieldValue(targetId, result);
    }
    else if (targetParam.option == 'DisplayVariable')
    {
        var dvName = targetParam.value;
        hyf.util.setDisplayVariableValue(dvName, result);
    }
}

/**
 * Override of the normal getParameterValue method for the calculation action so that it returns an array of all the found values,
 * rather than a single concat string
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleCalculationFindValues = function(valuesParam, objEventSource)
{
    var valuesArray = new Array();

    if (valuesParam.multiple)
    {
        var valArray = valuesParam.value;
        for (var i = 0; i < valArray.length; ++i)
        {
            valuesArray = valuesArray.concat(hyf.FMAction.handleCalculationGetValueFromParamObject(valArray[i], objEventSource));
        }
    }
    else
    {
        valuesArray = valuesArray.concat(hyf.FMAction.handleCalculationGetValueFromParamObject(valuesParam, objEventSource))
    }

    return valuesArray;
}

/**
 * Override the normal getValueFromParamObject for the calculation action so that we can handle the
 * 'all_across_repeat' option to return an array of the values for the field in each repeat entry.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.handleCalculationGetValueFromParamObject = function(obj, objEventSource)
{
    var values = new Array();
    if ((obj.option == 'PageField') && (obj.value.indexOf('**all_across_repeat') != -1))
    {
        var sourceId = obj.value;
        sourceId = sourceId.substring(0, sourceId.indexOf('**all_across_repeat'));

        //remove the ending row identifier from the repeat id
        var marker = obj.repeatId.lastIndexOf(obj.repeatName);
        var repId = obj.repeatId.substring(0, marker + obj.repeatName.length);

        var i = 1;
        var valPart = hyf.util.getFieldValue(repId + i + sourceId);
        while (valPart != null)
        {
            values[values.length] = valPart;
            ++i;
            valPart = hyf.util.getFieldValue(repId + i + sourceId);
        }
    }
    else
        values[values.length] = hyf.FMAction.getValueFromParamObject(obj, objEventSource);

    return values;
}


/**
 * Adds events to all the fields and dojo widgets on the page to enable 'as you type' validation.
 * @param container (optional) If provided, then as you type validation will only be enabled
 *              for controls within this container.  If not provided then all controls on the page
 *              will be processed.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.enableAsYouTypeValidation = function(container)
{
    //check as you type validation has been requested.
    if (hyf.validation.config.asYouType)
    {
        if (typeof(container) == 'undefined')
            container = document.body;

        dojo.query('input[type=text], input[type=password], textarea, select', container)
            .filter(function(item) {
                //filter out any controls that actually form part of a dojo form widget, as they will be handled below.
                var encWidget = (dijit && (typeof(dijit.getEnclosingWidget) == 'function')) ? dijit.getEnclosingWidget(item) : null;
                return ((encWidget == null) || (encWidget.declaredClass.indexOf('dijit.form.') == -1));
            })
            .onkeyup(hyf.FMAction.asYouTypeHandlerForKeyUp)
            .onchange(hyf.FMAction.asYouTypeHandler)
            .onfocus(hyf.FMAction.asYouTypeHandlerForFocus);
        dojo.query('input[type=checkbox], input[type=radio]', container)
            .filter(function(item) {
                //filter out any controls that actually form part of a dojo form widget, as they will be handled below.
                var encWidget = (dijit && (typeof(dijit.getEnclosingWidget) == 'function')) ? dijit.getEnclosingWidget(item) : null;
                return ((encWidget == null) || (encWidget.declaredClass.indexOf('dijit.form.') == -1));
            })
            .onkeyup(hyf.FMAction.asYouTypeHandlerForKeyUp)
            .onclick(hyf.FMAction.asYouTypeHandler)
            .onchange(hyf.FMAction.asYouTypeHandler)
            .onfocus(hyf.FMAction.asYouTypeHandlerForFocus);


        //only want to register form widgets, not layout stuff eg accordions
        var widgets = hyf.util.getDijitWidgets(container, 'dijit.form.');
        for (var i=0; i < widgets.length; ++i)
        {
            //ensure we revalidate on click of the up/down buttons for a number spinner
            if (widgets[i].declaredClass == 'dijit.form.NumberSpinner')
            {
                widgets[i].set('intermediateChanges', true);
            }
            dojo.connect(widgets[i], 'onKeyUp', widgets[i], hyf.FMAction.asYouTypeHandlerForKeyUp);
            dojo.connect(widgets[i], 'onChange', widgets[i], hyf.FMAction.asYouTypeHandler);
            dojo.connect(widgets[i], 'onFocus', widgets[i], hyf.FMAction.asYouTypeHandlerForFocus);
        }
    }
}

/** Ensure the enableAsYouTypeValidation function gets called whenever new content has been inseted.
 * We need this to happen on page load, and after any content is inserted via ajax (using insertContent method.)
 * The enableAsYouTypeValidation function process dojo widgets as well as fields, so we need to call it after
 * any widgets have been parsed.
 * @private
 * @author Hyfinity Limited
 */
dojo.connect(hyf.hooks, 'widgetsParsed', hyf.FMAction.enableAsYouTypeValidation);


/**
 * This is the handler function for any as you type validation call
 * triggered from an onfocus event. In this case we only ever
 * want to valdiate if the value is no blank.
 * @private
 */
hyf.FMAction.asYouTypeHandlerForFocus = function(e)
{
    return dojo.hitch(this, hyf.FMAction.asYouTypeHandler, e, true)();
}

/**
 * This is the handler function for any as you type validation call
 * triggered from annkeyup event.  In this case we check if the keyup event
 * was due to a tab action to the field, and if so only valdiate if not blank.
 * @private
 */
hyf.FMAction.asYouTypeHandlerForKeyUp = function(e)
{
    //dont want to validate blank value if it was a tab key up, ie have just
    //come into the field due to tab press from previous field
    var evt = e || window.event;
    var code;
    if (evt)
        code = (evt.keyCode ? evt.keyCode : evt.which);
    if ((code == 9) || (code == 16)) //tab or shift key
        return dojo.hitch(this, hyf.FMAction.asYouTypeHandler, evt, true)();
    else
        return dojo.hitch(this, hyf.FMAction.asYouTypeHandler, evt)();
}

/**
 * This is the main handler function for any as you type validation call.
 * @param e event object
 * @param onlyIfNotBlank (Optional) If true, then valdiation will only be performed if the field's
 *              value is not blank.  Defaults to false.
 * @private
 */
hyf.FMAction.asYouTypeHandler = function(e, onlyIfNotBlank)
{
    var evt = e || window.event;

    //for focus events, only want to validate if the value is blank
    //for widgets the event doesn't seem to come through for focus
    if (onlyIfNotBlank)
    {
        var fieldName = hyf.validation.ErrorDisplay.getFieldName(this);
        var value = hyf.util.getFieldValue(fieldName)
        if ((value == '') || (typeof(value) == 'number' && isNaN(value)))
        {
            return;
        }

    }

    hyf.validation.validateField(this, true);
}

/**
 * Returns the form validator object that should be used for all validation
 * functionality.
 * This currently assumes that there is only one form on the page that should be validated.
 * If needed, we can extend this to allow selection of which form should be validated, and
 * so return the correct validator object.
 * @return The hyf.validation.FormValidator object to use for validation.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.getFormValidator = function()
{
    if (typeof(hyf.FMAction.formValidator) == 'undefined')
    {
        var f;
        if (hyf.validation.config.form)
            f = hyf.validation.config.form;
        else
            f = document.forms[0];

        hyf.FMAction.formValidator = new hyf.validation.FormValidator(f);
    }

    return hyf.FMAction.formValidator;
}

/**
 * Returns the error display object that should be used for displaying any
 * validation errors
 * @return The hyf.validation.ErrorDisplay object to use for showing errors.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.getErrorDisplay = function()
{
    if (typeof(hyf.FMAction.errorDisplay) == 'undefined')
    {
        var dispMethod = 'none'
        if (typeof(hyf.validation.config.errorDisplayMethod) != 'undefined')
            dispMethod = hyf.validation.config.errorDisplayMethod;

        hyf.FMAction.errorDisplay = new hyf.validation.ErrorDisplay(dispMethod);

        /*if (typeof(hyf.validation.config.errorDisplayFieldStyle) != 'undefined')
            hyf.FMAction.errorDisplay.setFieldStyle(hyf.validation.config.errorDisplayFieldStyle);
        if (typeof(hyf.validation.config.errorDisplayFieldClass) != 'undefined')
            hyf.FMAction.errorDisplay.setFieldClass(hyf.validation.config.errorDisplayFieldClass);
        if (typeof(hyf.validation.config.errorDisplayMessageStyle) != 'undefined')
            hyf.FMAction.errorDisplay.setMessageStyle(hyf.validation.config.errorDisplayMessageStyle);
        if (typeof(hyf.validation.config.errorDisplayMessageClass) != 'undefined')
            hyf.FMAction.errorDisplay.setMessageClass(hyf.validation.config.errorDisplayMessageClass);
        if (typeof(hyf.validation.config.errorDisplayShowMessage) != 'undefined')
            hyf.FMAction.errorDisplay.setShowMessage(hyf.validation.config.errorDisplayShowMessage);*/
        if (typeof(hyf.validation.config.errorDisplayShowAlerts) != 'undefined')
            hyf.FMAction.errorDisplay.setShowAlerts(hyf.validation.config.errorDisplayShowAlerts);
        if (typeof(hyf.validation.config.errorDisplayValidationMode) != 'undefined')
            hyf.FMAction.errorDisplay.setValidationMode(hyf.validation.config.errorDisplayValidationMode);
        if (typeof(hyf.validation.config.errorDisplayMessageLocation) != 'undefined')
            hyf.FMAction.errorDisplay.setMessageLocation(hyf.validation.config.errorDisplayMessageLocation);
        if (typeof(hyf.validation.config.errorDisplayMessageString) != 'undefined')
            hyf.FMAction.errorDisplay.setMessageString(hyf.validation.config.errorDisplayMessageString);
    }

    return hyf.FMAction.errorDisplay;

}



/**
 * Main function used to handle any sub section submission functionality.
 * This is used to update part of the page by making an asynchronous call to the server for more data.
 *
 * @param URL The URL to call to retrieve the new information.
 * @param target The ID of the container in which to place the resulting HTML retrieved.
 * @param source (optional) The ID of a source container.  The contents of any input fields within this container
 *                  will be sent in the request to the remote service.
 *                  If this parameter is not present, the full details on the page will be submitted.
 * @param functionPrefix (optional) A string containing the prefix that will be used for all custom functions
 *                  related to this sub section submission.  The process will check for the presense of
 *                  three different functions that will be called if they exist:
 *                      <functionPrefix>ConfigureRequestParameters(requestParams)
 *                      <functionPrefix>SetLoadingMessage(message)
 *                      <functionPrefix>ManipulateResponse(response, successful)
 * @param validate (optional) A boolean field to indicate whether or not the data being submitted should be
 *                  first validated for compliance with the defined constraints.
 *                  If not provided, no validation will be performed.
 * @return A boolean value indicating whether or not the asynchronous call has been initiated.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.subSectionSubmit = function(URL, target, source, functionPrefix, validate)
{
    if (typeof(dojo) == 'undefined')
    {
        alert('This functionality requires the dojo framework to be available');
        return false;
    }

    //check if we need to validate the data being sent
    if (validate)
    {
        //check if we need to validate a group or the whole page
        if ((typeof(source) == 'undefined') || (source == null) || (document.getElementById(source) == null))
        {
            if (!hyf.validation.validateForm())
                return false;
        }
        else
        {
            if (!hyf.validation.validateContainer(document.getElementById(source)))
                return false;
        }
    }

    var content;

    if ((typeof(source) == 'undefined') || source == null || document.getElementById(source) == null)
    {
        //need to temporarily remove the mask values before converting the form
        hyf.validation.removeMasks();
        content = dojo.formToObject(hyf.FMAction.getFormValidator().getForm());
        hyf.validation.applyMasks();


        //if there are any dojo dialogs then these will be outside of the form so need to be manually added in
        var dialogs = hyf.util.getDijitWidgets(document.body, 'dijit.Dialog');
        for (var i = 0; i < dialogs.length; ++i)
        {
            if (dialogs[i].containerNode)
                dojo.mixin(content, hyf.util.encodeContainer(dialogs[i].containerNode));
        }

    }
    else
    {
        if (URL.indexOf('.do') != -1)
            content = hyf.util.encodeContainer(document.getElementById(source), URL.substring(0, URL.length - 3));
        else
            content = hyf.util.encodeContainer(document.getElementById(source));
    }

    var requestArgs = {
            url         :   URL,
            content     :   content,
            mimetype    :   "text/html",
            handleAs    :   "text"
            };

    //Add a hook for manipulation of the request args
    if (eval("window." + functionPrefix + 'ConfigureRequestParameters'))
        eval(functionPrefix + 'ConfigureRequestParameters(requestArgs)');

    requestArgs.handle = hyf.FMAction.subSectionHandler;
    requestArgs.hyfTarget = target;
    requestArgs.hyfFunctionPrefix = functionPrefix;

    //Display a loading message in the target container
    var loadingContent = '<span class="ajaxLoading">Loading...</span>';
    //check if the user has created a function to override this message
    if (eval("window." + functionPrefix + 'SetLoadingMessage'))
        eval('loadingContent = ' + functionPrefix + 'SetLoadingMessage(loadingContent)');

    //if the message is empty, don't change the display
    if (loadingContent != null)
        hyf.util.insertContent(document.getElementById(target), loadingContent);

    // dojo.io.bind(requestArgs); ash_change
    dojo.xhrPost(requestArgs);

    return true;
};



/**
 * Handler function called after each ajax call.
 * This is the method syntax required by dojo
 *
 * @param response The response object retreived.
 * @param ioArgs The request parameters array containing all the details used to inititate the request
 *
 * @private
 * @author Hyfinity Limited
 */
hyf.FMAction.subSectionHandler = function(response, ioArgs)
{

    var target = document.getElementById(ioArgs.args.hyfTarget);

    if(response instanceof Error)
    {
        //QUESTION: Do we want to pass the ioArgs object to the function?
        var content = "Unable to show details.  Please try again.";
        if (eval("window." + ioArgs.args.hyfFunctionPrefix + 'ManipulateResponse'))
            eval('content = ' + ioArgs.args.hyfFunctionPrefix + 'ManipulateResponse(content, false, response, ioArgs)');

        hyf.util.insertContent(target, content, true);
    }
    else
    {
        var content = response;
        //Add hook for manipulation of the response here (eg client side XSL)
        if (eval("window." + ioArgs.args.hyfFunctionPrefix + 'ManipulateResponse'))
            eval('content = ' + ioArgs.args.hyfFunctionPrefix + 'ManipulateResponse(content, true)');

        hyf.util.insertContent(target, content, true);
    }
};




hyf.FMCondition =
{
    version: '1.0',
    desc: 'Contains all the functions used to provide the inbuilt FormMaker event conditions'
}

/**
 * Validates the whole form, displaying any error found.
 * @return {boolean} indicating whether or not the valdiation was successful
 * @private
 * @author Hyfinity Limited
 */
hyf.FMCondition.checkFormValdiation = function()
{
    return hyf.validation.validateForm();
}

/**
 * Validates the specified group, displaying any error found.
 * @param groupParam {object} A param object specifying which group to try and validate
 * @return {boolean} indicating whether or not the valdiation was successful
 * @private
 * @author Hyfinity Limited
 */
hyf.FMCondition.checkGroupValdiation = function(groupParam)
{
    var groupName = groupParam.value;
    if ((typeof(groupParam.repeatId) != 'undefined') && (groupParam.repeatId != ''))
        groupName = groupParam.repeatId + groupName;

    var group = document.getElementById(groupName);
    if (group != null)
        return hyf.validation.validateContainer(group);
    else
        return false;
}

/**
 * Displays a confirmation message to the user, containing the specified message
 * @param messageParam {object} A param object specifying the message text
 * @return {boolean} indicating whether the user accepted or not.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMCondition.checkConfirm = function(messageParam, objEventSource)
{
    var msg = hyf.FMAction.getParameterValue(messageParam, objEventSource);

    return confirm(msg);
}

/**
 * Compares the given fields value to the reference, and returns the boolean result.
 * This allows for compatability with the old style conditional display setup, where a static string can contain
 * multiple values seperated by a semi colon (;) and if any of these match then the result is true.
 * @param sourceParam {object} A param object specifyinf the fields whose value should be compared.
 * @param comparisonParam {object} A param object indicating the type of comparison (eg =, !=, <, >,)
 * @param referenceParam {object} A param object indicating which reference value to use.
 * @return {boolean} indicating whether the comparison was true or not.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMCondition.checkFieldValue = function(sourceParam, comparisonParam, referenceParam, objEventSource)
{
    var option = sourceParam.option;
    var sourceField = null;
    var sourceValue = null;

    //work out whetehr this is positive type comparison or not.
    //this makes a difference when we have multiple values to check.  For example, if the comparison
    //is 'not equals' we only want to return true it it is not equal to all values
    var positiveComparison = true;
    if ((comparisonParam.option == '!=') || (comparisonParam.option == 'doesnt_contain'))
        positiveComparison = false;

    if (option == 'PageField')
    {
        var sourceId = sourceParam.value;
        if ((typeof(sourceParam.repeatId) != 'undefined') && (sourceParam.repeatId != ''))
            sourceId = sourceParam.repeatId + sourceId;

        sourceValue = hyf.util.getFieldValue(sourceId);

        sourceField = document.getElementById(sourceId);
    }
    else if (option == 'DisplayVariable')
    {
        sourceValue = hyf.util.getDisplayVariableValue(sourceParam.value);
    }
    else if (((option == 'Static') && (sourceParam.value.indexOf(';') != -1)) || ((option == 'FixedDynamic') && (sourceParam.fixedDynamicMultiple)))
    {
        sourceValue = sourceParam.value.replace(/;;/g, 'SEMI_COLON_REPLACEMENT');
        sourceValue = sourceValue.replace(/;/g, 'SEPARATOR_MARKER');
        sourceValue = sourceValue.replace(/SEMI_COLON_REPLACEMENT/g, ';');
        sourceValue = sourceValue.split('SEPARATOR_MARKER');
    }
    else
    {
        sourceValue = sourceParam.value;
    }

    if (sourceValue != null)
    {
        //make sure we always have an array of values
        if (Object.prototype.toString.call(sourceValue) !== '[object Array]')
            sourceValue = [sourceValue];

        for (var i = 0; i < sourceValue.length; ++i)
        {
            var sv = sourceValue[i];

            var refValue;
            if (((referenceParam.option == 'Static') && (referenceParam.value.indexOf(';') != -1)) || ((referenceParam.option == 'FixedDynamic') && (referenceParam.fixedDynamicMultiple)))
            {
                refValue = referenceParam.value.replace(/;;/g, 'SEMI_COLON_REPLACEMENT');
                refValue = refValue.replace(/;/g, 'SEPARATOR_MARKER');
                refValue = refValue.replace(/SEMI_COLON_REPLACEMENT/g, ';');
                refValue = refValue.split('SEPARATOR_MARKER');
            }
            else
                refValue = hyf.FMAction.getParameterValue(referenceParam, objEventSource);

            if (refValue != null)
            {
                //make sure we always have an array of values
                if (Object.prototype.toString.call(refValue) !== '[object Array]')
                    refValue = [refValue];

                for (var j = 0; j < refValue.length; ++j)
                {
                    var rv = refValue[j];

                    var dataType = 'unknown';
                    if (sourceField != null)
                        dataType = sourceField.getAttribute('_type');
                    if (dataType == 'date')
                    {
                        //both values should be in the data format

                        //handle the special case where the ref value is actually from another date field, and if
                        //so we need to convert the value based on that fields details
                        if (!referenceParam.multiple && referenceParam.option == 'PageField')
                        {

                            var refFieldId = referenceParam.value;
                            if ((typeof(referenceParam.repeatId) != 'undefined') && (referenceParam.repeatId != ''))
                                refFieldId = referenceParam.repeatId + refFieldId;
                            var refField = document.getElementById(refFieldId);

                            var result = hyf.util.compareValues(sv, rv, comparisonParam.option, 'date', sourceField.getAttribute("_data_date_format"), refField.getAttribute("_data_date_format"));
                            if (result == positiveComparison)
                                return result;
                        }
                        else
                        {
                            var result = hyf.util.compareValues(sv, rv, comparisonParam.option, 'date', sourceField.getAttribute("_data_date_format"));
                            if (result == positiveComparison)
                                return result;
                        }
                    }
                    else
                    {
                        var result = hyf.util.compareValues(sv, rv, comparisonParam.option, dataType);
                        if (result == positiveComparison)
                            return result;
                    }
                }
            }
        }
    }
    return !positiveComparison;
}


/**
 * Checks if the specified key was pressed to trigger the event
 * @param keyParam {object} A param object specifying the key to check for
 * @return {boolean} indicating whether the key was pressed or not
 * @private
 * @author Hyfinity Limited
 */
hyf.FMCondition.checkKeyPress = function(keyParam, objEventSource)
{
    var keyChar = objEventSource.event.charCode ? String.fromCharCode(objEventSource.event.charCode) : '';

    var testValue = (keyParam.option == 'enter_key') ? dojo.keys.ENTER : hyf.FMAction.getParameterValue(keyParam, objEventSource);

    if ((keyChar == testValue) || (objEventSource.event.keyCode == testValue))
        return true;
    else
        return false;

}

/**
 * Simple handler function for the Dynamic Check condition.
 * In this case the actual checking will have already been done by the XSL, so just need to check its resulting
 * value to determine whther to return true or false.
 * @param conditionParam {object} A prarm object containing the result of the dynamic check
 * @return {boolean} indicating the result of the dynamic check done during the rendering process.
 * @private
 * @author Hyfinity Limited
 */
hyf.FMCondition.checkDynamicCondition = function(conditionParam)
{
    if (conditionParam && ((conditionParam.value == true) || (conditionParam.value == 'true')))
        return true;
    else
        return false;
}



//------------------------------------------------------------------------------------------------
// BizFlow specific events functionality
// QUESTION: Should this be put into a seperate file?
hyf.HSGAction = {};


hyf.HSGAction.handleWIHAction = function(actionParam, responseParam, objEventSource)
{
    var functionName = actionParam.value;

    if (functionName != '')
    {
        try
        {
            if (functionName == 'respond')
            {
                if (responseParam && (responseParam.name == 'Response') && (responseParam.option != 'Default'))
                    basicWIHActionClient.respond(hyf.FMAction.getParameterValue(responseParam, objEventSource));
                else
                    basicWIHActionClient.respond();
            }
            else
            {
                if ((functionName == 'complete') || (functionName == 'setResponseName'))
                {
                    if (responseParam && (responseParam.name == 'Response') && (responseParam.option != 'Default'))
                    {
                        var requestedResp = hyf.FMAction.getParameterValue(responseParam, objEventSource)
                        if(!basicWIHActionClient.setResponseByName(requestedResp))
                        {
                            //couldn't set the response to the requested value - what should we do here?
                            return false;
                        }
                    }

                    if (functionName == 'setResponseName')
                        return true; //dont need to call any other scripts for this action

                }

                var scriptToEval = 'basicWIHActionClient.' + functionName + '()';
                eval(scriptToEval);
                return true;
            }
        }
        catch (e)
        {
            //we ignore errors here, as the most likely cause is that the page is not actually
            //being run within the WIH environment.
            return false;
        }
    }
}

hyf.HSGAction.handleWIHFlowControl = function(controlParam)
{
    var flowControl = controlParam.option;

    if ((flowControl != null) && (flowControl != ''))
    {
        try
        {
            if (flowControl == 'stop')
                basicWIHActionClient.setStop();
            else if (flowControl == 'wait')
                basicWIHActionClient.setWait();
            else if (flowControl == 'continue')
                basicWIHActionClient.setContinue();

            return true;
        }
        catch (e)
        {
            //we ignore errors here, as the most likely cause is that the page is not actually
            //being run within the WIH environment.
            return false;
        }
    }
}
