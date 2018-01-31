#!/bin/sh

# Enable JMX remote debugging
export CATALINA_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9825 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false" 


# Enable JMX remote debugging with SSL 
#export CATALINA_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9825 -Dcom.sun.management.jmxremote.ssl=true -Dcom.sun.management.jmxremote.authenticate=false" 

# Enable JMX remote debugging with authentication 
#export CATALINA_OPTS="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9825 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=true -Dcom.sun.management.jmxremote.access.file=../conf/jmxremote.access -Dcom.sun.management.jmxremote.password.file=../conf/jmxremote.password" 
