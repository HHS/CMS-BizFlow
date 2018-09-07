/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on 'How do I override or clone Hyfinity webapp files such as CSS & javascript?', please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index/solution_id/1113
==================================================================================================== */

/*
 * FormValidator.js
 *
 * Company: Hyfinity Ltd
 * Copyright (c) 2003
 *
 * Generic form validation class.
 * Allows the user to specify compulsory fields and other validation
 * information in a declarative manner, all form validation is then
 * taken care of automatically.
 *
 * Version 1.1
 */
hyf.validation =
{
    version: '1.1',
    desc:    'Contains all the functionality relating to validating forms and displaying any errors'
}

/**
 * Simple utility function to validate all the fields on the form
 * and display the errors in the appropriate way.
 * @return {boolean} A boolean value indicating whether or not the form validated ok. (true if no errors)
 *
 * @author Hyfinity Limited
 */
 //param clearBuiltInOnly (Optional) boolean, that if true means only the built in validation errors will be removed before showing the new ones
 //                         If false (the default), all displayed errors will be removed.
hyf.validation.validateForm = function(clearBuiltInOnly)
{
    //get the form validator and error display objects
    var fv = hyf.FMAction.getFormValidator();
    var ed = hyf.FMAction.getErrorDisplay();

    var errors = fv.checkForm();

    if (clearBuiltInOnly)
    {
        ed.resetDisplay(null, 'built-in');
    }
    else
    {
        ed.resetDisplay();
    }

    ed.addErrors(errors, 'built-in');

    //Try and display any relevant errors
    //we check on the result of this, rather than the size of the
    //errors collection directly as there may be custom errors already raised.
    if (ed.showErrors())
    {
        return false;
    }
    else
    {
        return true;
    }
}

/**
 * Simple utility function to validate all the fields in a given container
 * and display the errors in the appropriate way.
 * @param container {Group_Name} The HTML component (e.g. DIV) that contains the fields to valdiate.
 * @return {boolean} A boolean value indicating whether or not the container validated ok. (true if no errors)
 *
 * @author Hyfinity Limited
 */
 //param clearBuiltInOnly (Optional) boolean, that if true means only the built in validation errors will be removed before showing the new ones
 //                         If false (the default), all displayed errors will be removed.
hyf.validation.validateContainer = function(container, clearBuiltInOnly)
{
    if (typeof(container) == 'string')
    {
        container = document.getElementById(container);
    }
    // return if mandatory paramters are missing.
    if (container == null)
    {
        return;
    }

    //get the form validator and error display objects
    var fv = hyf.FMAction.getFormValidator();
    var ed = hyf.FMAction.getErrorDisplay();

    var errors = fv.checkContainer(container);

    if (clearBuiltInOnly)
    {
        ed.resetDisplay(container, 'built-in');
    }
    else
    {
        ed.resetDisplay(container);
    }

    ed.addErrors(errors, 'built-in');



    //Try and display any relevant errors
    //we check on the result of this, rather than the size of the
    //errors collection directly as there may be custom errors already raised.
    if (ed.showErrors(container))
    {
        return false;
    }
    else
    {
        return true;
    }
}

/**
 * Simple utility function to validate the given field and display any errors in the appropriate way.
 * @param field {Field_Name} The HTML field (e.g. input) to validate.
 * @return {boolean} A boolean value indicating whether or not the field validated ok. (true if no errors)
 *
 * @author Hyfinity Limited
 */
 //param clearBuiltInOnly (Optional) boolean, that if true means only the built in validation errors will be removed before showing the new ones
 //                         If false (the default), all displayed errors will be removed.
hyf.validation.validateField = function(field, clearBuiltInOnly)
{
    if (typeof(field) == 'string')
    {
        field = document.getElementById(field);
    }
    // return if mandatory paramters are missing.
    if (field == null)
    {
        return;
    }

    //get the form validator and error display objects
    var fv = hyf.FMAction.getFormValidator();
    var ed = hyf.FMAction.getErrorDisplay();

    var errors;

    if ((typeof(field.declaredClass) != 'undefined') && (field.declaredClass.indexOf('dijit.form.') == 0))
    {
        //field is actually a dojo widget
        errors = fv.checkWidget(field, false, true);
        field = document.getElementById(field.id);
    }
    else
        errors = fv.checkField(field, false, true);

    if (clearBuiltInOnly)
    {
        ed.resetDisplay(field, 'built-in');
    }
    else
    {
        ed.resetDisplay(field);
    }

    ed.addErrors(errors, 'built-in');

    //Try and display any relevant errors
    //we check on the result of this, rather than the size of the
    //errors collection directly as there may be custom errors already raised.
    if (ed.showErrors(field, false))
    {
        return false;
    }
    else
    {
        return true;
    }

}

