#!/bin/bash
# 
# Start PostgreSQL and Tomcat Services 
# 

# Start X Virtual Frame Buffer 
/labkey/bin/xvfb.sh start

# Start PostgreSQL
/etc/init.d/postgresql start 

# Start Tomcat 
/labkey/bin/tomcat7.sh start 

# If Tomcat has started successfully, then do not exist the script. 
# If Tomcat is not running, then exit
running=0
PID=$(ps ax | grep bootstrap.jar | grep catalina)
if [ -n "$PID" ]
then
    sleep 10
    while [ ${running} -eq 0 ]
    do
        PID=$(ps ax | grep bootstrap.jar | grep catalina)
        if [ -n "$PID" ]
        then
            sleep 10
            running=0
        else
            running=1
            break
        fi
    done
else
    running=1
fi

exit running
