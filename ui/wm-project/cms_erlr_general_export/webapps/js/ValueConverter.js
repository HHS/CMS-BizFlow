/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on 'How do I override or clone Hyfinity webapp files such as CSS & javascript?', please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index/solution_id/1113
==================================================================================================== */
/*
 * ValueConverter.js
 *
 * Company: Hyfinity Ltd
 * Copyright (c) 2003
 *
 * Performs conversion of a field value based on the attributes specified on the field
 *
 * @author Gerard Smyth
 * @version 1.0
 *
 */


hyf.validation.ValueConverter = function()
{

}

/*
 * Main method that performs the conversion on a particular field
 * NOTE: This updates the fields value in place with its newly converted value
 * If you do not want the field value to be updated, use the 'performStringConversion'
 * and 'performDateConversion' methods as appropriate.
 * @param field The field whose value should be converted
 * @return The converted field value
 */
hyf.validation.ValueConverter.convertField = function(field)
{
    var newValue;
    switch (field.type)
    {
        case "text":
        case "textarea":
        /* case "password":
        case "hidden": */
            newValue = hyf.validation.ValueConverter.convertTextField(field);
            break;
        case "select-one":
        case "select-multiple":
            newValue = hyf.validation.ValueConverter.convertSelectField(field);
            break;
        default:
            break;
    }

    return newValue;
}

/**
 * @private
 */
hyf.validation.ValueConverter.convertTextField = function(field)
{
    var newValue;
    switch (field.getAttribute("_type"))
    {
        case "string":
            newValue = hyf.validation.ValueConverter.performStringConversion(field, field.value);
            break;
        case "date"  :
            newValue = hyf.validation.ValueConverter.performDateConversion(field, field.value);
            break;
        default      :
            newValue = field.value;
    }
    //alert("Field name : "+field.name+"\nLast index of '_display' : "+field.name.lastIndexOf("_display")+"\nlength - 8 : "+(field.name.length - 8));
    if (field.getAttribute("_display_only") == 'true')
    {
        eval("field.form."+field.name.substring(0, field.name.length - 8)+".value=newValue");
    }
    else
    {
        field.value = newValue;
    }
    return newValue;
}

/**
 * @private
 */
hyf.validation.ValueConverter.convertSelectField = function(field)
{
    //only the editable entry on a combo box control can be changed
    if (field.selectedIndex != -1)
    {
        if (field.options[field.selectedIndex].getAttribute("_editable") == 'true')
        {
            var newValue;
            switch (field.getAttribute("_type"))
            {
                case "string":
                    newValue = hyf.validation.ValueConverter.performStringConversion(field, field.options[field.selectedIndex].value);
                    break;
                case "date"  :
                    newValue = hyf.validation.ValueConverter.performDateConversion(field, field.options[field.selectedIndex].value);
                    break;
                default      :
                    newValue = field.options[field.selectedIndex].value;
            }

            field.options[field.selectedIndex].value = newValue

            //should we bother changing the text field???
            //field.options[field.selectedIndex].text = newValue
            return newValue;
        }
    }
}

/*
 * Performs string conversion if required on the given value using the field param
 * to get the conversion definition attributes from.
 * @param value The value to convert
 * @param field The field containing the attributes describing the string conversion to perform.
 */
hyf.validation.ValueConverter.performStringConversion = function(field, value)
{
    //check if any case conversions are required on the value
    if (field.getAttribute('_data_case_format') && (field.getAttribute('_data_case_format') != ''))
    {
        value = hyf.validation.ValueConverter.convertStringValue(value, 'case', field.getAttribute('_data_case_format'));
    }

    //check if any whitespace conversions are required on the value
    if (field.getAttribute('_data_whitespace_format') && (field.getAttribute('_data_whitespace_format') != ''))
    {
        value = hyf.validation.ValueConverter.convertStringValue(value, 'whitespace', field.getAttribute('_data_whitespace_format'));
    }

    return value;
}

/*
 * Performs date conversion if required on the given value using the field param
 * to get the conversion definition attributes from.
 * @param value The value to convert
 * @param field The field containing the attributes describing the date conversion to perform.
 */
hyf.validation.ValueConverter.performDateConversion = function(field, value)
{
    var newValue = 0;
    //check if the value needs to be converted before performing any checks
    if (field.getAttribute('_display_date_format') && (field.getAttribute('_display_date_format') != '') && (field.getAttribute('_display_date_format') != field.getAttribute('_data_date_format')))
    {
        var displayDateFormat = field.getAttribute('_display_date_format');
        //handles the case when the display date is  MMMM
        displayDateFormat = displayDateFormat.replace(/MMMM/g,'MMM');
        var dataDateFormat = field.getAttribute('_data_date_format');
        dataDateFormat = dataDateFormat.replace(/MMMM/g,'MMM');

        //convert the data from the display format to the date format
        newValue = convertDate(value,displayDateFormat, dataDateFormat);
    }
    if (newValue == 0)
        return value;
    else
        return newValue;
}

