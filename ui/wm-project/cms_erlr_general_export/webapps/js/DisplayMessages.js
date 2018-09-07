/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on 'How do I override or clone Hyfinity webapp files such as CSS & javascript?', please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index/solution_id/1113
==================================================================================================== */

/*
 * DisplayMessages.js
 *
 * Company: Hyfinity Ltd
 * Copyright (c) 2003
 *
 * Class that generates display messages for a given error code
 * Will need to be replaced to create custom messages.
 *
 * Author Gerard Smyth
 * Version 1.1
 *
 */

hyf.validation.DisplayMessages = {
    messageProducers : {}
}

/**
 * Adds a message producer function that should be used to try and determine the error message
 * to display for the particular type of error.
 * When a message is being requested of this type, then each producer function added will be called
 * in the order they were added.  The first one that returns a message string will be used as the message
 * to be displayed.  When called, each function will be passed 2 parameters, the HTML field that the error
 * message should be found for, and the error code indicating the type of error
 * Producer functions for a specific error code will be called before any generic message producers.
 * If none of the producer functions defined return a message, then the default functionality will be used.
 * @param func {function} A reference to the message producer function.
 * @param errorCode {string} The code value indicating the type of errors that this message producer can deal with.
 *                  If this is not provided, then the function will be associated with all types of error.
 */
hyf.validation.DisplayMessages.addMessageProducer = function(func, errorCode)
{
    if ((errorCode == null) || (typeof(errorCode) == 'undefined'))
        errorCode = 'ALL';

    if (typeof(hyf.validation.DisplayMessages.messageProducers[errorCode]) == 'undefined')
        hyf.validation.DisplayMessages.messageProducers[errorCode] = new Array();

    hyf.validation.DisplayMessages.messageProducers[errorCode].push(func);
}

/**
 * Get the message associated with the test that this field has failed
 * This will call any defined message producer functions as needed to find the relevant message to display.
 * @param field The form object (input control, textarea, etc) that has failed the validation
 * @param errorCode The code number indicating the type of field - see validationError
 * @private
 * @return the message that should be displayed for this error.
 */
hyf.validation.DisplayMessages.getMessage = function(field, errorCode)
{
    //check if there is a message override specified for this field
    var msgCheckField = field;
    if ((msgCheckField.type == 'radio') || ((msgCheckField.type == 'checkbox') && (hyf.util.getWebMakerAttribute(msgCheckField, 'use') == 'selectMany')))
    {
        var cb = hyf.util.getFieldControlBody(msgCheckField);
        msgCheckField = dojo.query('input[name="' + msgCheckField.name + '"]', cb)[0];
    }

    var overrideMsg = hyf.util.getWebMakerAttribute(msgCheckField, 'error-msg');
    if (overrideMsg != null)
        return overrideMsg;


    //first check for any specifc message producers
    if (typeof(hyf.validation.DisplayMessages.messageProducers[errorCode]) != 'undefined')
    {
        for(var i = 0; i < hyf.validation.DisplayMessages.messageProducers[errorCode].length; ++i)
        {
            var func = hyf.validation.DisplayMessages.messageProducers[errorCode][i];
            var msg = func(field, errorCode);
            if ((msg != null) && (typeof(msg) == 'string'))
                return msg;
        }
    }

    //now check for any generic message producers
    if (typeof(hyf.validation.DisplayMessages.messageProducers['ALL']) != 'undefined')
    {
        for(var i = 0; i < hyf.validation.DisplayMessages.messageProducers['ALL'].length; ++i)
        {
            var func = hyf.validation.DisplayMessages.messageProducers['ALL'][i];
            var msg = func(field, errorCode);
            if ((msg != null) && (typeof(msg) == 'string'))
                return msg;
        }
    }

    //none of the defined message producers want to give a messge for this error, so use the default functionality
    return hyf.validation.DisplayMessages.getDefaultMessage(field, errorCode);
}

