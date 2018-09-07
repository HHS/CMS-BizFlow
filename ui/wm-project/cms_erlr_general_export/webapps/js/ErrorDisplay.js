/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on 'How do I override or clone Hyfinity webapp files such as CSS & javascript?', please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index/solution_id/1113
==================================================================================================== */

/**
 * ErrorDisplay.js
 *
 * Company: Hyfinity Ltd
 * Copyright (c) 2003
 *
 * Generic javscript object for highlighting validation errors in a form
 *
 * @author Gerard Smyth
 * @version 2.0
 *
 */


hyf.validation.ErrorDisplay = function(displayMethod)
{
    /** The approach to use for displaying errors - none, text, tooltip or bubble. */
    this._displayMethod = displayMethod;
    this._mainMessageLocation = null;
    this._mainMessageString = "";
    /** Stores whether popup alerts should be used. */
    this._showAlerts = false;
    /** Stores the message string that will be shown in the alert window.*/
    this._alertMessage = '';
    /** Indicates whether all errors should be highlighted ('all'), or just the first ('one').
     * This applies to the alert message content, and any visible messages displayed.
     * All styling changes will be made regardless of this value. */
    this._validationMode = 'one';

    /** This stores all the new errors that have not yet been shown in the screen.
     *  This is a mapping of field id to an array of ValidationError objects */
    this._newErrors = {};
    /** This stores all the errors that are currently visible on the screen.
     *  This is a mapping of field id to an array of ValidationError objects */
    this._shownErrors = {};


    // provide backward compatability by handling the old display method of alert.
    if (displayMethod == 'alert')
    {
        this._displayMethod = 'none';
        this._showAlerts = true;
    }

}

/** sets whether the error messages should be shown together in a top level DIV
 * @param messageLocation the name of the DIV to use to show the error messages, or null to stop this display*/
hyf.validation.ErrorDisplay.prototype.setMessageLocation = function(messageLocation)
{
    this._mainMessageLocation = messageLocation;
}

/** sets a specific string that should be used in the top level DIV instead of the specific error messages*/
hyf.validation.ErrorDisplay.prototype.setMessageString = function(messageString)
{
    this._mainMessageString = messageString;
}

/** sets whether alert messages shoulf be shown along with the visual highlighting.
 * Popup alert messages should be used for speech browsers. */
hyf.validation.ErrorDisplay.prototype.setShowAlerts = function(showAlerts)
{
    this._showAlerts = showAlerts;
}
/** sets the validationMode. Either 'all' or 'one'.
 * This value is curretnly only used for the alert popup to decide whether to include all errors or just one.
 */
hyf.validation.ErrorDisplay.prototype.setValidationMode = function(validationMode)
{
    this._validationMode = validationMode;
}

/**
 * Adds the provided ValdiationError object to the list to be displayed
 * at some point in the future.
 * @param error The ValdiationError object defining the error.
 * @param type (Optional) A string name indicating the type of this error.
 *      This can be used to allow only certain types of errors to be removed later
 *      by calling the resetDisplay method with the same error type.
 */
hyf.validation.ErrorDisplay.prototype.addError = function(error, type)
{
    this.addErrors([error], type);
}

/**
 * Adds all of the provided ValdiationError objects to the list of errors
 * to be displayed at some point in the future.
 * @param errors An array of ValdiationError objects defining the errors.
 * @param type (Optional) A string name indicating the type of these errors.
 *      This can be used to allow only certain types of errors to be removed later
 *      by calling the resetDisplay method with the same error type.
 */
hyf.validation.ErrorDisplay.prototype.addErrors = function(errors, type)
{
    if ((errors == null) || (typeof(errors) == 'undefined'))
        return;

    for (var i = 0; i < errors.length; ++i)
    {
        if (errors[i] == null)
            continue;

        var fieldId = errors[i].getField().id;

        if (type)
        {
            errors[i].type = type;
        }

        //check if we already have errors for this field
        if (!this._newErrors[fieldId])
        {
            this._newErrors[fieldId] = [];
        }

        this._newErrors[fieldId].push(errors[i]);
    }
}

/**
 * Checks whether there are any errors to be displayed for the specified component.
 * This will only return true if a call to showErrors with the same component
 * will display some errors.
 * @param component (optional) The HTML component to check if there are any errors for
 * @return boolean indicating whether there are any errors to show.
 */
hyf.validation.ErrorDisplay.prototype.hasErrorsToShow = function(component)
{
    for (fieldId in this._newErrors)
    {
        //check if this error applies to the given component
        if ((component == null) || (typeof(component) == 'undefined') ||
            (hyf.util.isParent(this._newErrors[fieldId][0].getField(), component)))
        {
            return true;
        }
    }
    return false;
}

/**
 * Main function that displays validation errors.
 * This will display any errors that have been added by the add methods above since the last time this
 * function was called (for the same component)
 * Any fields within this component that are not currently showing an error, and will not have an error
 * shown by this call will be marked as successful.
 *
 * @param component (optional) The HTML component to show errors for.  This can be an individual field,
 *          or a container element (eg DIV) holding a number of fields. If not provided, then all
 *          the new errors will be displayed.
 * @param changeFocus (optional) A boolean value indicating whether the focus should be changed
 *          to the first field in error.  If not provided then the focus will be changed.
 * @return boolean indicating whether any errors have been displayed by this method or not.
 */
hyf.validation.ErrorDisplay.prototype.showErrors = function(component, changeFocus)
{
    if (component == null || typeof(component) == 'undefined')
        component = document.body;

    this._errorShownInThisCall = false;

    //the errors that have been rendered on screen
    var relevantErrors = [];

    //find all the fields in the contianer
    var fields = hyf.validation.findFieldsInContainer(component, true, true);

    for (var i = 0; i < fields.length; ++i)
    {
        //make sure the field has an id - this should always be the case for our controls
        if ((typeof(fields[i].id) == 'undefined') || (fields[i].id == ''))
            continue;

        //check if there are any errors for this field
        var fieldId = fields[i].id;
        if (this._newErrors[fieldId])
        {
            //have an error to show for this field
            var fieldErrors = this._newErrors[fieldId];
            this.displayError(fieldErrors[0]);

            relevantErrors.push(fieldErrors[0]);

            //push all of the errors for this field into the shown errors collection
            if (this._shownErrors[fieldId])
            {
                this._shownErrors[fieldId] = this._shownErrors[fieldId].concat(fieldErrors);
            }
            else
            {
                this._shownErrors[fieldId] = fieldErrors;
            }

            //remove field from new errors now they have been shown
            delete this._newErrors[fieldId];
        }
        else
        {
            //dont have any new errors to show
            //if none already shown, and this is a field we would normally valdiate, then mark as success
            if ((!this._shownErrors[fieldId]) && (hyf.FMAction.getFormValidator().shouldFieldBeValidated(fields[i])))
            {
                this.displaySuccess(fields[i]);
            }
        }

    }

    if (this._errorShownInThisCall)
    {
        //put the focus on the first field in error
        if ((typeof(changeFocus) == 'undefined') || (changeFocus))
            this.focusErrorField(relevantErrors);

        if (this._showAlerts)
        {
            alert(this._alertMessage);
            this._alertMessage = "";
        }

        this._errorShownInThisCall = false;
        return true;
    }
    else
    {
        return false;
    }
}


/**
 * Resets the display by undoing any changes made to show any errors within the specified component
 * @param component (optional) The HTML component to remove the errors for.  This can be a single field,
 *              or a container element (such as a DIV) that contains multiple fields with potential
 *              errors displayed.  If not provided, then all displayed errors will be removed.
 * @param type (optional) A string specifying the type of errors to reset.  If provided, only existing errors
 *              that match this type will be removed.  If not provided, the default, all errors will be removed.
 */
