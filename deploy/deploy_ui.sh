#!/bin/sh

#######################
# deployment variables
#######################
INPUT1=$1
INPUT2=$2
ENV=
DEBUG_OPTION="debug"
DIR_TEST="success"
CURDATE1=$(date +%Y%m%d)
CURDATE2=$(date +%Y-%m-%d)
CURDATETIME=$(date +%Y%m%d_%H%M%S)

# script error logging
LOG_FILE=



setEnv()
{

	if [ "$INPUT1" == "dev" ] 
	then
		ENV=dev
	elif [ "$INPUT1" == "qa" ] 
	then
		ENV=test
	elif [ "$INPUT1" == "prod" ] 
	then
		ENV=prod
	else
		echo "ERROR: You must specify environment (dev, qa, prod)" 1>&3
		exit 1
	fi

}


setVar(){

	DEBUG_OPTION=$INPUT2
	if [ "$DEBUG_OPTION" == "-nodebug" ]
	then
		ISDEBUG="false"
	else
		ISDEBUG="true"
	fi
	ISTEMPFIX="false"
	DIR_DEBUGSRC="`pwd`"
	DIR_DEPLOY="/hrts/deploy/baseline"
	DIR_TOMCAT="/hrts/$ENV/tomcat8/apache-tomcat-8.0.37"
	SRC_WEBAPPS="$DIR_DEPLOY/ui/runtime/webapps"
	TRG_WEBAPPS="$DIR_TOMCAT/webapps"
	setupLog
}


setupLog()
{
	LOG_FILE="ui-deploy-$ENV-$CURDATETIME.log"
	exec 3>&1 4>&2
	trap 'exec 2>&4 1>&3' 0 1 2 3
	exec 1>${LOG_FILE} 2>&1
}


showVar(){

	echo "-------------------------------------"            | tee /dev/fd/3
	echo "ENV     = $ENV"                                   | tee /dev/fd/3
	echo "ISDEBUG = $ISDEBUG"                               | tee /dev/fd/3
	if [ "$ISDEBUG" == "true" ]
	then
		echo "*** NOTE: In order to run as non-debug mode, use -nodebug option."
		echo
	fi
	echo "DIR_DEBUGSRC = " $DIR_DEBUGSRC                    | tee /dev/fd/3
	echo "ISTEMPFIX    = " $ISTEMPFIX                       | tee /dev/fd/3
	echo "DIR_DEPLOY   = " $DIR_DEPLOY                      | tee /dev/fd/3
	echo "DIR_TOMCAT   = " $DIR_TOMCAT                      | tee /dev/fd/3
	echo "SRC_WEBAPPS  = " $SRC_WEBAPPS                     | tee /dev/fd/3
	echo "TRG_WEBAPPS  = " $TRG_WEBAPPS                     | tee /dev/fd/3
	echo "Timestamp    = " $(date +"%Y-%m-%d %H:%M:%S %z")  | tee /dev/fd/3
	echo "-------------------------------------"            | tee /dev/fd/3
	if [ ! -d "$DIR_DEPLOY" ]
	then
		echo "*** ERROR: $DIR_DEPLOY does not exist."       | tee /dev/fd/3
		DIR_TEST="fail"
	fi
	if [ ! -d "$DIR_TOMCAT" ]
	then
		echo "*** ERROR: $DIR_TOMCAT does not exist."       | tee /dev/fd/3
		DIR_TEST="fail"
	fi
	if [ ! -d "$SRC_WEBAPPS" ]
	then
		echo "*** ERROR: $SRC_WEBAPPS does not exist."      | tee /dev/fd/3
		DIR_TEST="fail"
	fi
	if [ ! -d "$TRG_WEBAPPS" ]
	then
		echo "*** ERROR: $TRG_WEBAPPS does not exist."      | tee /dev/fd/3
		DIR_TEST="fail"
	fi

	echo "DIR_TEST  = " $DIR_TEST                           | tee /dev/fd/3
	echo "-------------------------------------"            | tee /dev/fd/3

}


startTomcat(){

	echo "----------"           | tee /dev/fd/3
	echo "Starting tomcat ..."  | tee /dev/fd/3
	if [ "$ISDEBUG" == "true" ]
	then
		$DIR_DEBUGSRC/script1.sh
	else
		$DIR_TOMCAT/bin/hrts-startup.sh
	fi
	echo

}


stopTomcat(){

	echo "----------"           | tee /dev/fd/3
	echo "Stopping tomcat ..."  | tee /dev/fd/3
	if [ "$ISDEBUG" == "true" ]
	then
		$DIR_DEBUGSRC/script1.sh
		echo
		echo "sleeping for 3 seconds..."  | tee /dev/fd/3
		sleep 3s
	else
		$DIR_TOMCAT/bin/hrts-shutdown.sh
		echo
		echo "sleeping for 1 minute..."   | tee /dev/fd/3
		sleep 1m
	fi
	echo

}


copyBfCustom(){

	echo "----------"                              | tee /dev/fd/3
	echo "Coping BizFlow customization files ..."  | tee /dev/fd/3
	if [ "$ISDEBUG" == "true" ]
	then
		$DIR_DEBUGSRC/script1.sh
	else
		# bizflow web customization file deploy
		cp -rf $SRC_WEBAPPS/bizflow $TRG_WEBAPPS
		# bizflow web customization configuration deploy
		cp -rf $SRC_WEBAPPS/../configuration/$INPUT1/tomcat/webapps/bizflow $TRG_WEBAPPS
		# bizflowrule web file deploy
		cp -rf $SRC_WEBAPPS/bizflowrule $TRG_WEBAPPS
	fi
	echo

}


copyWmRuntime(){

	echo "----------"                         | tee /dev/fd/3
	echo "Coping WebMaker runtime files ..."  | tee /dev/fd/3
	if [ "$ISDEBUG" == "true" ]
	then
		$DIR_DEBUGSRC/script1.sh
	else
		# WebMaker runtime file deploy
		cp -rf $SRC_WEBAPPS/bizflowwebmaker $TRG_WEBAPPS
		# WebMaker configuration deploy
		cp -rf $SRC_WEBAPPS/../configuration/$INPUT1/tomcat/webapps/bizflowwebmaker $TRG_WEBAPPS
	fi
	echo

}


copyTempfix(){

	echo "----------"                              | tee /dev/fd/3
	echo "Coping temporary fix runtime files ..."  | tee /dev/fd/3
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
setEnv
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