/*
 * String conversion function that does not require a field control, so can be used on page load to output text for example
 * @param value the value on which to perform the conversion
 * @param method the conversion to perform, currently 'case' or 'whitespace'
 * @param type the type of conversion. 'upper', 'lower', 'sentence', 'title', or 'preserve' for case conversion.
 *                                     'preserve', 'collapse', or 'remove' for whitespace conversion
 * @return the converted value
 */
hyf.validation.ValueConverter.convertStringValue = function(value, method, type)
{
    //alert("about to convert value "+value);
    var newValue;
    if (method == 'case')
    {
        switch (type)
        {
            case 'upper'   : newValue = value.toUpperCase(); break;
            case 'lower'   : newValue = value.toLowerCase(); break;
            case 'sentence': newValue = hyf.validation.ValueConverter.convertToSentenceCase(value); break;
            case 'title'   : newValue = hyf.validation.ValueConverter.convertToTitleCase(value); break;
            case 'preserve':
            default        : newValue = value; break;
        }
    }
    else if (method == 'whitespace')
    {
        switch (type)
        {
            case 'collapse' : newValue = hyf.validation.ValueConverter.collapseWhitespace(value); break;
            case 'remove'   : newValue = hyf.validation.ValueConverter.removeWhitespace(value); break;
            case 'preserve' :
            default         : newValue = value; break;
        }
    }
    return newValue;
}

/**
 * Utiltiy function that converts the given string to sentence case
 * I.E. the first letter of each sentence is capitalised
 * @param value the string to convert
 * @return the value string converted to sentence case
 * @private
 */
hyf.validation.ValueConverter.convertToSentenceCase = function(value)
{
    //convert the string to lower case first
    var newValue = value.toLowerCase();

    var convertNextLetter = true;
    var convertedValue = '';

    for (var i=0; i<newValue.length; ++i)
    {
        var charCode = newValue.charCodeAt(i);
        var currentChar = String.fromCharCode(charCode);
        //alert(currentChar);
        if (currentChar == '.')
        {
            //alert('current char is full stop');
            convertNextLetter = true;
            convertedValue = convertedValue.concat(currentChar);
        }
        else if (currentChar.search(/\W/) != -1)
        {
            //alert("non word character");
            convertedValue = convertedValue.concat(currentChar);
        }
        else
        {
            //alert("Word character");
            if (convertNextLetter == true)
            {
                convertedValue = convertedValue.concat(currentChar.toUpperCase());
            }
            else
            {
                convertedValue = convertedValue.concat(currentChar);
            }
            convertNextLetter = false;
        }
        //alert(convertedValue);
    }

    //alert("original string : ***"+value+"***\nconverted string : ***"+convertedValue+"***");

    return convertedValue;
}

/**
 * Utiltiy function for converting the given string to title case
 * I.E. the first letter in each word is capitalised
 * @param value the string to convert
 * @return the value string converted to title case
 * @private
 */
hyf.validation.ValueConverter.convertToTitleCase = function(value)
{
    //convert the string to lower case first
    var newValue = value.toLowerCase();

    var convertNextLetter = true;
    var convertedValue = '';

    for (var i=0; i<newValue.length; ++i)
    {
        var charCode = newValue.charCodeAt(i);
        var currentChar = String.fromCharCode(charCode);
        if (currentChar.search(/\W/) != -1)
        {
            //alert("non word character");
            convertNextLetter = true;
            convertedValue = convertedValue.concat(currentChar);
        }
        else
        {
            //alert("Word character");
            if (convertNextLetter == true)
            {
                convertedValue = convertedValue.concat(currentChar.toUpperCase());
            }
            else
            {
                convertedValue = convertedValue.concat(currentChar);
            }
            convertNextLetter = false;
        }
        //alert(convertedValue);
    }

    //alert("original string : ***"+value+"***\nconverted string : ***"+convertedValue+"***");

    return convertedValue;
}



/**
 * Utility function for collapsing whitespace from the given value
 * this removes all whitespace from the start and end of the string,
 * and reduces any groups of whitespace in the middle to one space character.
 * @param value the string value to remove the whitespace from
 * @return the string resulting from the whitespace removal
 * @private
 */