hyf.validation.ErrorDisplay.prototype.resetDisplay = function(component, type)
{
    if (component == null || typeof(component) == 'undefined')
        component = document.body;

    //find all the fields in the contianer
    var fields = hyf.validation.findFieldsInContainer(component, true, true);

    for (var i = 0; i < fields.length; ++i)
    {
        //make sure the field has an id - this should always be the case for our controls
        if ((typeof(fields[i].id) == 'undefined') || (fields[i].id == ''))
            continue;

        this.resetDisplayForField(fields[i]);

        if (this._shownErrors[fields[i].id])
        {
            //if we have a type value, any errors not for that type
            //should not be removed, so they need to be moved back into
            //the new errors collection to be reshown
            if (type)
            {
                var se = this._shownErrors[fields[i].id];
                for (var j = 0; j < se.length; ++j)
                {
                    if ((typeof(se[j].type) == 'undefined') || (se[j].type == null) || (se[j].type != type))
                    {
                        //want to keep this error, so move it back to _newErrors
                        if (!this._newErrors[fields[i].id])
                        {
                            this._newErrors[fields[i].id] = [];
                        }

                        this._newErrors[fields[i].id].push(se[j]);
                    }
                }
            }

            delete this._shownErrors[fields[i].id];
        }
    }

    var errorsRemaining = false;

    for (field in this._shownErrors)
    {
        errorsRemaining = true;
        break;
    }

    //if there are now no errors being displayed, hide the top level message if there is one.
    if (!errorsRemaining)
    {
        if ((typeof(this._mainMessageLocation) != 'undefined') && (this._mainMessageLocation != null) && (this._mainMessageLocation != ''))
        {
            this._mainMessageLocation.style.display = "none";
            this._mainMessageLocation.innerHTML = "";
        }
    }
}


//-------------- Private Methods -----------------------------------------------

/**
 * Tries to put the focus into the first field in error.
 * @param applicableErrors (Optional) An array of errors to try and focus the field from.
 *          If not provided, the _shownErrors details will be used.
 */
hyf.validation.ErrorDisplay.prototype.focusErrorField = function(applicableErrors)
{
    if (!applicableErrors)
    {
        applicableErrors = [];
        for (f in this._shownErrors)
        {
            applicableErrors = applicableErrors.concat(this._shownErrors[f])
        }
    }

    for (var i = 0; i < applicableErrors.length; ++i)
    {
        var ve = applicableErrors[i];
        var errorField = ve.getField();

        if (hyf.util.setFocusOnField(errorField))
            return;
    }
}


/**
 * Function that takes a ValidationError object and displays it based on
 * this ErrorDisplay object's settings
 * @param error ValdiationError object to display
 */
hyf.validation.ErrorDisplay.prototype.displayError = function(error)
{
    var cb = hyf.util.getFieldControlBody(error.getField());
    var fi = hyf.validation.ErrorDisplay.getFeedbackIcon(error.getField());
    if (cb)
        dojo.addClass(cb, 'hasError');
    if (fi)
        dojo.addClass(fi, 'fiError');

    var lc = hyf.util.getFieldLabelContainer(error.getField());
    if (lc != null)
    {
        dojo.addClass(lc, 'hasError');
    }


    //if we have a timeout to hide the server message for this field then
    //cancel the timeout as we are showing another error so don't want to hide it
    if (error.getField().smHideTimeout)
    {
        window.clearTimeout(error.getField().smHideTimeout);
        error.getField().smHideTimeout = null;
        delete error.getField().smHideTimeout;
    }

    if ((this._validationMode == 'all') || (!this._errorShownInThisCall))
    {
        if (this._displayMethod == 'text') //update the styling and contents of relevant containers to show error
        {
            this.showErrorText(error);
        }
        else if (this._displayMethod == 'tooltip') //update the styling of relevant containers and create tooltip to show error
        {
            this.showErrorTooltip(error);
        }
        else if (this._displayMethod == 'bubble') //update the styling of relevant containers and create tooltip to show error
        {
            this.showErrorBubble(error);
        }
        else if (this._displayMethod == 'none')
        {
            //do nothing
        }
        else
        {
            alert('Unknown display method!!!');
        }
    }

    //check if the errors should be shown in combined DIV
    if ((typeof(this._mainMessageLocation) != 'undefined') && (this._mainMessageLocation != null) && (this._mainMessageLocation != ''))
    {
        this._mainMessageLocation.style.display = "block";
        if ((typeof(this._mainMessageString) != 'undefined') && (this._mainMessageString != null) && (this._mainMessageString != ''))
            this._mainMessageLocation.innerHTML = this._mainMessageString;
        else
            this._mainMessageLocation.innerHTML = this._mainMessageLocation.innerHTML + '<div id="' +
                            error.getField().id + '_topLevelMsg"><span>' +
                            hyf.validation.ErrorDisplay.getFieldDisplayName(error.getField()) + '</span>: ' +
                            hyf.validation.DisplayMessages.getMessage(error.getField(), error.getErrorCode()) + '</div>';
    }

    if (this._showAlerts == true) //show alert messages for errors
    {
        this.buildAlertMessage(error);
    }

    this._errorShownInThisCall = true;
}

/** Build the message to show in a popup alert.
 * If the validationMode is set to 'one' then only the first error will be alerted,
 * otherwise the alert message will detail all errors.
 */
hyf.validation.ErrorDisplay.prototype.buildAlertMessage = function(error)
{
    if ((this._validationMode == 'one') && (this._alertMessage == ''))
    {
       this._alertMessage = "Validation Error on " + hyf.validation.ErrorDisplay.getFieldDisplayName(error.getField()) +
                    "\n\n" + hyf.validation.DisplayMessages.getMessage(error.getField(), error.getErrorCode());
    }

    if (this._validationMode == 'all')
    {
        if (this._alertMessage == '')
        {
            this._alertMessage = 'Please correct the following errors:\n\n';
        }

        this._alertMessage += hyf.validation.ErrorDisplay.getFieldDisplayName(error.getField()) + "\t:\t" + hyf.validation.DisplayMessages.getMessage(error.getField(), error.getErrorCode()) + "\n";
    }
}

/** Shows the given ValidationError object using the 'text' style display
 *  ie. changes styles of the field and places the error message within the message container*/
hyf.validation.ErrorDisplay.prototype.showErrorText = function(error)
{
    var fieldName = hyf.validation.ErrorDisplay.getFieldName(error.getField());
    var messageContainer = document.getElementById(fieldName + "_error_message_container");

    if (messageContainer == null)
    {
        messageContainer = document.createElement('span');
        messageContainer.id = fieldName + "_error_message_container";
        messageContainer.className = 'errorMessage';

        var fieldContainer = document.getElementById(fieldName+"_container");
        fieldContainer.appendChild(messageContainer);

    }

    messageContainer.innerHTML = hyf.validation.DisplayMessages.getMessage(error.getField(), error.getErrorCode());
}

/** Shows the given ValidationError object using the 'tooltip' style display
 *  ie. changes styles of the field and places the error message within an onhover tooltip*/
hyf.validation.ErrorDisplay.prototype.showErrorTooltip = function(error)
{
    var fi = hyf.validation.ErrorDisplay.getFeedbackIcon(error.getField());

    fi.innerHTML = '<span class="tooltipContent" style="display:none;">' + hyf.validation.DisplayMessages.getMessage(error.getField(), error.getErrorCode()) + '</span>';

    fi.onmouseover = hyf.tooltips.showTipMessage;
    fi.onmouseout = hyf.tooltips.hideTipMessage;
    //add an onclick handler as well to better handle touch devices which will simulate a click.
    //In this case we show the tip immediately if one isnt displayed, or hide the current one if it is
    fi.onclick = hyf.tooltips.toggleTipMessage;
}