/**
 * Constructs a new form validator object.
 *
 * @param form A HTML form to validate
 * @private
 * @author Hyfinity Limited
 */
hyf.validation.FormValidator = function(form)
{
    this._form = form;

    //set up the type validation classes
    this._numberValidator = new hyf.validation.NumberValidator();
    this._stringValidator = new hyf.validation.StringValidator();
    this._booleanValidator = new hyf.validation.BooleanValidator();
    this._dateValidator = new hyf.validation.DateValidator();
}

/**
 * Return the HTML form associated with the validator
 *
 * @return The HTML Form being validated
 * @private
 */
hyf.validation.FormValidator.prototype.getForm = function()
{
    return this._form;
}



/**
 * Validates the form object associated with this FormValidator.
 *
 * @return An array of ValidationError objects indicating the validation errors.
 * @private
 */
hyf.validation.FormValidator.prototype.checkForm = function()
{
    var invalidFields = new Array();
    for (var i = 0; i < this._form.elements.length; ++i)
    {
        var element = this._form.elements[i];

        var fieldErrors = this.checkField(element)
        if (fieldErrors != null)
        {
            invalidFields = invalidFields.concat(fieldErrors);
        }
    }

    //add in any dojo widget errors
    invalidFields = invalidFields.concat(this.checkWidgets(this._form));

    return invalidFields;
}

/**
 * Checks the given field to see if it is valid.
 * @param field The field on the page to validate.
 * @return One or more ValidationError objects detailing the validation problems with the given field.
 *         If multiple errors, these are contained within an array, if no errors, null is returned.
 * @private
 * @author Hyfinity Limited
 */
hyf.validation.FormValidator.prototype.checkField = function(field, checkHidden, checkEditableTable)
{
    if ((field.getAttribute("_type") != undefined) && (field.getAttribute("_type") != null) && (field.getAttribute("_type") != ''))
    {
        //check if the element should be validated
        if (this.shouldFieldBeValidated(field, checkHidden, checkEditableTable))
        {
            if ((field.type == 'textarea') && hyf.richtext && hyf.richtext.isRichText(field))
                hyf.richtext.updateTextareaValue(field);

            //Remove mask to ensure correct validation
            var isMasked = hyf.validation.isValueMasked(field);
            if (isMasked)
                hyf.validation.removeMask(field);

            var validatedField = null;
            switch(field.getAttribute("_type"))
            {
                case "number":
                      validatedField = this._numberValidator.check(field);
                      break;
                case "string":
                      validatedField = this._stringValidator.check(field);
                      break;
                case "boolean":
                      validatedField = this._booleanValidator.check(field);
                      break;
                case "date":
                      validatedField = this._dateValidator.check(field);
                      break;
                default:
                      validatedField = new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_INVALID_TYPE);
            }
            //Reapply mask to ensure desired display
            if (isMasked)
                hyf.validation.applyMask(field);

            return validatedField;
        }
    }
    return null;
}

/**
 * Checks it the given field should actually be validated.
 * this checks the actual validation control flag, as well as looking at the
 * location of the field, eg is it hidden etc.
 *
 * @param field The HTML control to check
 * @param checkHidden Optional boolean value indicating whether we should check if the field is hidden
 *                  or not to determine whether to validate.  If false (the default), then fields in a hidden
 *                  container will not be validated unless they are only hidden due to being on a tab that
 *                  is not currently selected.
 * @param checkEditableTable Optional boolean value indicating whether to check fields that are specific controls
 *                  for the editable table new row functionality.  If false (the default), then these fields will
 *                  not be validated.
 * @param isWidget Optional flag indicating whether the field param is actually a dojo widget.  Defaults to false.
 * @return A boolean value indicating whether or not the provided field should be validated.
 * @private
 * @author Hyfinity Limited
 */