hyf.validation.ValueConverter.collapseWhitespace = function(value)
{
    value = String(value);
    //alert("about to collapse whitespace on:\n*****"+value+"*****");
    //remove whitespcae charcters from the start of the string
    value = value.replace(/^\s+/g,'');
    //remove whitespcae charcters from the end of the string
    value = value.replace(/\s+$/g, '');

    //collapse whitespace in the middle
    value = value.replace(/\s+/g, ' ');

    //alert("collapsed value is:\n*****"+value+"*****");

    return value;

}

/**
 * Utility function that removes all whitespace from a given string
 * @param value the string to remove the whitespace from
 * @return the value string with all teh whitespace removed
 * @private
 */
hyf.validation.ValueConverter.removeWhitespace = function(value)
{
    value=String(value);
    //alert("about to remove whitespace on:\n*****"+value+"*****");

    //remove all whitespace characters
    value = value.replace(/\s/g, "");

    //alert("removed value is:\n*****"+value+"*****");
    return value
}

/**
 * Masks the original data value with the _display_mask attribute.
 * Also, makes a note of the original data value in attribute _unmasked_value to enable later retrieval for unmasking.
 * @param control Field to mask.
 */
hyf.validation.applyMask = function(control)
{
    if (null != control.getAttribute("_display_mask"))
    {
        var mask = control.getAttribute("_display_mask");
        var maskedValue = ""
        var originalValue = "";
        var valueProp = 'value';

        //String (editable) field
        if (("string" == control.getAttribute("_type")) && (control.type == 'text' || control.type == 'textarea'))
        {
            originalValue = control.value;
        }
        //Output (display-only) field
        else if (control.getAttribute('_use') == 'output')
        {
            if ((control.innerHTML != '&nbsp;') && (control.innerHTML != '') && (control.innerHTML != '&#160;'))
            {
                originalValue = control.innerHTML;
                valueProp = 'innerHTML';
            }
            else
            {
                originalValue = '';
                valueProp = 'innerHTML';
            }
        }
        else
        {
            return; //not a valid control that we can mask
        }

        //Make a note of the original data, for future unmasking
        control.setAttribute("_unmasked_value", originalValue);

        if ("" != mask && "" != originalValue)
        {
            maskedValue = hyf.validation.createMaskedValue(originalValue, mask);
            control[valueProp] = maskedValue;
            control.setAttribute('_mask_applied', 'true');
        }
    }
}

/**
 * Replaces the masked value with the original data value.
 * @param control Field to unmask.
 */
hyf.validation.removeMask = function(control)
{
    //Only deal with fields that have an _unmasked_value attribute, created when the mask was applied to the original data.
    if (hyf.validation.isValueMasked(control))
    {
        //String (editable) field
        if (("string" == control.getAttribute("_type")) && (control.type == 'text' || control.type == 'textarea'))
        {
            if (document.activeElement === control)
            {
                //Record the click position to enable correct cursor placement
                var clickPos = control.selectionStart;
                control.value = control.getAttribute("_unmasked_value");
                //Allow for mask characters to preserve correct placement
                var mask = control.getAttribute('_display_mask');
                var scanLength = clickPos;
                if (mask.length < clickPos)
                {
                    scanLength = mask.length;
                }
                var originalClickPos = clickPos;
                for (var i=0; i<scanLength; i++)
                {
                    if (mask.charAt(i) != '#')
                    {
                        clickPos--;
                    }
                }
                control.selectionStart = clickPos;
                control.selectionEnd = clickPos;
                //Select behaviour if tab was used
                if (originalClickPos == 0)
                {
                    control.select();
                }
            }
            else
            {
                control.value = control.getAttribute("_unmasked_value");
            }


        }
        //Output (display-only) field
        else if (control.getAttribute('_use') == 'output')
        {
            control.innerHTML = control.getAttribute("_unmasked_value");
        }
        control.setAttribute('_mask_applied', 'false');
    }
}

/**
 * Checks if the value for the specified control is masked.
 * @param control The control to check
 * @return true if the value is masked, false otherwise.
 */
hyf.validation.isValueMasked = function(control)
{
    return ((control.getAttribute("_unmasked_value") != null) && (control.getAttribute('_mask_applied') == 'true'));
}

/**
 * Returns the unmasked value for the given control.
 * @param control The control to get the unmasked value for
 * @return The unmasked value, or null if the controls value is not masked.
 */
hyf.validation.getUnmaskedValue = function(control)
{
    if (hyf.validation.isValueMasked(control))
        return control.getAttribute("_unmasked_value");
    else
        return null;
}