/** Shows the given ValidationError object using the message bubble style display
 *  This automatically pops up whenever the error field has focus.
 *  */
hyf.validation.ErrorDisplay.prototype.showErrorBubble = function(error)
{
    var f = error.getField();
    //var fi = hyf.validation.ErrorDisplay.getFeedbackIcon(f);
    var fi = hyf.util.getFieldControlBody(f);

    hyf.tooltips.showBubbleMessage(hyf.validation.DisplayMessages.getMessage(f, error.getErrorCode()), fi);

    f._hyfFocusHandle = hyf.attachEventHandler(f, 'onfocus', function() {
            hyf.tooltips.showBubbleMessage(hyf.validation.DisplayMessages.getMessage(f, error.getErrorCode()), fi);
    });
    f._hyfBlurHandle = hyf.attachEventHandler(f, 'onblur', function() {
            hyf.tooltips.hideBubbleMessage(fi);
    });


}

/**
 * Marks the given field as having successfully passed all validation checks.
 * @param field The HTML element for the field (eg textbox) to mark.
 */
hyf.validation.ErrorDisplay.prototype.displaySuccess = function(field)
{
    var fi = hyf.validation.ErrorDisplay.getFeedbackIcon(field);
    var cb = hyf.util.getFieldControlBody(field);

    if (cb)
        dojo.addClass(cb, 'hasSuccess');
    if (fi)
        dojo.addClass(fi, 'fiSuccess');

    var lc = hyf.util.getFieldLabelContainer(field);
    if (lc != null)
    {
        //dojo.removeClass(lc, 'hasError');
        dojo.addClass(lc, 'hasSuccess');
    }

    //check if there is a server message for this field to remove
    var sm = hyf.validation.ErrorDisplay.getServerMessage(field);
    var lsm = hyf.validation.ErrorDisplay.getLabelServerMessage(field);
    if (sm || lsm)
    {
        var retain = (sm) ? hyf.util.getWebMakerAttribute(sm, 'retain') : 'true';
        var lretain = (lsm) ? hyf.util.getWebMakerAttribute(lsm, 'retain') : 'true';
        if ((retain == null) || (retain != 'true') || (lretain == null) || (lretain != 'true'))
        {
            //use a timeout to hide the server message, so that we can cancel
            //the hide if we reshow an error straight away
            field.smHideTimeout = setTimeout(function() {
                    if ((retain == null) || (retain != 'true'))
                        sm.parentNode.removeChild(sm);
                    if ((lretain == null) || (lretain != 'true'))
                        lsm.parentNode.removeChild(lsm);
                    field.smHideTimeout = null;
                    delete field.smHideTimeout;
            }, 200);

        }

    }
}


/**
 * Removes any display changes put in place to highlight the provided error
 * @param error The ValidationError object to remove the display for
 * @private Use resetDisplay instead
 */
hyf.validation.ErrorDisplay.prototype.resetDisplayForField = function(field)
{
    var cb = hyf.util.getFieldControlBody(field);
    if (!cb)
        return;

    var fi = hyf.validation.ErrorDisplay.getFeedbackIcon(field, false);

    if (fi)
    {
        if (this._displayMethod == 'text')
        {
            var fieldName = hyf.validation.ErrorDisplay.getFieldName(field);

            var messageContainer = document.getElementById(fieldName + "_error_message_container")

            if (messageContainer != null)
            {
                messageContainer.parentNode.removeChild(messageContainer);
            }
        }
        else if (this._displayMethod == 'tooltip')
        {
            fi.innerHTML = '';
            fi.onmouseover = null;
            fi.onmouseout = null;
        }
        else if (this._displayMethod == 'bubble')
        {
            fi.innerHTML = '';
            hyf.tooltips.hideBubbleMessage(cb);
            if (field._hyfFocusHandle)
            {
                hyf.detachEventHandler(field._hyfFocusHandle);
                field._hyfFocusHandle = null;
                delete field._hyfFocusHandle;
            }
            if (field._hyfBlurHandle)
            {
                hyf.detachEventHandler(field._hyfBlurHandle);
                field._hyfBlurHandle = null;
                delete field._hyfBlurHandle;
            }
        }

        dojo.removeClass(fi, 'fiError');
        dojo.removeClass(fi, 'fiSuccess');
    }

    dojo.removeClass(cb, 'hasError');
    dojo.removeClass(cb, 'hasSuccess');


    var lc = hyf.util.getFieldLabelContainer(field);
    if (lc != null)
    {
        dojo.removeClass(lc, 'hasError');
        dojo.removeClass(lc, 'hasSuccess');
    }

    //remove details from the main message location if present, and not overridden
    if ((typeof(this._mainMessageLocation) != 'undefined') && (this._mainMessageLocation != null) && (this._mainMessageLocation != ''))
    {
        if ((typeof(this._mainMessageString) == 'undefined') || (this._mainMessageString == null) || (this._mainMessageString == ''))
        {
            var topLevelError = document.getElementById(field.id + '_topLevelMsg');
            if (topLevelError != null)
            {
                topLevelError.parentNode.removeChild(topLevelError);
            }
        }
    }
}


//-------- Utility Functions -----------------------------

/**
 * Returns the container used to show the feedback icon for the given field.
 * If there is not currently a container, by default, one will be created.
 * @param field The field HTML object (input textbox, textarea, etc) to get the feedback container for.
 * @param createIfNeeded (Optional) boolean indicating whether the feeedback icon container should be
 *                  created if it doesn't laredy exists. Defautls to true.
 * @return The HTML element for the feedback icon, or null if not present and createIfNeeded false.
 */
hyf.validation.ErrorDisplay.getFeedbackIcon = function(field, createIfNeeded)
{
    if (typeof(createIfNeeded) == 'undefined')
        createIfNeeded = true;

    var controlBody = hyf.util.getFieldControlBody(field);

    if ((typeof(controlBody) != 'undefined') && (controlBody != null))
    {
        var feedback = null;

        var matches = dojo.query('.feedbackIcon', controlBody);
        if (matches.length > 0)
        {
            feedback = matches[0];
        }
        //if the feedback icon container could not be found then we should create one
        else if (createIfNeeded)
        {
            feedback = document.createElement('i');
            feedback.className = 'feedbackIcon';

            //if there are any style overrides on the control then apply them
            //we are only interested in font-weight and font-size settings.
            //we always apply these settings rather than checking if they are set as overrides
            //as for dojo widgets they will not actually be on the input field, but on a parent

            //If the control is actually part of a radio or multi checkbox group, then the styling information
            //we need is actaully on the label for the control, not the control itself.
            var styleElem = field;
            if ((field.type == 'radio') || ((field.type == 'checkbox') && (hyf.util.getWebMakerAttribute(field, 'use') == 'selectMany')))
            {
                styleElem = dojo.query('label[for='+field.id+']', controlBody)[0];
            }
            if (styleElem)
            {
                feedback.style.fontSize = hyf.util.getCurrentStyle(styleElem, 'font-size');
                feedback.style.fontWeight = hyf.util.getCurrentStyle(styleElem, 'font-weight');
            }


            controlBody.appendChild(feedback);
            dojo.addClass(controlBody, 'hasFeedback');

        }
        return feedback;
    }

}

/**
 * Returns the container used to show the server message for the given field.
 * This will return null if there is not a server message displayed for this field.
 * @param field The field HTML object (input textbox, textarea, etc) to get the server message container for.
 * @return The HTML element for the server message, or null if not present.
 */
hyf.validation.ErrorDisplay.getServerMessage = function(field)
{
    var name = hyf.validation.ErrorDisplay.getFieldName(field);

    var container = document.getElementById(name + '_server_message_container');
    return container;
}

/**
 * Returns the container used to show the server message for the given field's label.
 * This will return null if there is not a server message displayed against this fields label.
 * @param field The field HTML object (input textbox, textarea, etc) to get the server message container for.
 * @return The HTML element for the server message, or null if not present.
 */