/**
 * Returns the display message that would be given for the deefined error if no message producers override it.
 * @param field The form object (input control, textarea, etc) that has failed the validation
 * @param errorCode The code number indicating the type of field - see validationError
 * @return the default message that should be displayed for this error.
 * @private
 */
hyf.validation.DisplayMessages.getDefaultMessage = function(field, errorCode)
{
    switch (errorCode)
    {
        case hyf.validation.ValidationError.ERROR_INVALID_TYPE :
                    return hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "Type attribute is invalid.");
        case hyf.validation.ValidationError.ERROR_REQUIRED :
                    return hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "You must specify a value for this field.");
        case hyf.validation.ValidationError.ERROR_NAN :
                    return hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "This value must represent a valid number.");
        case hyf.validation.ValidationError.ERROR_INVALID_DATE :
                    var msg = hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "This value must be a valid date in the format") + " ";
                    if (field.getAttribute("_error_data_format_display") && (field.getAttribute("_error_data_format_display") != ''))
                         return msg + field.getAttribute("_error_data_format_display").toUpperCase()+".";
                    else if (field.getAttribute("_display_date_format") && (field.getAttribute("_display_date_format") != ''))
                         return msg + field.getAttribute("_display_date_format").toUpperCase()+".";
                    else
                         return msg + field.getAttribute("_data_date_format").toUpperCase()+".";
        case hyf.validation.ValidationError.ERROR_INVALID_TIME :
                    var msg = hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "This value must be a valid time in the format") + " ";
                    if (field.getAttribute("_error_data_format_display") && (field.getAttribute("_error_data_format_display") != ''))
                         return msg + field.getAttribute("_error_data_format_display").toUpperCase()+".";
                    else if (field.getAttribute("_display_date_format") && (field.getAttribute("_display_date_format") != ''))
                         return msg + field.getAttribute("_display_date_format").toUpperCase()+".";
                    else
                         return msg + field.getAttribute("_data_date_format").toUpperCase()+".";
        case hyf.validation.ValidationError.ERROR_MAX_INCLUSIVE :
                    return hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "This value cannot be greater than") + " " + field.getAttribute("_maxInclusive") + ".";
        case hyf.validation.ValidationError.ERROR_MAX_EXCLUSIVE :
                    return hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "This value must be less than") + " " + field.getAttribute("_maxExclusive") + ".";
        case hyf.validation.ValidationError.ERROR_MIN_INCLUSIVE :
                    return hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "This value cannot be less than") + " "+field.getAttribute("_minInclusive")+".";
        case hyf.validation.ValidationError.ERROR_MIN_EXCLUSIVE :
                    return hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "This value must be greater than") + " "+field.getAttribute("_minExclusive")+".";
        case hyf.validation.ValidationError.ERROR_REGULAR_EXPRESSION :
                    return hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "This value does not match the required format.");
        case hyf.validation.ValidationError.ERROR_LENGTH :
                    return hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "This value must be of length") + " "+field.getAttribute("_length")+".";
        case hyf.validation.ValidationError.ERROR_MIN_LENGTH :
                    return hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "This value must have a minimum length of") + " "+field.getAttribute("_minLength")+".";
        case hyf.validation.ValidationError.ERROR_MAX_LENGTH :
                    return hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "This value cannot have a length greater than") + " "+field.getAttribute("_maxLength")+".";
        case hyf.validation.ValidationError.ERROR_NOT_VALID_BOOLEAN :
                    return hyf.validation.DisplayMessages.getTranslatedMessage(errorCode, "This field can only have a value of 'true' or 'false'.");
        default: return hyf.validation.DisplayMessages.getTranslatedMessage(99, "This field is invalid.");
    }
}


/**
 * This attemtps to get a translated error message for the specified error code and returns it.
 * If no translated message can be found then the provided default is returned instead.
 * @private
 */
hyf.validation.DisplayMessages.getTranslatedMessage = function(errorCode, defaultMsg)
{
    var transField = document.getElementById('hyf_default_error_message_' + errorCode);
    if ((transField != null) && (transField.value != ''))
        return transField.value;
    else
        return defaultMsg;
}
