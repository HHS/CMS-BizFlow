
SET DEFINE OFF;

/*
	NOTICE: The update in this script should be run in BIZFLOW schema.
		This change does not need to be done in a higher level environment, e.g. PROD, 
		unless the previous BIX with the old application name had been deployed.
*/

-- WebMaker application name change from ERLR_Main to cms_erlr_main.
UPDATE BIZFLOW.PROCAPPDEF SET INVOKEDMETHOD = '[/SERVER/WEBMAKER[NAME=''BizFlow WebMaker Server'']]/cms_erlr_main/bizflowEntry.do' WHERE NAME = 'ER/LR Case Initiation';
UPDATE BIZFLOW.APPTMPLT SET INVOKEDMETHOD = '[/SERVER/WEBMAKER[NAME=''BizFlow WebMaker Server'']]/cms_erlr_main/bizflowEntry.do' WHERE NAME = 'ER/LR Case Initiation';
UPDATE BIZFLOW.PROCAPP SET INVOKEDMETHOD = '[/SERVER/WEBMAKER[NAME=''BizFlow WebMaker Server'']]/cms_erlr_main/bizflowEntry.do' WHERE NAME = 'ER/LR Case Initiation';