hyf.validation.ErrorDisplay.getLabelServerMessage = function(field)
{
    var name = hyf.validation.ErrorDisplay.getFieldName(field);

    var container = document.getElementById(name + '_label_server_message_container');
    return container;
}

/**
 * Returns the name of the FormMaker element represented by the specified field
 * For fields within a repeat, the returned name will include the repeatId prefix.
 * @param field The field HTML object (input textbox, textarea, etc) to get the name from.
 * @return The determined name.
 */
hyf.validation.ErrorDisplay.getFieldName = function(field)
{
    if ((typeof(field.declaredClass) != 'undefined') && (field.declaredClass.indexOf('dijit.form.') == 0))
    {
        //field is actually a dojo widget
        return field.id;
    }



    var name;
    if (field.getAttribute("_element") != null)
        name = field.getAttribute("_element");
    else if (field.getAttribute("_originalFieldName") != null)
        name = field.getAttribute("_originalFieldName");
    else if ((typeof(field.name) != 'undefined') && (field.name != ''))
        name = field.name;
    else
        name = field.id;

    //check if the field is only used for display, and if so remove the '_display' suffix
    if (field.getAttribute("_display_only") == 'true')
    {
        name = name.substring(0, fieldName.length - 8);
    }

    return name;
}


/** Tries to find the display name to use for the given field.
 * This is done by trying to find a label that is associated with this field,
 * and if present returning its content.
 * If this cant be found, the name of the field is simply returned.
 *
 * @param field The form control object to find the name for
 * @return the display name to use for the given field.
 */
hyf.validation.ErrorDisplay.getFieldDisplayName = function(field)
{
    var id = field.getAttribute("id");

    if (field.type == 'radio')
        id = field.name + "1";

    if ((field.type == 'checkbox') && (field.getAttribute("_use") == 'selectMany'))
        id = field.getAttribute("_element") + "1";

    if (field.getAttribute("_originalFieldName") != null)
        id = field.getAttribute("_originalFieldName");

    var usefieldset = false;
    var fieldset = null;
    //Handle the case where the radio buttons / checkboxes are contained in a fieldset,
    //but without a specific label.  In this case, we should use the fieldset legend.
    if ((field.type == 'radio') || ((field.type == 'checkbox') && (field.getAttribute("_use") == 'selectMany')))
    {
        fieldset = hyf.validation.ErrorDisplay.findFieldsetParent(field);
        if (fieldset != null)
        {
            usefieldset = true;
            inputs = fieldset.getElementsByTagName("input");
            selects = fieldset.getElementsByTagName("select");
            textareas = fieldset.getElementsByTagName("textarea");
            for (var i = 0; i < inputs.length; ++i)
            {
                inputField = inputs.item(i);

                if (inputField.type == 'radio')
                {
                    if (inputField.name != field.name)
                        usefieldset = false;
                }
                else if (inputField.type == 'checkbox')
                {
                    if (inputField.getAttribute("_element") != field.getAttribute("_element"))
                        usefieldset = false;
                }
                else
                    usefieldset = false;
            }
            if ((selects.length > 0) || (textareas.length > 0))
            {
                usefieldset = false;
            }
        }
    }

    if (usefieldset)
    {
        if (fieldset != null)
        {
            return fieldset.getElementsByTagName("legend").item(0).innerHTML;
        }
        else
            return field.name;
    }
    else
    {
        if (id != null)
        {
            var labels = document.getElementsByTagName("label");
            for (var i = 0; i < labels.length; ++i)
            {
                var forAtt = labels.item(i).getAttribute('htmlFor');
                if (forAtt == null)
                    forAtt = labels.item(i).getAttribute('for');
                if (forAtt == id)
                {
                    var labelHTML = labels.item(i).innerHTML;
                    var startSpan = labelHTML.indexOf('<SPAN');
                    if (startSpan == -1)
                        startSpan = labelHTML.indexOf('<span');
                    if (startSpan != -1)
                    {
                        if (startSpan == 0)
                        {
                            var endSpan = labelHTML.indexOf('</SPAN>');
                            if (endSpan == -1)
                                endSpan = labelHTML.indexOf('</span>');
                            return labelHTML.substr(endSpan + 7);
                        }
                        else
                        {
                            return labelHTML.substring(0, startSpan);
                        }
                    }
                    else
                        return labelHTML;
                }
            }
        }
    }
    return field.name;
}

/**
 * checks to see if the given node has a fieldset as an ancestor, and
 * if so returns it.
 * Otherwise returns null
 */
hyf.validation.ErrorDisplay.findFieldsetParent = function(node)
{
    if ((node.parentNode == null) || (node.parentNode.nodeType == 9))
    {
        return null;
    }
    else
    {
        if (node.parentNode.tagName.toUpperCase() == 'FIELDSET')
        {
            return node.parentNode;
        }
        else
        {
            return hyf.validation.ErrorDisplay.findFieldsetParent(node.parentNode);
        }
    }
}



//-------------------- tooltip functionality --------------------------------


hyf.tooltips = {
    currentTipElement: null,
    currentTipLocation: null,

    positionOffset: 5, //the number of pixels to offset the displayed tooltip from the request location
    screenEdgeOffset: 15 //the minimum pixel gap to keep from the edge of the screen

}




/**
 * Called when the mouse moves onto the trigger container.
 * Finds the coordinates of the mouse, and then initialises the tooltip.
 */
hyf.tooltips.showTipMessage = function(e, immediate)
{
    hyf.tooltips.createTooltipContainer();

    var tipDiv = document.getElementById('tipDiv');
    var messageDiv = document.getElementById("messageDiv");

    if ((tipDiv != null) && (messageDiv != null))
    {
        var posx = 0;
        var posy = 0;

        var evt = e || window.event;
        // There is no e.target property in IE, so instead IE uses window.event.srcElement
        var target = evt.target || evt.srcElement;

        if ((typeof(target) != 'undefined') && (target != null))
        {
            while ((target != null) &&
                   (hyf.util.getWebMakerAttribute(target, 'tipMessage') == null) &&
                   (dojo.query('.tooltipContent', target).length == 0))
                target = target.parentNode;

            if (target == null) return;

            //If the tip is the same as the last then it has been requested to be displayed from a previous event, so don't show again.
            if (target == hyf.tooltips.currentTipElement)
            {
                if (hyf.tooltips.popdownTimeout)
                {
                    clearTimeout(hyf.tooltips.popdownTimeout);
                    hyf.tooltips.popdownTimeout = null;
                }
                return;
            }

            hyf.tooltips.requestedTipElement = target;

            //work out where to position the tooltip - this is the top left corner of the tooltip
            var tipTriggerPos = hyf.util.getMouseCoords(evt);
            hyf.tooltips.requestedTipLocation = {
                    x: tipTriggerPos.x,
                    y: tipTriggerPos.y
            };

            if (hyf.tooltips.popupTimeout)
            {
                clearTimeout(hyf.tooltips.popupTimeout);
            }

            if (immediate)
            {
                hyf.tooltips.showTip();
            }
            else
            {
                hyf.tooltips.popupTimeout = setTimeout(hyf.tooltips.showTip, 300);
                if (hyf.tooltips.popdownTimeout)
                {
                    clearTimeout(hyf.tooltips.popdownTimeout);
                    hyf.tooltips.popdownTimeout = null;
                    hyf.util.hideComponent(tipDiv);
                    hyf.util.hideComponent(messageDiv);
                }
            }
            return;
        }

        hyf.util.hideComponent(tipDiv);
        hyf.util.hideComponent(messageDiv);
    }
}

/**
 * Actually makes the tooltip visible.
 * This should never be called directly - use showTipMessage instead.
 * @private
 */
