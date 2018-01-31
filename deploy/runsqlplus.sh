#!/bin/sh

USERNAME=$1
PASSWORD=$2
HOST=localhost
PORT=$3
SERVICE=$4
OPTION=$5

echo "USERNAME  = $USERNAME"
echo "PASSWORD  = $PASSWORD"
echo "HOST      = $HOST"
echo "PORT      = $PORT"
echo "SERVICE   = $SERVICE"
echo "OPTION    = $OPTION"

if [ -z "$USERNAME" ] ||  [ -z "$PASSWORD" ] || [ -z "$HOST" ] || [ -z "$PORT" ] || [ -z "$SERVICE" ]
then
	echo "Required parameter: USERNAME, PASSWORD, HOST, PORT, SERVICE"
	exit 1
fi

if [ ! -z "$OPTION" ] && [ ! -f "$OPTION" ]
then
	echo "Not valid file path: $OPTION"
	exit 1
fi

export ORACLE_HOME=/opt/app/oracle/product/12.1.0/db_1

if [ "$OPTION" == ""  ]
then
	$ORACLE_HOME/bin/sqlplus $USERNAME/$PASSWORD@//$HOST:$PORT/$SERVICE
else

	$ORACLE_HOME/bin/sqlplus -L $USERNAME/$PASSWORD@//$HOST:$PORT/$SERVICE $OPTION
fi
