#!/bin/sh 

INPUT1=$1
INPUT2=$2
INPUT3=$3
ENV=
APPPROP=noappprop
BASEDIR=$(cd `dirname $0` && pwd)
TRG_DIR=$BASEDIR/log
BF_DIR=/bizflow/$ENV
WS_DIR=/hrts/$ENV/tomcat8/apache-tomcat-8.0.37
CURDATE1=$(date +%Y%m%d)
CURDATE2=$(date +%Y-%m-%d)
DATEDLOG=


setEnv()
{
	if [ "$INPUT1" == "dev" ] 
	then
		ENV=dev
	elif [ "$INPUT1" == "qa" ] 
	then
		ENV=test
	elif [ "$INPUT1" == "prd" ] 
	then
		ENV=prod
	else
		echo "You must specify environment (dev, qa, prd)"
		exit 1
	fi
	
	echo "ENV = $ENV"
}


setOption()
{
	echo
	echo "Specify \"appprop\" as the second parameter to capture properties files."
	if [ "$INPUT2" == "appprop" ] 
	then
		APPPROP=incappprop
	else
		APPPROP=noappprop
	fi
	echo "APPPROP = $APPPROP"
	
	echo 
	echo "Specify \"dated\" as the third parameter to capture only current dated logs."
	if [[ ( "$INPUT2" == "dated" ) || ( "$INPUT3" == "dated" ) ]] 
	then
		DATEDLOG=dated
	else
		DATEDLOG=all
	fi
	echo "DATEDLOG = $DATEDLOG"
}


prepareDir()
{
	if [ -d  "$TRG_DIR" ] 
	then
		echo "Deleting target directory for clean up."
		rm -rf $TRG_DIR 
	fi

	mkdir -p $TRG_DIR/$ENV/biis/logs
	mkdir -p $TRG_DIR/$ENV/usas/logs
	mkdir -p $TRG_DIR/$ENV/caphr/logs
	mkdir -p $TRG_DIR/$ENV/bf/logs
	mkdir -p $TRG_DIR/$ENV/ws/logs
}


copyFile()
{
	if [ "$APPPROP" == "incappprop" ] 
	then
		cp /hrts/$ENV/biis/application.properties $TRG_DIR/$ENV/biis
	fi
	cp /hrts/$ENV/biis/logs/* $TRG_DIR/$ENV/biis/logs

	if [ "$APPPROP" == "incappprop" ] 
	then
		cp /hrts/$ENV/usas/application.properties $TRG_DIR/$ENV/usas
	fi
	cp /hrts/$ENV/usas/report.properties $TRG_DIR/$ENV/usas
	cp /hrts/$ENV/usas/logs/* $TRG_DIR/$ENV/usas/logs

	if [ "$APPPROP" == "incappprop" ] 
	then
		cp /hrts/$ENV/caphr/application.properties $TRG_DIR/$ENV/caphr
	fi
	cp /hrts/$ENV/caphr/logs/* $TRG_DIR/$ENV/caphr/logs


	if [ "$DATEDLOG" == "dated" ] 
	then
		cp $BF_DIR/logs/bizflow_dev_$CURDATE1.log $TRG_DIR/$ENV/bf/logs
		cp $BF_DIR/logs/callera.log               $TRG_DIR/$ENV/bf/logs
		cp $BF_DIR/logs/credb.log                 $TRG_DIR/$ENV/bf/logs
		cp $BF_DIR/logs/hworaexe.log              $TRG_DIR/$ENV/bf/logs
		cp $BF_DIR/logs/hworaole.log              $TRG_DIR/$ENV/bf/logs
		cp $BF_DIR/logs/hwqueue.log               $TRG_DIR/$ENV/bf/logs
		cp $BF_DIR/logs/hwschd.log                $TRG_DIR/$ENV/bf/logs
		cp $BF_DIR/logs/hwserd.log                $TRG_DIR/$ENV/bf/logs
		cp $BF_DIR/logs/process.log               $TRG_DIR/$ENV/bf/logs

		cp $BF_DIR/bizflowera/log/default-$CURDATE2*.log $TRG_DIR/$ENV/bf/logs
		cp $BF_DIR/bizflowera/log/era.log                $TRG_DIR/$ENV/bf/logs
		cp $BF_DIR/bizflowera/log/wrapper.log            $TRG_DIR/$ENV/bf/logs

		cp $WS_DIR/logs/catalina.$CURDATE2.log             $TRG_DIR/$ENV/ws/logs
		cp $WS_DIR/logs/catalina.out                       $TRG_DIR/$ENV/ws/logs
		cp $WS_DIR/logs/cmspdf.log                         $TRG_DIR/$ENV/ws/logs
		cp $WS_DIR/logs/cmspdf_performance.log             $TRG_DIR/$ENV/ws/logs
		cp $WS_DIR/logs/host-manager.$CURDATE2.log         $TRG_DIR/$ENV/ws/logs
		cp $WS_DIR/logs/localhost.$CURDATE2.log            $TRG_DIR/$ENV/ws/logs
		cp $WS_DIR/logs/localhost_access_log.$CURDATE2.log $TRG_DIR/$ENV/ws/logs
		cp $WS_DIR/logs/manager.$CURDATE2.log              $TRG_DIR/$ENV/ws/logs
		
		cp $WS_DIR/webapps/bizflowadvreport/WEB-INF/logs/jasperserver.log   $TRG_DIR/$ENV/ws/logs
		cp $WS_DIR/webapps/bizflowadvreport/WEB-INF/logs/jasperserver.log.1 $TRG_DIR/$ENV/ws/logs
	else
		cp $BF_DIR/logs/*.log $TRG_DIR/$ENV/bf/logs
		cp $BF_DIR/bizflowera/log/*.log $TRG_DIR/$ENV/bf/logs
		cp $WS_DIR/logs/*.log $TRG_DIR/$ENV/ws/logs
		cp $WS_DIR/webapps/bizflowadvreport/WEB-INF/logs/*.log $TRG_DIR/$ENV/ws/logs
	fi
}


zipFile()
{
	#cd $TRG_DIR
	
	if [ "$APPPROP" == "incappprop" ] 
	then
		zip -r log-appprop-$ENV.zip $TRG_DIR
	else
		zip -r log-$ENV.zip $TRG_DIR
	fi
}




#========================
# MAIN operation
#========================
setEnv
setOption
prepareDir
copyFile
zipFile


