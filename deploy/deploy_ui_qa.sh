#!/bin/sh

#######################
# QA deploy
#######################
DEBUG_OPTION="debug"
DIR_TEST="success"

setVar(){
	if [ "$DEBUG_OPTION" == "-nodebug" ]
	then
		ISDEBUG="false"
	else
		ISDEBUG="true"
	fi
	ISTEMPFIX="false"
	DIR_DEBUGSRC="`pwd`"
	DIR_DEPLOY="/hrts/deploy/baseline"
	DIR_TOMCAT="/hrts/test/tomcat8/apache-tomcat-8.0.37"
	SRC_WEBAPPS="$DIR_DEPLOY/ui/runtime/webapps"
	TRG_WEBAPPS="$DIR_TOMCAT/webapps"
}

showVar(){
	echo "-------------------------------------"
	echo "ISDEBUG = " $ISDEBUG
	if [ "$ISDEBUG" == "true" ]
	then
		echo "*** NOTE: In order to run as non-debug mode, use -nodebug option."
	fi
	echo "DIR_DEBUGSRC = " $DIR_DEBUGSRC
	echo "ISTEMPFIX    = " $ISTEMPFIX
	echo "DIR_DEPLOY   = " $DIR_DEPLOY
	echo "DIR_TOMCAT   = " $DIR_TOMCAT
	echo "SRC_WEBAPPS  = " $SRC_WEBAPPS
	echo "TRG_WEBAPPS  = " $TRG_WEBAPPS
	echo "Timestamp    = " $(date +"%Y-%m-%d %H:%M:%S %z")
	echo "-------------------------------------"
	if [ ! -d "$DIR_DEPLOY" ]
	then
		echo "*** ERROR: $DIR_DEPLOY does not exist."
		DIR_TEST="fail"
	fi
	if [ ! -d "$DIR_TOMCAT" ]
	then
		echo "*** ERROR: $DIR_TOMCAT does not exist."
		DIR_TEST="fail"
	fi
	if [ ! -d "$SRC_WEBAPPS" ]
	then
		echo "*** ERROR: $SRC_WEBAPPS does not exist."
		DIR_TEST="fail"
	fi
	if [ ! -d "$TRG_WEBAPPS" ]
	then
		echo "*** ERROR: $TRG_WEBAPPS does not exist."
		DIR_TEST="fail"
	fi

	echo "DIR_TEST  = " $DIR_TEST
	echo "-------------------------------------"
}

startTomcat(){
	echo "-----"
	echo "Starting tomcat ..."
	if [ "$ISDEBUG" == "true" ]
	then
		$DIR_DEBUGSRC/script1.sh
	else
		$DIR_TOMCAT/bin/hrts-startup.sh
	fi
	echo
}

stopTomcat(){
	echo "-----"
	echo "Stopping tomcat ..."
	if [ "$ISDEBUG" == "true" ]
	then
		$DIR_DEBUGSRC/script1.sh
		echo
		echo "sleeping for 3 seconds..."
		sleep 3s
	else
		$DIR_TOMCAT/bin/hrts-shutdown.sh
		echo
		echo "sleeping for 2 minutes..."
		sleep 2m
	fi
	echo
}

copyBfCustom(){
	echo "-----"
	echo "Coping BizFlow customization files ..."
	if [ "$ISDEBUG" == "true" ]
	then
		$DIR_DEBUGSRC/script1.sh
	else
		# bizflow web customization file deploy
		cp -rf $SRC_WEBAPPS/bizflow $TRG_WEBAPPS
		# bizflow web customization configuration deploy
		cp -rf $SRC_WEBAPPS/../configuration/qa/tomcat/webapps/bizflow $TRG_WEBAPPS
	fi
	echo
}

copyWmRuntime(){
	echo "-----"
	echo "Coping WebMaker runtime files ..."
	if [ "$ISDEBUG" == "true" ]
	then
		$DIR_DEBUGSRC/script1.sh
	else
		# WebMaker runtime file deploy
		cp -rf $SRC_WEBAPPS/bizflowwebmaker $TRG_WEBAPPS
		# WebMaker configuration deploy
		cp -rf $SRC_WEBAPPS/../configuration/qa/tomcat/webapps/bizflowwebmaker $TRG_WEBAPPS
	fi
	echo
}

copyTempfix(){
	echo "-----"
	echo "Coping temporary fix runtime files ..."
	if [ "$ISDEBUG" == "true" ]
	then
		$DIR_DEBUGSRC/script1.sh
	else
		# BF custom fix which will be official patch later
		cp -rf $DIR_DEPLOY/../tempfix/attachUpload.jsp $TRG_WEBAPPS/bizflow/bizcoves/wih
		# WebMaker configuration deploy
		cp -rf $DIR_DEPLOY/../tempfix/cmspdf.jar $TRG_WEBAPPS/bizflowwebmaker/WEB-INF/lib
	fi
	echo
}


#========================
# MAIN operation
#========================
DEBUG_OPTION=$1
setVar
showVar
if [ "$DIR_TEST" == "success" ]
then
	stopTomcat
	copyBfCustom
	copyWmRuntime
	if [ "$ISTEMPFIX" == "true" ]
	then
		copyTempfix
	fi
	startTomcat
fi
