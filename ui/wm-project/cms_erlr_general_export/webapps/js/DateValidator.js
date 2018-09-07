/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on ‘How do I override or clone Hyfinity webapp files such as CSS & javascript?’, please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index/solution_id/1113
==================================================================================================== */

/*
 * DateValidator.js
 *
 * Company: Hyfinity Ltd
 * Copyright (c) 2003
 *
 * Wrapper object that contains a check method for validating a given field for conforming with the date type
 * Uses the date processing script from http://www.mattkruse.com/javascript/date/index.html to do the
 * actual checking (included in date.js)
 *
 * @author Gerard Smyth
 * @version 1.0
 *
 */


hyf.validation.DateValidator = function()
{

}



/*
 * Main method for the validation check
 * Delegates the work to the appropriate method depending on the type of control
 *
 * @return an array of ValidationError objects for the tests failed
 */
hyf.validation.DateValidator.prototype.check = function(field)
{
    var workingField = field;

    //first of all check whether this field represents just part of the overall date field
    var dateFieldPartsPrefix = workingField.getAttribute('_originalFieldName');
    if ((dateFieldPartsPrefix != null) && (dateFieldPartsPrefix!=''))
    {
        //if so, then create a temporary new field containing the combined details of all the parts of this date field
        //this temporary field can then be validated normally
        workingField = field.cloneNode(true);
        var concatDDF = hyf.validation.DateValidator.getConcatDateFieldParts(dateFieldPartsPrefix,"format",true);
        var concatDDFDisplay = hyf.validation.DateValidator.getConcatDateFieldParts(dateFieldPartsPrefix,"format",false);
        var concatDDFValues = hyf.validation.DateValidator.getConcatDateFieldParts(dateFieldPartsPrefix,"values",true);
        workingField.setAttribute('id',dateFieldPartsPrefix);
        workingField.setAttribute('name',dateFieldPartsPrefix);
        workingField.setAttribute('_display_date_format',concatDDF);
        //store the combined display format string against the actual field for use in any error messages if needed.
        field.setAttribute('_error_data_format_display',concatDDFDisplay);

        if(workingField.type == "select-one")
        {
            workingField.selectedIndex = 0;
            workingField.options[0].value = concatDDFValues;
        }
        else
        {
            workingField.value = concatDDFValues;
        }
    }

    var failedChecks = new Array();
    switch (workingField.type)
    {
        case "text":
        case "textarea":
        case "password":
        case "hidden":
            failedChecks = hyf.validation.DateValidator.checkTextField(workingField);
            break;
        case "select-one":
        case "select-multiple":
            failedChecks = hyf.validation.DateValidator.checkSelectField(workingField);
            break;
        case "checkbox":
            failedChecks = hyf.validation.DateValidator.checkCheckBoxField(workingField);
            break;
        case "radio":
            failedChecks = hyf.validation.DateValidator.checkRadioField(workingField);
            break;
        default:
            break;
    }

    //if the field being validated was just part of the full date, then we need to update
    //the field references in any errors found to point back to the actual field, not the
    //temporary one used for validation.
    if ((dateFieldPartsPrefix != null) && (dateFieldPartsPrefix!=''))
    {
        for (var i=0; i< failedChecks.length; ++i)
        {
            failedChecks[i].setField(field);
        }
    }


    return failedChecks;
}

/**
 * Static method to validate a given text box field as a date value
 * @param field The text field to validate
 * @return an array of all the errors found
 * @private
 */
hyf.validation.DateValidator.checkTextField = function(field)
{
    var failedChecks = new Array();

    if (field.getAttribute("_required") == 'true')
    {
        if (field.value=='')
            failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_REQUIRED));
    }

    if (field.value != '')
        failedChecks = failedChecks.concat(hyf.validation.DateValidator.checkDate(field, field.value));

    return failedChecks;
}

/**
 * Static method to validate a given select box field as a date value
 * @param field The select field to validate
 * @return an array of all the errors found
 * @private
 */
