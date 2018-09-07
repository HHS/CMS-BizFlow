/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on 'How do I override or clone Hyfinity webapp files such as CSS & javascript?', please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index/solution_id/1113
==================================================================================================== */
/*
 * BooleanValidator.js
 *
 * Company: Hyfinity Ltd
 * Copyright (c) 2003
 *
 * Wrapper object that contains a check method for validating a given field for conforming with the boolean type
 *
 * @author Gerard Smyth
 * @version 1.0
 *
 */


hyf.validation.BooleanValidator = function()
{

}


/**
 * Main method that performs the validation check
 *
 * @return an array of ValidationError objects for the tests failed
 */
hyf.validation.BooleanValidator.prototype.check = function(field)
{
    var failedChecks = new Array();
    //alert("will check field "+field+" for boolean conformity here");
    switch (field.type)
    {
        case "text":
        case "textarea":
        case "password":
        case "hidden":
            failedChecks = hyf.validation.BooleanValidator.checkTextField(field);
            break;
        case "select-one":
        case "select-multiple":
            failedChecks = hyf.validation.BooleanValidator.checkSelectField(field);
            break;
        case "checkbox":
            failedChecks = hyf.validation.BooleanValidator.checkCheckBoxField(field);
            break;
        case "radio":
            failedChecks = hyf.validation.BooleanValidator.checkRadioField(field);
            break;
        default:
            break;
    }
    return failedChecks;
}


/**
 * Static method to validate a given text box field as a boolean value
 * @param field The text field to validate
 * @return an array of all the errors found
 * @private
 */
hyf.validation.BooleanValidator.checkTextField = function(field)
{
    var failedChecks = new Array();

    //check if value required
    if (field.getAttribute("_required") == 'true')
    {
        if (field.value=='')
            failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_REQUIRED));
    }

    // Possibly should add checks for different boolean types, ie yes/no

    if ((field.value != '') && !((field.value == 'true') || (field.value == 'false')))
        failedChecks = failedChecks.concat(new hyf.validation.ValidationError(field, hyf.validation.ValidationError.ERROR_NOT_VALID_BOOLEAN));

    return failedChecks;
}

/**
 * Static method to validate a given select box field as a boolean value
 * @param field The select box field to validate
 * @return an array of all the errors found
 * @private
 */
hyf.validation.BooleanValidator.checkSelectField = function(field)
{
    var failedChecks = new Array();

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
    return failedChecks;
}

/**
 * Static method to validate a given checkbox field as a boolean value
 * @param field The checkbox field to validate
 * @return an array of all the errors found
 * @private
 */
hyf.validation.BooleanValidator.checkCheckBoxField = function(field)
{
    //Are any checks needed? - A Checkbox is already boolean, checked or not checked!
    return new Array();
}

/**
 * Static method to validate a given radio button field as a boolean value
 * @param field The radio field to validate
 * @return an array of all the errors found
 * @private
 */
hyf.validation.BooleanValidator.checkRadioField = function(field)
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

    return failedChecks;
}