hyf.tooltips.showTip = function()
{
    var tipDiv = document.getElementById('tipDiv');
    var messageDiv = document.getElementById("messageDiv");

    hyf.util.showComponent(tipDiv, true, null, 'fade');
    hyf.util.showComponent(messageDiv);
    hyf.tooltips.messageSize(tipDiv, messageDiv, hyf.tooltips.requestedTipLocation.x, hyf.tooltips.requestedTipLocation.y);

    hyf.tooltips.currentTipElement = hyf.tooltips.requestedTipElement;
}

/**
 * Sets the size of the message box based on the amount of content, and positions
 * the tooltip window correctly.
 * This positions the tooltip to the bottom right of the provided coordinates.
 */
hyf.tooltips.messageSize = function(tipDiv, messageDiv, posx, posy)
{
    //make sure we have numbers for the positions
    posx = Number(posx);
    posy = Number(posy);

    var vp = hyf.util.getViewportSize(true);

    //Reset the size and posiiton of the tooltip divs
    tipDiv.style.position = 'absolute';
    tipDiv.style.height = 'auto';
    tipDiv.style.width = '300px';

    messageDiv.style.height = 'auto';
    messageDiv.style.width = 'auto';
    messageDiv.scrollTop = 0;
    messageDiv.scrollLeft = 0;
    messageDiv.style.right = 0;
    messageDiv.style.left = 0;
    messageDiv.style.top = 0;
    messageDiv.style.position = 'absolute';


    //set the new content into the messageDiv
    if (hyf.util.getWebMakerAttribute(hyf.tooltips.requestedTipElement, 'tipMessage') != null)
        messageDiv.innerHTML = hyf.util.getWebMakerAttribute(hyf.tooltips.requestedTipElement, 'tipMessage');
    else
        messageDiv.innerHTML = dojo.query('.tooltipContent', hyf.tooltips.requestedTipElement)[0].innerHTML;

    var messageWidth = messageDiv.offsetWidth;

    messageDiv.style.overflow = 'auto';

    //if the default message width is too big for the screen then reduce it
    if (messageWidth > (vp.width - (hyf.tooltips.screenEdgeOffset * 2)))
    {
        messageWidth = vp.width - (hyf.tooltips.screenEdgeOffset * 2);
        tipDiv.style.width = messageWidth + 'px';
    }

    var messageHeight = messageDiv.offsetHeight;

    //if the message height is too big for the screen, make sure it gets a scrollbar
    if (messageHeight > (vp.height - (hyf.tooltips.screenEdgeOffset * 2)))
    {
        messageHeight = vp.height - (hyf.tooltips.screenEdgeOffset * 2);
    }


    tipDiv.style.height = messageHeight + 'px';

    hyf.util.setComponentHeight(messageDiv, tipDiv);

    if (document.getElementById('tipFrame'))
    {
        //hide tip frame if present, as this is no longer needed unles ie8
        if (dojo.isIE <= 8)
        {
            document.getElementById('tipFrame').style.height = (messageDiv.offsetHeight)+ 'px';
            document.getElementById('tipFrame').style.width = (messageDiv.offsetWidth)+ 'px';
        }
        else
            document.getElementById('tipFrame').style.display = 'none';
    }


    // prevent overlapping off window (bottom)
    if ((posy + messageHeight + hyf.tooltips.screenEdgeOffset) > (vp.height + vp.scrollTop))
    {
        tipDiv.style.top = (vp.height + vp.scrollTop - messageHeight - hyf.tooltips.screenEdgeOffset) + 'px';
    }
    else
    {
        tipDiv.style.top = (posy + hyf.tooltips.positionOffset) + 'px';
    }

    // prevent overlapping off window (right)
    if ((posx + hyf.tooltips.positionOffset + messageWidth + hyf.tooltips.screenEdgeOffset) > (vp.width + vp.scrollLeft))
    {
        tipDiv.style.left = (vp.width + vp.scrollLeft - messageWidth - hyf.tooltips.screenEdgeOffset) + 'px';
    }
    else
    {
        tipDiv.style.left = (posx + hyf.tooltips.positionOffset) + 'px';
    }

}


/**
 * Toggles the visibility of a tooltip.
 * If one is already visible it will be hidden.
 * Otherwise the event will be passed to the showTipMessage function.
 * Therefore this event should be triggered from a component that has a tip.
 */
hyf.tooltips.toggleTipMessage = function(e)
{
    if (hyf.tooltips.currentTipElement != null)
        hyf.tooltips.hideTipMessage();
    else
        hyf.tooltips.showTipMessage(e, true)
}


/**
 * Called when the mouse moves off of the trigger container.
 * Initalise the timeout to hide the tooltip
 * @pararm immediate (Optional) Boolean indicating whether to hide the tip straight away,
 *          or wait a period of time. Defaults to false.
 */
hyf.tooltips.hideTipMessage = function(immediate)
{
    //when called directly by the browser it might auto pass in the event object
    if (typeof(immediate) != 'boolean')
        immediate = false;

    //stop any tip that has been set to show
    if (hyf.tooltips.popupTimeout)
    {
        clearTimeout(hyf.tooltips.popupTimeout);
        hyf.tooltips.popupTimeout = null;
    }

    //make sure we have a visible tip
    if (hyf.tooltips.currentTipElement != null)
    {
        if (hyf.tooltips.popdownTimeout)
        {
            clearTimeout(hyf.tooltips.popdownTimeout);
            hyf.tooltips.popdownTimeout = null;
        }

        if (immediate)
        {
            hyf.tooltips.hideTip();
        }
        else
        {
            hyf.tooltips.popdownTimeout = setTimeout("hyf.tooltips.hideTip()", 500);
        }
    }
}


/**
 * Actually hides the tooltip window.
 */
hyf.tooltips.hideTip = function()
{
    //Reset the curernt tip value as it has been hidden.
    hyf.tooltips.currentTipElement = null;

    var tipDiv = document.getElementById('tipDiv');
    var messageDiv = document.getElementById("messageDiv")
    if (tipDiv != null)
    {
        hyf.util.hideComponent(tipDiv, true, null, 'fade');
    }
    if (messageDiv != null)
    {
        //hyf.util.hideComponent(messageDiv);
    }
}


/**
 * Called when mouse moved over the tooltip window.
 * Used to cancel any timers to hide the tooltip.
 */
hyf.tooltips.inToolTip = function()
{
    if (hyf.tooltips.popupTimeout)
    {
        clearTimeout(hyf.tooltips.popupTimeout);
        hyf.tooltips.popupTimeout = null;
    }
    if (hyf.tooltips.popdownTimeout)
    {
        clearTimeout(hyf.tooltips.popdownTimeout);
        hyf.tooltips.popdownTimeout = null;
    }
}

/**
 * Called when the mouse moves out of the tooltip window.
 * Inititalise the timer to hide the tooltip.
 */
hyf.tooltips.outToolTip = function()
{
    if (hyf.tooltips.popupTimeout)
    {
        clearTimeout(hyf.tooltips.popupTimeout);
        hyf.tooltips.popupTimeout = null;
    }
    if (hyf.tooltips.popdownTimeout)
    {
        clearTimeout(hyf.tooltips.popdownTimeout);
    }
    hyf.tooltips.hideTipMessage();
}

/**
 * Creates the div containers needed by the tooltips if they are not already present.
 */
hyf.tooltips.createTooltipContainer = function()
{
    var tipDiv = document.getElementById('tipDiv');
    if (tipDiv == null)
    {
        tipDiv = document.createElement('div');
        tipDiv.id = 'tipDiv';

        var content = ''
        if (dojo.isIE <= 8)
            content += '<iframe id="tipFrame" name="tipFrame" src="about:blank;" style="width : 100%; height : 100px;"></iframe>';

        content += '<div id="messageDiv"></div>';

        tipDiv.innerHTML = content;

        tipDiv.style.display = 'none';

        document.body.appendChild(tipDiv);
    }

    //make sure we have the correct events defined
    var messageDiv = document.getElementById('tipDiv');
    messageDiv.onmouseover = hyf.tooltips.inToolTip;
    messageDiv.onmouseout = hyf.tooltips.outToolTip;
}



