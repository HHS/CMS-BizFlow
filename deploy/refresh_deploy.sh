#!/bin/sh

################################
# Refresh deployment files
################################

VARTEST="success"
FILEPATH=$1
FILENAME=${FILEPATH##*/}
PW=
DIR_SRCDIR=~/deploy/baseline/ui
DIR_COPY=/hrts/copydir
DIR_DEPLOYUI=/hrts/deploy/baseline/ui
ADMUSR=sa-bizdev



getPw(){
	read -rs -p "Enter password: " PW
}

testVar(){
	echo "-------------------------------------"
	echo "FILEPATH     = " $FILEPATH
	echo "FILENAME     = " $FILENAME
	echo "DIR_SRCDIR   = " $DIR_SRCDIR
	echo "DIR_COPY     = " $DIR_COPY
	echo "DIR_DEPLOYUI = " $DIR_DEPLOYUI
	echo "Timestamp    = " $(date +"%Y-%m-%d %H:%M:%S %z")
	echo "-------------------------------------"
	if [ -z "$PW" ]
	then
		echo "*** ERROR: password is not set."
		VARTEST="fail"
	fi
	if [ -z "$FILEPATH" ]
	then
		echo "*** ERROR: FILEPATH is not specified in command argument."
		VARTEST="fail"
	fi
	if [ ! -d "$DIR_SRCDIR" ]
	then
		echo "*** ERROR: $DIR_SRCDIR does not exist."
		VARTEST="fail"
	elif [ ! -e "$DIR_SRCDIR/$FILENAME" ]
	then
		echo "*** ERROR: $DIR_SRCDIR/$FILENAME does not exist."
		VARTEST="fail"
	fi
	if [ ! -d "$DIR_COPY" ]
	then
		echo "*** ERROR: $DIR_COPY does not exist."
		VARTEST="fail"
	fi
	if [ ! -d "$DIR_DEPLOYUI" ]
	then
		echo "*** ERROR: $DIR_DEPLOYUI does not exist."
		VARTEST="fail"
	fi

	echo "VARTEST  = " $VARTEST
	echo "-------------------------------------"
 
}

refresh(){
	cd $DIR_COPY
	rm runtime_*
	cp -f $DIR_SRCDIR/$FILENAME .
	chmod 666 $FILENAME
	
	echo $PW | sudo -kS su $ADMUSR
	cd $DIR_COPY
	cp -f $FILENAME $DIR_DEPLOYUI
	cd $DIR_DEPLOYUI
	rm -rf runtime
	unzip $FILENAME
	cd ../..
	#./deploy_ui_dev.sh -nodebug
}


################################
# MAIN program
################################
getPw
testVar
if [ "$VARTEST" == "success" ]
then
	echo "Variable test was successfull.  Refreshing deployment file..."
	refresh
fi