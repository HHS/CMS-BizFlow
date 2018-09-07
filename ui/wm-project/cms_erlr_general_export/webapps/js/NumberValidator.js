/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on 'How do I override or clone Hyfinity webapp files such as CSS & javascript?', please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index/solution_id/1113
==================================================================================================== */

/*
 * NumberValidator.js
 *
 * Company: Hyfinity Ltd
 * Copyright (c) 2003
 *
 * Wrapper object that contains a check method for validating a given field for conforming with the number type
 *
 * @author Gerard Smyth
 * @version 1.0
 */


hyf.validation.NumberValidator = function()
{

}

/*
 * Main method that performs the validation check
 *
 * @param field the HTML element (input, select etc.) that is to be validated
 * @return an array of ValidationError objects for the tests failed
 */
hyf.validation.NumberValidator.prototype.check = function(field)
{
    var failedChecks = new Array();

    switch (field.type)
    {
        case "text":
        case "textarea":
        case "password":
        case "hidden":
            failedChecks = hyf.validation.NumberValidator.checkTextField(field);
            break;
        case "select-one":
        case "select-multiple":
            failedChecks = hyf.validation.NumberValidator.checkSelectField(field);
            break;
        case "checkbox":
            failedChecks = hyf.validation.NumberValidator.checkCheckBoxField(field);
            break;
        case "radio":
            failedChecks = hyf.validation.NumberValidator.checkRadioField(field);
            break;
        default:
            break;
    }
    return failedChecks;
}




/*
 * Validates the given field assuming that it is a text box type field
 *
 * @param field the HTML element (input, select etc.) that is to be validated
 * @return An array of ValidationError objects for all the validation checks that fail
 * @private
 */
hyf.validation.NumberValidator.checkTextField = function(field)
{
    var failedChecks = new Array();
    //alert("field to check is text type");

    //check if value required
    if (field.getAttribute("_required") == 'true')
    {
        if (field.value=='')
            failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_REQUIRED));
    }

    if (field.value != '')
        failedChecks = failedChecks.concat(hyf.validation.NumberValidator.checkValue(field, field.value));

    return failedChecks;
}

/*
 * Validates the given field assuming that it is a selectbox type field
 *
 * @param field the HTML element (input, select etc.) that is to be validated
 * @return An array of ValidationError objects for all the validation checks that fail
 * @private
 */
hyf.validation.NumberValidator.checkSelectField = function(field)
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

                failedChecks = failedChecks.concat(hyf.validation.NumberValidator.checkValue(field, checkVal));
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
            failedChecks = failedChecks.concat(hyf.validation.NumberValidator.checkValue(field, checkVal));
    }

    return failedChecks;
}

/*
 * Validates the given field assuming that it is a checkbox type field
 *
 * @param field the HTML element (input, select etc.) that is to be validated
 * @return An array of ValidationError objects for all the validation checks that fail
 * @private
 */
hyf.validation.NumberValidator.checkCheckBoxField = function(field)
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
            failedChecks = failedChecks.concat(hyf.validation.NumberValidator.checkValue(field, field.value));

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
            failedChecks = failedChecks.concat(hyf.validation.NumberValidator.checkValue(field, field.value));
    }

    return failedChecks;
}

/*
 * Validates the given field assuming that it is a radio button type field
 *
 * @param field the HTML element (input, select etc.) that is to be validated
 * @return An array of ValidationError objects for all the validation checks that fail
 * @private
 */
hyf.validation.NumberValidator.checkRadioField = function(field)
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
    failedChecks = failedChecks.concat(hyf.validation.NumberValidator.checkValue(field, checkVal));

    return failedChecks;
}


/*
 * Checks the given value (checkValue) against a number of validation checks
 * as determined by the attributes of the field element
 *
 * @param field the HTML element (input, select etc.) that is to be validated
 * @param checkValue The value to be vaildated against the requirements specified by the field
 *        Seperated out from the field as different field types access the value in different ways.
 * @return An array of ValidationError objects for all the validation checks that fail
 * @private
 */
hyf.validation.NumberValidator.checkValue = function(field, checkValue)
{
    var failedChecks = new Array();
    //check that the value is actually a number
    var numberRegExp = "^[-]?[0-9\.]+$";
    if (checkValue.search(numberRegExp) == -1)
        failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_NAN));


    //check if value within inclusive max
    if ((field.getAttribute("_maxInclusive") != undefined) && (field.getAttribute("_maxInclusive") != null) && (field.getAttribute("_maxInclusive") != ''))
    {
        if (Number(checkValue) > Number(field.getAttribute("_maxInclusive")))
           failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_MAX_INCLUSIVE));
    }
    //check if value within exclusive max
    if ((field.getAttribute("_maxExclusive") != undefined) && (field.getAttribute("_maxExclusive") != null) && (field.getAttribute("_maxExclusive") != ''))
    {
        if (Number(checkValue) >= Number(field.getAttribute("_maxExclusive")))
           failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_MAX_EXCLUSIVE));
    }
    //check if value within inclusive min
    if ((field.getAttribute("_minInclusive") != undefined) && (field.getAttribute("_minInclusive") != null) && (field.getAttribute("_minInclusive") != ''))
    {
        if (Number(checkValue) < Number(field.getAttribute("_minInclusive")))
           failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_MIN_INCLUSIVE));
    }
    //check if value within exclusive min
    if ((field.getAttribute("_minExclusive") != undefined) && (field.getAttribute("_minExclusive") != null) && (field.getAttribute("_minExclusive") != ''))
    {
        if (Number(checkValue) <= Number(field.getAttribute('_minExclusive')))
           failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_MIN_EXCLUSIVE));
    }
    //check regular expression
    if ((field.getAttribute("_regularExpression") != undefined) && (field.getAttribute("_regularExpression") != null) && (field.getAttribute("_regularExpression") != ''))
    {
        //_regularExpression attribute can contain multiple REs, all of which must match
        //Most normal seperator characters can occur in REs so use obscure seperator (*@*@*) between REs, and split the string into an array

        var regExps = field.getAttribute("_regularExpression");
        var REArray = regExps.split('*@*@*');

        for(var i=0; i<REArray.length; ++i)
        {
            if (checkValue.search(REArray[i]) == -1)
            {
                failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_REGULAR_EXPRESSION));
                break;
            }
        }

        /* if (value.search(field._regularExpression) == -1)
            failedChecks = failedChecks.concat(new ValidationError(field, ValidationError.ERROR_REGULAR_EXPRESSION)); */
    }

    return failedChecks;
}
