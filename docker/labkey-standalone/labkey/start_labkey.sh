#!/bin/bash
# 
#
# Copyright (c) 2014-2017 LabKey Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
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