hyf.validation.DateValidator.checkSelectField = function(field)
{
    var failedChecks = new Array();
    var checkVal = '';

    if (field.type == "select-multiple") //need to check every selected value
    {
        var selected = false;
        for (var i = 0 ; i < field.options.length; ++i)
        {
            if (field.options[i].selected == true)
            {
                //May not want this to check text as well
                //eg, may have the text saying 'Please Select a Value'
                /*if (field.options[i].value=='')
                    checkVal = field.options[i].text;
                else*/
                    checkVal = field.options[i].value;


                if (checkVal != '')
                    selected = true;
                failedChecks = failedChecks.concat(hyf.validation.DateValidator.checkDate(field, checkVal));
            }
        }
        if (field.getAttribute("_required") == 'true')
        {
            if (!selected)
               failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_REQUIRED));
        }
    }
    else //only need to check the one selected value
    {
        checkVal = field.options[field.selectedIndex].value;
        //check if value required and if so is one selected
        if (field.getAttribute("_required") == 'true')
        {
            if (field.selectedIndex == -1)
                failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_REQUIRED));
            else
            {
                //May not want this to check text as well
                //eg, may have the text saying 'Please Select a Value'
                /*if (field.options[field.selectedIndex].value=='')
                    checkVal = field.options[field.selectedIndex].text;
                else*/
                    checkVal = field.options[field.selectedIndex].value;

                if (checkVal == '')
                    failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_REQUIRED));
            }
        }
        if (checkVal != '')
            failedChecks = failedChecks.concat(hyf.validation.DateValidator.checkDate(field, checkVal));
    }

    return failedChecks;
}

/**
 * Static method to validate a given check box field as a date value
 * @param field The checkbox field to validate
 * @return an array of all the errors found
 * @private
 */
hyf.validation.DateValidator.checkCheckBoxField = function(field)
{
    var failedChecks = new Array();

   //see if this checkbox is being used as part of a selectMany control or just a single entry
    if (field.getAttribute('_use') == 'selectMany')
    {
        var selectManyName = field.getAttribute('_element');
        //find all checkboxes that make up the selectMany control
        var checkBoxes = new Array();
        var inputs = document.getElementById(selectManyName + '_container').getElementsByTagName("input");
        for (var i=0; i<inputs.length; ++i)
        {
            if ((inputs.item(i).type == "checkbox") && (inputs.item(i).getAttribute('_use') == 'selectMany'))
            {
                if (inputs.item(i).getAttribute('_element') == selectManyName)
                {
                    checkBoxes[checkBoxes.length] = inputs.item(i);
                }
            }
        }

        //alert(checkBoxes.length+" checkboxes in this select many control");

        //check if value required - a selectMany checkbox being required means at least one of the checkboxes must be checked!!!
        if (field.getAttribute("_required") == 'true')
        {
            var oneChecked = false;
            for (var i=0; i<checkBoxes.length; ++i)
            {
                //alert(checkBoxes[i].checked);
                if (checkBoxes[i].checked==true)
                {
                    oneChecked = true;
                    break;
                }
            }
            //alert(oneChecked);
            if (!oneChecked)
                failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_REQUIRED));
        }

        if (field.checked == true)
            failedChecks = failedChecks.concat(hyf.validation.DateValidator.checkDate(field, field.value));

    }
    else
    {
        //check if value required - a checkbox being required means it must be checked!!!
        if (field.getAttribute("_required") == 'true')
        {
            if (field.checked==false)
                failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_REQUIRED));
        }

        if (field.checked == true)
            failedChecks = failedChecks.concat(hyf.validation.DateValidator.checkDate(field, field.value));
    }

    return failedChecks;
}

/**
 * Static method to validate a given radio button field as a date value
 * @param field The radio field to validate
 * @return an array of all the errors found
 * @private
 */
hyf.validation.DateValidator.checkRadioField = function(field)
{
    var failedChecks = new Array();
    var name = field.name;
    var radioArray;
    if (eval("field.form") != null)
    {
        radioArray = eval("field.form."+name);
    }
    else
    {
        //This handles the case where the info might reside outside the main form, e.g. a dialog control.
        radioArray = dojo.query('input[type=radio][name='+name+']');
    }

    var checkVal = '';
    var checked = false;

    if (radioArray.length == undefined)
    {
        if (radioArray.checked == true)
        {
            checked = true;
            checkVal = radioArray.value;
        }
    }
    else
    {
        for (var i = 0; i < radioArray.length; ++i)
        {
            if (radioArray[i].checked == true)
            {
                checked = true;
                checkVal = radioArray[i].value;
            }
        }
    }

    //check if value required - ie one radio button must be selected
    if (field.getAttribute("_required") == 'true')
    {
        if (!checked)
            failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_REQUIRED));
    }

    //check constriants on value
    failedChecks = failedChecks.concat(hyf.validation.DateValidator.checkDate(field, checkVal));

    return failedChecks;
}