/**
 * Ensure that tooltips can be hidden on touch devices by touching the background
 */
if (document.addEventListener)
{
    document.addEventListener('touchstart', function(e) {
            var evt = (window.event) ? window.event : e;
            if (hyf.tooltips.currentTipElement != null)
            {
                hyf.tooltips.hideTipMessage();
            }
    });
}


/**
 * In order to support our 'Message Bubble' error display method we use a modified version of the dijit.Tooltip widget.
 * This needs to be modified because the dojo widget relies on only one tooltip being visible at a time.
 * In our case (if the validation mode is 'all') we want to show multiple bubbles/tooltips at the same time, even for fields
 * that are not currently visible on the screen.
 *
 * To achieve this we need to extend and modify a few of the dojo classes.
 *
 */

/**
 * Define a new 'wm/place' component which is an equivalent of dijit/place
 * Unfortunately dijit/place cant be extended by declare so this contains a lot of code copied
 * directly from the dijit/place.js file. (version 1.7.5)
 * The main changes we have made is to the _place method so that if the position being placed at
 * is totally off the screen (top or bottom) then we dont bother to keep it in the view port.
 */
define("wm/place",
       ["dojo/_base/array", // array.forEach array.map array.some
        "dojo/dom-geometry", // domGeometry.getMarginBox domGeometry.position
        "dojo/dom-style", // domStyle.getComputedStyle
        "dojo/_base/kernel", // kernel.deprecated
        "dojo/_base/window", // win.body
        "dojo/window", // winUtils.getBox
        "dijit"	// dijit (defining dijit.place to match API doc)
       ], function(array, domGeometry, domStyle, kernel, win, winUtils, dijit){

    // module:
    //		dijit/place
    // summary:
    //		Code to place a popup relative to another node


    function _place(/*DomNode*/ node, choices, layoutNode, aroundNodeCoords){
        // get {x: 10, y: 10, w: 100, h:100} type obj representing position of
        // viewport over document
        var view = winUtils.getBox();

        // This won't work if the node is inside a <div style="position: relative">,
        // so reattach it to win.doc.body.	 (Otherwise, the positioning will be wrong
        // and also it might get cutoff)
        if(!node.parentNode || String(node.parentNode.tagName).toLowerCase() != "body"){
            win.body().appendChild(node);
        }

        var best = null;
        array.some(choices, function(choice){

            var corner = choice.corner;
            var pos = choice.pos;
            var overflow = 0;

            // calculate amount of space available given specified position of node
            var spaceAvailable = {
                w: {
                    'L': view.l + view.w - pos.x,
                    'R': pos.x - view.l,
                    'M': view.w
                   }[corner.charAt(1)],
                h: {
                    'T': view.t + view.h - pos.y,
                    'B': pos.y - view.t,
                    'M': view.h
                   }[corner.charAt(0)]
            };

            // configure node to be displayed in given position relative to button
            // (need to do this in order to get an accurate size for the node, because
            // a tooltip's size changes based on position, due to triangle)
            if(layoutNode){
                var res = layoutNode(node, choice.aroundCorner, corner, spaceAvailable, aroundNodeCoords);
                overflow = typeof res == "undefined" ? 0 : res;
            }

            // get node's size
            var style = node.style;
            var oldDisplay = style.display;
            var oldVis = style.visibility;
            if(style.display == "none"){
                style.visibility = "hidden";
                style.display = "";
            }
            var mb = domGeometry.getMarginBox(node);
            style.display = oldDisplay;
            style.visibility = oldVis;

            // coordinates and size of node with specified corner placed at pos,
            // and clipped by viewport
            var
                startXpos = {
                    'L': pos.x,
                    'R': pos.x - mb.w,
                    'M': Math.max(view.l, Math.min(view.l + view.w, pos.x + (mb.w >> 1)) - mb.w) // M orientation is more flexible
                }[corner.charAt(1)],
                startX = Math.max(view.l, startXpos),
                endX = Math.min(view.l + view.w, startXpos + mb.w);

            if ((pos.y > (view.t + view.h)) || ((pos.y + mb.h) < view.t))
            {
                var
                    startYpos = {
                        'T': pos.y,
                        'B': pos.y - mb.h,
                        'M': pos.y - (mb.h >> 1)
                    }[corner.charAt(0)],
                    startY = startYpos,
                    endY = startYpos + mb.h;
            }
            else
            {
                var
                    startYpos = {
                        'T': pos.y,
                        'B': pos.y - mb.h,
                        'M': Math.max(view.t, Math.min(view.t + view.h, pos.y + (mb.h >> 1)) - mb.h)
                    }[corner.charAt(0)],
                    startY = Math.max(view.t, startYpos),
                    endY = Math.min(view.t + view.h, startYpos + mb.h);
            }

            var width = endX - startX,
                height = endY - startY;

            overflow += (mb.w - width) + (mb.h - height);

            if(best == null || overflow < best.overflow){
                best = {
                    corner: corner,
                    aroundCorner: choice.aroundCorner,
                    x: startX,
                    y: startY,
                    w: width,
                    h: height,
                    overflow: overflow,
                    spaceAvailable: spaceAvailable
                };
            }
            return !overflow;
        });

        // In case the best position is not the last one we checked, need to call
        // layoutNode() again.
        if(best.overflow && layoutNode){
            layoutNode(node, best.aroundCorner, best.corner, best.spaceAvailable, aroundNodeCoords);
        }

        // And then position the node.  Do this last, after the layoutNode() above
        // has sized the node, due to browser quirks when the viewport is scrolled
        // (specifically that a Tooltip will shrink to fit as though the window was
        // scrolled to the left).
        //
        // In RTL mode, set style.right rather than style.left so in the common case,
        // window resizes move the popup along with the aroundNode.
        var l = domGeometry.isBodyLtr(),
            s = node.style;
        s.top = best.y + "px";
        s[l ? "left" : "right"] = (l ? best.x : view.w - best.x - best.w) + "px";
        s[l ? "right" : "left"] = "auto";	// needed for FF or else tooltip goes to far left

        return best;
    }


    return {
        around: function(
            /*DomNode*/		node,
            /*DomNode || dijit.place.__Rectangle*/ anchor,
            /*String[]*/	positions,
            /*Boolean*/		leftToRight,
            /*Function?*/	layoutNode){

            // if around is a DOMNode (or DOMNode id), convert to coordinates
            var aroundNodePos = (typeof anchor == "string" || "offsetWidth" in anchor)
                ? domGeometry.position(anchor, true)
                : anchor;

            // Compute position and size of visible part of anchor (it may be partially hidden by ancestor nodes w/scrollbars)
            if(anchor.parentNode){
                // ignore nodes between position:relative and position:absolute
                var sawPosAbsolute = domStyle.getComputedStyle(anchor).position == "absolute";
                var parent = anchor.parentNode;
                while(parent && parent.nodeType == 1 && parent.nodeName != "BODY"){  //ignoring the body will help performance
                    var parentPos = domGeometry.position(parent, true),
                        pcs = domStyle.getComputedStyle(parent);
                    if(/relative|absolute/.test(pcs.position)){
                        sawPosAbsolute = false;
                    }
                    if(!sawPosAbsolute && /hidden|auto|scroll/.test(pcs.overflow)){
                        var bottomYCoord = Math.min(aroundNodePos.y + aroundNodePos.h, parentPos.y + parentPos.h);
                        var rightXCoord = Math.min(aroundNodePos.x + aroundNodePos.w, parentPos.x + parentPos.w);
                        aroundNodePos.x = Math.max(aroundNodePos.x, parentPos.x);
                        aroundNodePos.y = Math.max(aroundNodePos.y, parentPos.y);
                        aroundNodePos.h = bottomYCoord - aroundNodePos.y;
                        aroundNodePos.w = rightXCoord - aroundNodePos.x;
                    }
                    if(pcs.position == "absolute"){
                        sawPosAbsolute = true;
                    }
                    parent = parent.parentNode;
                }
            }


            var x = aroundNodePos.x,
                y = aroundNodePos.y,
                width = "w" in aroundNodePos ? aroundNodePos.w : (aroundNodePos.w = aroundNodePos.width),
                height = "h" in aroundNodePos ? aroundNodePos.h : (kernel.deprecated("place.around: dijit.place.__Rectangle: { x:"+x+", y:"+y+", height:"+aroundNodePos.height+", width:"+width+" } has been deprecated.  Please use { x:"+x+", y:"+y+", h:"+aroundNodePos.height+", w:"+width+" }", "", "2.0"), aroundNodePos.h = aroundNodePos.height);

            // Convert positions arguments into choices argument for _place()
            var choices = [];
            function push(aroundCorner, corner){
                choices.push({
                    aroundCorner: aroundCorner,
                    corner: corner,
                    pos: {
                        x: {
                            'L': x,
                            'R': x + width,
                            'M': x + (width >> 1)
                           }[aroundCorner.charAt(1)],
                        y: {
                            'T': y,
                            'B': y + height,
                            'M': y + (height >> 1)
                           }[aroundCorner.charAt(0)]
                    }
                })
            }
            array.forEach(positions, function(pos){
                var ltr =  leftToRight;
                switch(pos){
                    case "above-centered":
                        push("TM", "BM");
                        break;
                    case "below-centered":
                        push("BM", "TM");
                        break;
                    case "after-centered":
                        ltr = !ltr;
                        // fall through
                    case "before-centered":
                        push(ltr ? "ML" : "MR", ltr ? "MR" : "ML");
                        break;
                    case "after":
                        ltr = !ltr;
                        // fall through
                    case "before":
                        push(ltr ? "TL" : "TR", ltr ? "TR" : "TL");
                        push(ltr ? "BL" : "BR", ltr ? "BR" : "BL");
                        break;
                    case "below-alt":
                        ltr = !ltr;
                        // fall through
                    case "below":
                        // first try to align left borders, next try to align right borders (or reverse for RTL mode)
                        push(ltr ? "BL" : "BR", ltr ? "TL" : "TR");
                        push(ltr ? "BR" : "BL", ltr ? "TR" : "TL");
                        break;
                    case "above-alt":
                        ltr = !ltr;
                        // fall through
                    case "above":
                        // first try to align left borders, next try to align right borders (or reverse for RTL mode)
                        push(ltr ? "TL" : "TR", ltr ? "BL" : "BR");
                        push(ltr ? "TR" : "TL", ltr ? "BR" : "BL");
                        break;
                    default:
                        // To assist dijit/_base/place, accept arguments of type {aroundCorner: "BL", corner: "TL"}.
                        // Not meant to be used directly.
                        push(pos.aroundCorner, pos.corner);
                }
            });

            var position = _place(node, choices, layoutNode, {w: width, h: height});
            position.aroundNodePos = aroundNodePos;

            return position;
        }
    }
});