hyf.validation.FormValidator.prototype.shouldFieldBeValidated = function(field, checkHidden, checkEditableTable, isWidget)
{
    //if the field is disabled then dont validate
    if (field.disabled || field.readOnly)
        return false;

    if (isWidget)
        field = document.getElementById(field.id)

    //if the validate flag is false then dont validate
    if (field.getAttribute("_validate") == 'false')
        return false;

    //check if the field is in a hidden group
    if (typeof(checkHidden) != 'boolean')
        checkHidden = false;
    if (!checkHidden)
    {
        var parentCheckField = field;
        //special handling for the switch control.
        //This is actually a checkbox that gets hidden, but should still be validated if not inside any hidden groups
        if ((field.type == 'checkbox') && dojo.hasClass(field, 'hide') && dojo.hasClass(field, 'switch'))
            parentCheckField = field.parentNode;
        //also handle the tinymce based rich text editor
        if ((field.type == 'textarea') && hyf.richtext && hyf.richtext.isRichText(field.id))
            parentCheckField = field.parentNode;
        if ((field.type == 'select-multiple') && dojo.hasClass(field, 'autocomplete'))
            parentCheckField = field.parentNode;

        var hiddenParents = hyf.util.findFieldHiddenParents(parentCheckField)
        if (hiddenParents.length > 0)
        {
            //check if the field is actually only hidden due to being in a non selected tab
            var layoutContainers = hyf.util.findFieldLayoutContainerParents(parentCheckField);

            //if every hidden parent is also a layout container then the user can make this field visible
            //so still need to valdiate it, otherwise we dont validate it
            for (var i = 0; i < hiddenParents.length; ++i)
            {
                if (dojo.indexOf(layoutContainers, hiddenParents[i]) == -1)
                    return false;
            }

        }
    }

    //check for editable table controls
    if (typeof(checkEditableTable) != 'boolean')
        checkEditableTable = false;
    if (!checkEditableTable && (typeof(hyf.editabletable) != 'undefined') && hyf.editabletable.checkNewRowField(field))
        return false;

    //no reason not to validate, so return true
    return true;
}

/**
 * Validates all fields within the given HTML container.
 * @param container The HTML container (eg DIV) containing the fields to validate.
 * @return An array of ValidationError objects indicating the valdiation errors with the fields checked.
 * @private
 * @author Hyfinity Limited
 */
hyf.validation.FormValidator.prototype.checkContainer = function(container)
{
    if (container == null || typeof(container) == 'undefined')
        return null;

    var errors = new Array();

    var fields = hyf.validation.findFieldsInContainer(container, true);
    for (var i = 0; i < fields.length; ++i)
    {
        var fe = this.checkField(fields[i], null, true)
        if (fe != null)
            errors = errors.concat(fe);
    }

    //add in any dojo widget errors
    errors = errors.concat(this.checkWidgets(container, null, true));

    return errors;
}

/**
 * Looks for any dojo widgets in the provided container, and checks if they are valid
 * If not, then an ValidationError object is created for the error.
 * @param container The DOM Node to check in
 * @return The array of ValdiationError objects found.
 * @private
 */
hyf.validation.FormValidator.prototype.checkWidgets = function(container, checkHidden, checkEditableTable)
{
    var errors = new Array();

    //check dijit available
    var widgets = hyf.util.getDijitWidgets(container, 'dijit.form', true);
    for (var i = 0; i < widgets.length; ++i)
    {
        errors = errors.concat(this.checkWidget(widgets[i], checkHidden, checkEditableTable));
    }

    return errors;
}


/**
 * Attempts to validate the provided dojo widget, and returns an array of
 * ValidationError objects for any errors found.
 * @param widget The dojo widget to validate
 * @return The array of ValdiationError objects found.
 * @private
 */
