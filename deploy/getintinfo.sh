#!/bin/sh 

INPUT1=$1
INPUT2=$2
ENV=
APPPROP=noappprop
BASEDIR=$(cd `dirname $0` && pwd)
TRG_DIR=$BASEDIR/integinfo



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

	if [ "$INPUT2" == "appprop" ] 
	then
		APPPROP=incappprop
	else
		APPPROP=noappprop
	fi
	
	echo "APPPROP = $APPPROP"

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
}


zipFile()
{
	#cd $TRG_DIR
	
	if [ "$APPPROP" == "incappprop" ] 
	then
		zip -r integinfo-appprop-$ENV.zip $TRG_DIR
	else
		zip -r integinfo-$ENV.zip $TRG_DIR
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