/**
 * Define a new 'wm/Tooltip' widget which extends dijit/Tooltip.
 * This overrides the dijit._MasterTooltip component to make use of  our 'wm/place' and to separate out
 * the creation and positioning of the tooltip.
 * The WMTooltip widget then extends the base one with repalced methods for show and hide, which allow one
 * tooltip per aroundNode, not just one in total.  This also adds a resetPosition function which can be used
 * to reposition an already visible tooltip into the correct location.
 */
define("wm/Tooltip",
        ["dojo/_base/declare",
         "dijit/Tooltip",
         "wm/place",
         "dojo/_base/lang",
         "dojo/dom-style",
         "dojo/dom-class"],
        function(declare, Tooltip, place, lang, domStyle, domClass){

            var MasterTooltip = declare([dijit._MasterTooltip], {

                    show: function(innerHTML, aroundNode, position, rtl, textDir)
                    {
                        if(this.aroundNode && this.aroundNode === aroundNode && this.containerNode.innerHTML == innerHTML){
                            return;
                        }

                        // reset width; it may have been set by orient() on a previous tooltip show()
                        this.domNode.width = "auto";

                        if(this.fadeOut.status() == "playing"){
                            // previous tooltip is being hidden; wait until the hide completes then show new one
                            this._onDeck=arguments;
                            return;
                        }
                        this.containerNode.innerHTML=innerHTML;

                        if(textDir){
                            this.set("textDir", textDir);
                        }
                        this.containerNode.align = rtl? "right" : "left"; //fix the text alignment

                        this.aroundNode = aroundNode;
                        this.position = (position && position.length) ? position : Tooltip.defaultPosition;

                        this.positionTip();

                        domClass.add(this.domNode, "validationMessageBubble");

                        // show it
                        domStyle.set(this.domNode, "opacity", 0);
                        this.fadeIn.play();
                        this.isShowingNow = true;

                    },

                    positionTip: function()
                    {
                        var pos = place.around(this.domNode, this.aroundNode,
                            this.position, (this.containerNode.align == 'left'), lang.hitch(this, "orient"));

                        // Position the tooltip connector for middle alignment.
                        // This could not have been done in orient() since the tooltip wasn't positioned at that time.
                        var aroundNodeCoords = pos.aroundNodePos;
                        if(pos.corner.charAt(0) == 'M' && pos.aroundCorner.charAt(0) == 'M'){
                            this.connectorNode.style.top = aroundNodeCoords.y + ((aroundNodeCoords.h - this.connectorNode.offsetHeight) >> 1) - pos.y + "px";
                            this.connectorNode.style.left = "";
                        }else if(pos.corner.charAt(1) == 'M' && pos.aroundCorner.charAt(1) == 'M'){
                            this.connectorNode.style.left = aroundNodeCoords.x + ((aroundNodeCoords.w - this.connectorNode.offsetWidth) >> 1) - pos.x + "px";
                        }
                    }
            });

            var WMTooltip = declare([Tooltip], {

            });
            /** Replacement static show method */
            WMTooltip.show = function(innerHTML, aroundNode, position, rtl, textDir){

                    //create the MasterTooltip object for this node if required.
                    if (!aroundNode._wmTooltip)
                    {
                        aroundNode._wmTooltip = new MasterTooltip();
                    }

                    //if this field is currently hidden then we can't show the tooltip now
                    //as the positioning will be all wrong.
                    //Instead just store the details to show later when it becomes visible.
                    if (hyf.util.checkFieldHidden(aroundNode))
                    {
                        aroundNode._wmTooltipToShow = arguments;
                    }
                    else
                    {
                        aroundNode._wmTooltip.show(innerHTML, aroundNode, position, rtl, textDir);
                    }
            };

            /** Replacement static hide method.
             * This hides the tooltip show against the provided node using the show method above.*/
            WMTooltip.hide = function(aroundNode) {

                    if (aroundNode._wmTooltip)
                    {
                        aroundNode._wmTooltip.hide(aroundNode)

                        //if we have any settings to auto show this tooltip again
                        //in the future (eg due to being on a hidden node)
                        //then remove them as this tooltip should no longer be displayed.
                        if (aroundNode._wmTooltipAutoHidden)
                        {
                            aroundNode._wmTooltipAutoHidden = false;
                            delete aroundNode._wmTooltipAutoHidden;
                        }
                        if (aroundNode._wmTooltipToShow)
                        {
                            aroundNode._wmTooltipToShow = null;
                            delete aroundNode._wmTooltipToShow;
                        }

                        return true;
                    }

                    return false;
            };

            /**
             * Resets the position of the currently visible tooltip for
             * the given node so that it is still in the correct place.
             */
            WMTooltip.resetPosition = function(aroundNode) {

                    if (aroundNode._wmTooltip && aroundNode._wmTooltip.isShowingNow)
                    {
                        aroundNode._wmTooltip.positionTip();
                    }

            }

            return WMTooltip;
});



