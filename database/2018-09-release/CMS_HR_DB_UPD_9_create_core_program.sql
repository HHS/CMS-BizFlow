/**
 * Gets current user group name
 *
 * @param I_KEY - a user's group key name
 *
 * @return a user's group name
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