/**
 * Applies the mask the the original data value to return the masked value.
 * @param originalValue Original unmasked data value.
 * @param mask Mask to use to tansform the data value to the diaplay value.
 * @return maskedValue The display value after the mask has been applied to the data value.
 */
hyf.validation.createMaskedValue = function(originalValue, mask)
{
    if ("" == mask)
    {
        return originalValue;
    }

    var maskedValue = "";
    var originalValuePos = 0;
    //Use this var to track whether a closing bracket is necessary. This is useful when the data is shorter than the mask and a bracket has already been opened.
    var openBracket = false;

    //'Walk' the mask
    for (var i=0; i<mask.length; i++)
    {
        //'Walk' the data
        if(originalValuePos < originalValue.length)
        {
            //Output data char
            if ("#" == mask.charAt(i))
            {
                   maskedValue += originalValue.charAt(originalValuePos);
                   originalValuePos += 1;
            }
            //Output mask char
            else
            {
                maskedValue += mask.charAt(i);
                //Make a note to close bracket if data finishes before mask ends
                if ("(" == mask.charAt(i) || "[" == mask.charAt(i) || "{" == mask.charAt(i))
                {
                    openBracket = true;
                }
                //Make a note to indicate no open brackets
                else if (")" == mask.charAt(i) || "]" == mask.charAt(i) || "}" == mask.charAt(i))
                {
                    openBracket = false;
                }
            }
        }
        //Data finished. 'Walk the remainder of the mask.
        else
        {
            //Complete closing bracket where data fell short of the mask length
            if ((")" == mask.charAt(i) || "]" == mask.charAt(i) || "}" == mask.charAt(i)) && openBracket)
            {
                maskedValue += mask.charAt(i);
                //Force main loop end that 'walks the mask'
                i = mask.length;
            }
        }
    }
    //Handle the scenario where the data is longer that the mask. Output the rest of the data (unmasked) after mask has completed.
    for (var i=originalValuePos; i<originalValue.length; i++)
    {
        maskedValue+=originalValue.charAt(i);
    }
    return maskedValue;
}

/**
 * Applies masks to all fields that have masks defined.
 * @param container The container where the masked fields are located. If not provided, the document body will be used.
 */
hyf.validation.applyMasks = function(container)
{
    if ((typeof(container) == 'undefined') || (container == null))
        container = document.body;

    dojo.query("[_display_mask]", container).forEach(function(node, index, arr){
            hyf.validation.applyMask(node);
    })
}

/**
 * Isolates and applies masks to all fields that have masks defined. Also attaches event to enable the application and removal of masks for each field.
 * This is used when a form is first loaded to ensure all data is displayed in masked format.
 * @param container The container where the masked fields are located. If not provided, the document body will be used.
 */
hyf.validation.initMasks = function(container)
{
    if ((typeof(container) == 'undefined') || (container == null))
        container = document.body;

    dojo.query("[_display_mask]", container).forEach(function(node, index, arr){
            if (!hyf.validation.isValueMasked(node))
            {
                dojo.connect(node, "onfocus", hyf.validation.removeMaskEventHandler);
                dojo.connect(node, "onblur", hyf.validation.applyMaskEventHandler);
                hyf.validation.applyMask(node);
            }
    })
}

/**
 * Removes the masks for all fields that have display masks.
 * This is used when a form is submitted to ensure all data is sent to the server in unmasked format.
 * @param container The container where the masked fields are located. If not provided, the document body will be used.
 */
hyf.validation.removeMasks = function(container)
{
    if (typeof(container) == 'undefined')
        container = document.body;

    dojo.query("[_display_mask]", container).forEach(function(node, index, arr){
            hyf.validation.removeMask(node);
    })
}

/**
 * Event Handler for the onblur event to enable the application of the mask when a field is exited.
 * @param evt Event
 */
hyf.validation.applyMaskEventHandler = function(evt)
{
    var event = evt || window.event;
    var target = event.target || event.srcElement;
    hyf.validation.applyMask(target);
}

/**
 * Event Handler for the onfocus event to enable the removal of the mask when a field is clicked.
 * @param evt Event
 */
hyf.validation.removeMaskEventHandler = function(evt)
{
    var event = evt || window.event;
    var target = event.target || event.srcElement;
    hyf.validation.removeMask(target);
}

//Mask and Unmask fields as required after page loaded and Dojo Widgets parsed
dojo.connect(hyf.hooks, 'widgetsParsed', hyf.validation.initMasks);

//submit event to ensure all masked fields are unmasked before submission
hyf.util.addOnFormSubmit(hyf.validation.removeMasks);