require(["dojo/topic", "wm/Tooltip", "dojo/on"], function(topic, Tooltip, on) {

        var resetTimeout = null;

        /** As the bubble tooltips are actually directly under the body in the HTML (so that they will appear over everythign else)
         * They are very sensitive to the structrue of the page. eg if a group is hidden, the location of all following controls
         * will change, and so any tooltips displayed will now be in the wrong position.
         * This method attempts to correct the position of any displayed bubble tooltips.
         * @param container The container to check in.  If not provided the whole page will be checked.
         * @private
         */
        function resetTooltipPositions(container)
        {
            if (resetTimeout)
            {
                clearTimeout(resetTimeout);
            }

            if (hyf.FMAction.getErrorDisplay()._displayMethod == 'bubble')
            {
                resetTimeout = setTimeout(function(){

                        if (!container)
                            container = document.body;

                        dojo.query('.controlBody.hasError', container).forEach(function(item) {
                                if (item._wmTooltip && item._wmTooltip.isShowingNow)
                                {
                                    Tooltip.resetPosition(item);
                                }

                        });

                        resetTimeout = null;
                }, 100);

            }

        }

        topic.subscribe('hyf/hooks/contentInserted', function (container) {
                //dont pass in the container, as changing its content could effect position of all following controls
                resetTooltipPositions();
        });

        on(window, 'resize', function() {resetTooltipPositions(); });

        /** When we hide a container (eg switching tabs), we need to make sure that any bubble tooltips visible for that
         * container are hidden, as otherwise they will still be visible due to not actually being within
         * the contianer in the HTML. (tooltips end up under the body)
         */
        topic.subscribe('hyf/hooks/containerHidden', function (container) {
                if (hyf.FMAction.getErrorDisplay()._displayMethod == 'bubble')
                {
                    //hide any currently visible tooltips within this container
                    dojo.query('.controlBody.hasError', container).forEach(function(item) {
                            if (item._wmTooltip && item._wmTooltip.isShowingNow)
                            {
                                item._wmTooltip.domNode.style.display = 'none';
                                item._wmTooltipAutoHidden = true;
                                item._wmTooltip.isShowingNow = false;
                            }

                    });

                    //hiding a container may affect the position of content after it,
                    //so make sure all visible tooltips are in the correct location
                    resetTooltipPositions();
                }

        });
        /** When showing a container (eg switching tabs), if there were any tooltips auto hidden purely due to
         *  container hiding then we reshow them here.
         */
        topic.subscribe('hyf/hooks/containerDisplayed', function (container) {
                if (hyf.FMAction.getErrorDisplay()._displayMethod == 'bubble')
                {
                    //reshow any tooltips within this container that were auto hidden during container hide
                    dojo.query('.controlBody.hasError', container).forEach(function(item) {
                            //make sure it is now visible
                            if (!hyf.util.checkFieldHidden(item))
                            {
                                if (item._wmTooltip && item._wmTooltipAutoHidden)
                                {
                                    item._wmTooltip.domNode.style.display = '';
                                    item._wmTooltip.isShowingNow = true;
                                    item._wmTooltipAutoHidden = false;
                                    delete item._wmTooltipAutoHidden;
                                }
                                //also if the tooltip could never be created initially due to
                                //being hidden, call show here.
                                else if (item._wmTooltip && item._wmTooltipToShow)
                                {
                                    item._wmTooltip.show.apply(item._wmTooltip, item._wmTooltipToShow);
                                    item._wmTooltipToShow = null;
                                    delete item._wmTooltipToShow;
                                }
                            }
                    });

                    //showing a container may affect the position of content after it,
                    //so make sure all visible tooltips are in the correct location
                    resetTooltipPositions();
                }
        })
});




/**
 * Shows a message bubble tooltip with the specified content, beside the given dom node
 * This message will not be hidden until hideBubbleMessage is called.
 * @param msg The HTML string to show in the tooltip bubble
 * @param node The HTML node to position the bubble by.
 * @param positions (Optional) An array of position locations in which to place the tooltip bubble.
 *              If not provided, then this will attempt to determine the best locations.
 */
hyf.tooltips.showBubbleMessage = function(msg, node, positions)
{
    if (typeof(positions) == 'undefined')
    {
        //work out where the label is positioned for this field
        //and use the correct bubble position values as appropriate
        var labelPos = 'left';

        //assume that the passed in node is a controlBody element - so the parent will be the field container
        var fc = node.parentNode;
        //for default layout group, the container parent should be the controlRow, and then controlContainer with label position class
        if (fc && fc.parentNode && dojo.hasClass(fc.parentNode, 'controlRow')
                && fc.parentNode.parentNode && dojo.hasClass(fc.parentNode.parentNode, 'controlContainer'))
        {
            if (dojo.hasClass(fc.parentNode.parentNode, 'labelAbove'))
                labelPos = 'above';
            else if (dojo.hasClass(fc.parentNode.parentNode, 'labelRight'))
                labelPos = 'right';
            else if (dojo.hasClass(fc.parentNode.parentNode, 'labelBelow'))
                labelPos = 'below';
        }
        else if (fc && fc.tagName.toLowerCase() == 'td') //grid or table
        {
            var table = fc.parentNode;
            while(table && table.tagName.toLowerCase() != 'table')
            {
                table = table.parentNode;
            }

            if (table)
            {
                //first check if it is a table with header row
                var colNum = fc.cellIndex;
                var header = table.rows[0].cells[colNum];
                if ((header.tagName.toLowerCase() == 'th') && (header.scope = 'col'))
                {
                    //is a table structure so treat as label above
                    labelPos = 'above';
                }
                else
                {
                    //assume grid structure
                    var fieldId = fc.id.substring(0, fc.id.length - '_container'.length);
                    var lc = hyf.util.getFieldLabelContainer(fieldId);
                    if (lc)
                    {
                        var rowNum = fc.parentNode.rowIndex;

                        var lColNum = lc.cellIndex;
                        var lRowNum = lc.parentNode.rowIndex;

                        if (rowNum == lRowNum)
                        {
                            if (colNum > lColNum)
                                labelPos = 'left';
                            else
                                labelPos = 'right';
                        }
                        else if (rowNum > lRowNum)
                        {
                            labelPos = 'above';
                        }
                        else if (rowNum < lRowNum)
                        {
                            labelPos = 'below';
                        }
                    }
                }
            }

        }

        switch (labelPos)
        {
            case 'above'    :   positions = ['below', 'above']; break;
            case 'below'    :   positions = ['above', 'below']; break;
            case 'right'    :   positions = ['before-centered','below', 'above']; break;
            default         :   positions = ['after-centered', 'below', 'above'];
        }
    }

    require(["wm/Tooltip"], function(Tooltip) {

            if (document.body.getAttribute('dir') == 'rtl')
                Tooltip.show(msg, node, positions, true);
            else
                Tooltip.show(msg, node, positions);

    });
}

/**
 * Hide a bubble message currently displayed for the given node.
 * @param node The HTML node the message was posiitoned by.  Must match that previously passed
 *              to a showBubbleMessage calll.
 */
hyf.tooltips.hideBubbleMessage = function(node)
{
    require(["wm/Tooltip"], function(Tooltip) {

            Tooltip.hide(node);

    });
}


