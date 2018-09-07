/* ===================================================================================================
* WARNING – This file is part of the base implementation for WebMaker, so it should not be edited or changed for any project.
* These files are replaced if a project is re-imported to the WebMaker Studio or migrated to a new version of the product.
* For guidance on 'How do I override or clone Hyfinity webapp files such as CSS & javascript?', please read the following relevant FAQ entry:
* http://www.hyfinity.net/faq/index/solution_id/1113
==================================================================================================== */

/**
 * ValidationError.js
 *
 * Company: Hyfinity Ltd
 * Copyright (c) 2003
 *
 * Class to store details of a field that has failed a validation test
 *
 * @author Gerard Smyth
 * @version 1.0
 *
 */



hyf.validation.ValidationError = function(field, errorCode)
{
    this._field = field;
    this._errorCode = errorCode;
}


//initalize the 'static' error code variables
hyf.validation.ValidationError.ERROR_INVALID_TYPE = 1;
hyf.validation.ValidationError.ERROR_REQUIRED = 2;
hyf.validation.ValidationError.ERROR_NAN = 3;
hyf.validation.ValidationError.ERROR_INVALID_DATE = 4;
hyf.validation.ValidationError.ERROR_MAX_INCLUSIVE = 5;
hyf.validation.ValidationError.ERROR_MAX_EXCLUSIVE = 6;
hyf.validation.ValidationError.ERROR_MIN_INCLUSIVE = 7;
hyf.validation.ValidationError.ERROR_MIN_EXCLUSIVE = 8;
hyf.validation.ValidationError.ERROR_REGULAR_EXPRESSION = 9;
hyf.validation.ValidationError.ERROR_LENGTH = 10;
hyf.validation.ValidationError.ERROR_MIN_LENGTH = 11;
hyf.validation.ValidationError.ERROR_MAX_LENGTH = 12;
hyf.validation.ValidationError.ERROR_NOT_VALID_BOOLEAN = 13;
hyf.validation.ValidationError.ERROR_INVALID_TIME = 14;

//generic error for any other problems
hyf.validation.ValidationError.ERROR_INVALID = 99;


/**
 * Get the HTML field that has failed the test
 *
 * @return the field associated with this object
 */
hyf.validation.ValidationError.prototype.getField = function()
{
    return this._field;
}

/**
 * Sets the HTML field that this error relates to
 *
 * @param field The field to associate with this error.
 */
hyf.validation.ValidationError.prototype.setField = function(field)
{
    this._field = field;
}


/**
 * Get the code of the test that this field has failed
 *
 * @return the failed test error code
 */
hyf.validation.ValidationError.prototype.getErrorCode = function()
{
    return this._errorCode;
}