hyf.validation.FormValidator.prototype.checkWidget = function(widget, checkHidden, checkEditableTable)
{
    var errors = new Array();

    if (this.shouldFieldBeValidated(widget, checkHidden, checkEditableTable, true))
    {
        var widgetField = document.getElementById(widget.id);

        var widgetValue = widget.get('value');
        var widgetDisplayedValue = widget.get('displayedValue');
        var emptyValue = false;
        //if the widget has a displayed value, then use this for checking, otherwise look at the value
        if ((typeof(widgetDisplayedValue) != 'undefined') && (widgetDisplayedValue != null))
        {
            if (widgetDisplayedValue == '')
                emptyValue = true
        }
        else if (widgetValue == '')
            emptyValue = true;

        if (emptyValue)
        {
            if ((typeof(widget.required) != 'undefined') && (widget.required))
            {
                errors = errors.concat(
                    new hyf.validation.ValidationError(widgetField, hyf.validation.ValidationError.ERROR_REQUIRED));
            }
        }

        if (typeof(widget.isValid) == 'function')
        {
            if (!widget.isValid())
            {
                errors = errors.concat(
                    new hyf.validation.ValidationError(widgetField, hyf.validation.ValidationError.ERROR_INVALID));
            }
        }
    }

    return errors;
}

/**
 * Checks each form element in the form associated with this formValidator
 * to see if its value needs to be converted.
 * If so this method actually changes the values of the fields on the form
 * @private
 */
hyf.validation.FormValidator.prototype.convertFormValues = function()
{
    for (var i = 0; i < this._form.elements.length; ++i)
    {
        var element = this._form.elements[i];

        if ((element.getAttribute("_type") != undefined) && (element.getAttribute("_type") != null) && (element.getAttribute("_type") != ''))
        {
            //check if the element should be validated
            if (element.getAttribute("_validate") != 'false')
            {
                hyf.validation.ValueConverter.convertField(element)
            }
        }
    }
}


/**
 * Returns an array of all the form controls int eh given container.
 * @param container The HTML container to look in.
 * @param wmTypeOnly If true, then only fields that have a WebMaker type attribute setting will be returned
 *              Defautls to false, so all input, select, textarea fields will be returned.
 * @param includeWidgets If true, then the underlying field for any dojo widgets in the
 *              container will also be included. (Defaults to false)
 * @return Array of fields found (input, textarea, select tags)
 */
hyf.validation.findFieldsInContainer = function(container, wmTypeOnly, includeWidgets)
{
    var fields = [];
    //check any input fields
    var inputs = container.getElementsByTagName('input');
    for (var i = 0; i < inputs.length; ++i)
    {
        fields.push(inputs[i]);
    }
    //check any textareas
    var textareas = container.getElementsByTagName('textarea');
    for (var i = 0; i < textareas.length; ++i)
    {
        fields.push(textareas[i]);
    }
    //check any select boxes
    var selects = container.getElementsByTagName('select');
    for (var i = 0; i < selects.length; ++i)
    {
        fields.push(selects[i]);
    }

    //if the container itself is a field, then return it
    if ((container.tagName.toLowerCase() == 'input') || (container.tagName.toLowerCase() == 'textarea') || (container.tagName.toLowerCase() == 'select'))
        fields.push(container);

    if (wmTypeOnly)
    {
        fields = dojo.filter(fields, function(item, i) {
                 return ((item.getAttribute("_type") != null) && (item.getAttribute("_type") != ''));
        });
    }

    if (includeWidgets)
    {
        var widgets = hyf.util.getDijitWidgets(container, 'dijit.form', true);

        for (var i = 0; i < widgets.length; ++i)
        {
            var f = document.getElementById(widgets[i].id);
            if (f)
                fields.push(f);
        }
    }

    return fields;
}



/**
 * Checks through the given container for any dojo widgets
 * and performs any initialisation steps needed to make them better fit
 * with our styling and validation approach.
 * This currently only deals with FilteringSelect and ComboBox widgets
 * @param container The container to check in for dojo widgets.  If this is not provided
 *              then the document will be used.
 * @private
 * @author Hyfinity Limited
 */
hyf.validation.initiateWidgets = function(container)
{
    var widgets = hyf.util.getDijitWidgets(container);

    for (var i = 0; i < widgets.length; ++i)
    {
        var widget = widgets[i];

        if (widget.declaredClass.indexOf('dijit.form.') == 0)
        {
            widget.displayMessage = function(message) {};
            if (widget.textbox)
                dojo.removeClass(widget.textbox, 'dijitReset');
        }
        else if (typeof(widget.getChildren) == 'function')
        {
            //check if this dojo container widget contains other widgets that we need to check
            widgets = widgets.concat(widget.getChildren());
        }
    }
}

//ensure the initiateWidgets method above will be called after any dojo parse operation to create widgets
dojo.connect(hyf.hooks, 'widgetsParsed', hyf.validation.initiateWidgets);