/* Checks that the given 'value' is a date using the format given as an attribute
 * on the 'field'.  Also checks the min/max inclusive/exclusive values if they are present
 */
hyf.validation.DateValidator.checkDate = function(field, value)
{
    var failedChecks = new Array();

    //check if the value needs to be converted before performing any checks

    value = hyf.validation.ValueConverter.performDateConversion(field, value);

    //check that the value matches its date format
    if (!isDate(value, field.getAttribute("_data_date_format")))
    {
        //check if this is actually a time only value
        var config = hyf.calendar.config[field.id];
        if (!config)
            config = hyf.calendar.config[hyf.util.splitFullFieldId(field.id).fieldName];

        if (config && config.hasTime && !config.hasDate)
            failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_INVALID_TIME));
        else
            failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_INVALID_DATE));
    }

    //check if value within inclusive max
    if ((field.getAttribute("_maxInclusive") != undefined) && (field.getAttribute("_maxInclusive") != null) && (field.getAttribute("_maxInclusive") != ''))
    {
        var result = compareDates(value, field.getAttribute("_data_date_format"), field.getAttribute("_maxInclusive"), field.getAttribute("_data_date_format"));
        if (!(result == -1 || result == 0))
           failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_MAX_INCLUSIVE));
    }
    //check if value within exclusive max
    if ((field.getAttribute("_maxExclusive") != undefined) && (field.getAttribute("_maxExclusive") != null) && (field.getAttribute("_maxExclusive") != ''))
    {
        var result = compareDates(value, field.getAttribute("_data_date_format"), field.getAttribute("_maxExclusive"), field.getAttribute("_data_date_format"));
        if (result != -1)
           failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_MAX_EXCLUSIVE));
    }
    //check if value within inclusive min
    if ((field.getAttribute("_minInclusive") != undefined) && (field.getAttribute("_minInclusive") != null) && (field.getAttribute("_minInclusive") != ''))
    {
        var result = compareDates(value, field.getAttribute("_data_date_format"), field.getAttribute("_minInclusive"), field.getAttribute("_data_date_format"));
        if (!(result == 1 || result == 0))
           failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_MIN_INCLUSIVE));
    }
    //check if value within exclusive min
    if ((field.getAttribute("_minExclusive") != undefined) && (field.getAttribute("_minExclusive") != null) && (field.getAttribute("_minExclusive") != ''))
    {
        var result = compareDates(value, field.getAttribute("_data_date_format"), field.getAttribute("_minExclusive"), field.getAttribute("_data_date_format"));
        if (result != 1)
           failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_MIN_EXCLUSIVE));
    }

    return failedChecks;
}



/* Utility function to concatenate the display date format
 * of all the datefield parts
 * The display parameter specifies whether to return the separated version
 */
hyf.validation.DateValidator.getConcatDateFieldParts = function(dateFieldPartsPrefix,type,separator)
{
    var diffCounter = 0;
    var partCounter = 1;
    var workingString = "";
    while(diffCounter < 2)
    {
        var currentPart = document.getElementById(dateFieldPartsPrefix + "_datefield_part_"+partCounter);

        if(currentPart == null)
        {
            diffCounter++;
        }
        else
        {
            if(separator && (type=="format"||currentPart.value!=''))
            {
                workingString += "-";
            }
            if(type=="format")
            {
                workingString += currentPart.getAttribute('_display_date_format');
                if (!separator)
                {
                    var checkElem = currentPart;
                    //the first part of the control will be immediately followed by the hidden _xpath field
                    while (checkElem.nextSibling && (checkElem.nextSibling.nodeType == 1) && (checkElem.nextSibling.type == 'hidden'))
                        checkElem = checkElem.nextSibling;

                    if (checkElem.nextSibling && (checkElem.nextSibling.nodeType == 3))
                        workingString += checkElem.nextSibling.nodeValue;
                }
            }
            else if(type=="values")
            {
                //alert(currentPart.value);
                workingString += currentPart.value;
            }
            if(separator && (type=="format"||currentPart.value!=''))
            {
                workingString += "-";
            }
            diffCounter = 0;
        }
        partCounter++;
    }
    return workingString;
}
