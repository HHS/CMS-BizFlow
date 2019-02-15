/**
 * Gets current user group name
 *
 * @param I_KEY - a user's group key name
 *
 * @return a user group name
 */
CREATE OR REPLACE FUNCTION FN_GET_USER_GROUP_NAME
  (
    I_KEY IN VARCHAR2
  )
  RETURN VARCHAR2
IS
  L_NAME VARCHAR2(100);

  BEGIN

    SELECT NAME INTO L_NAME FROM UG_MAPPING WHERE KEY = I_KEY;

    RETURN L_NAME;
  END;
/

/**
 * Gets current user group key
 *
 * @param I_NAME - a user's group name
 *
 * @return the key of a users group
 */
CREATE OR REPLACE FUNCTION FN_GET_USER_GROUP_KEY
  (
    I_NAME IN VARCHAR2
  )
  RETURN VARCHAR2
IS
  L_KEY VARCHAR2(100);

  BEGIN

    SELECT KEY INTO L_KEY FROM UG_MAPPING WHERE NAME = I_NAME;

    RETURN L_KEY;
  END;
/
