#!/bin/bash
#
#
# Copyright (c) 2016-2017 LabKey Corporation
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

# Start X Virtual Frame Buffer, PostgreSQL and Tomcat Services
#
# This entry point script will perform the following steps
# 1) Read secrets
#   - The required secrets are password for accessing LabKey database on PostgreSQL server
#     and Master Encryption Key used to access LabKey PropertyStore
#   - The secrets must be provided at RUN time using ENV variables
#       * PG_PASSWORD
#       * LABKEY_ENCRYPTION_KEY
# 2) Start X virtual frame buffer (required for R reports)
# 3) Start PostgreSQL Server and create "labkey" user
# 4) Using secrets read above start Tomcat server
#

#
# Read Secrets into variables to be used later in script
#
echo "Secrets: Reading secrets (ie passwords, etc) from environment"
if [ -z "$PG_PASSWORD" ]
then
    echo "ERROR: PG_PASSWORD environment variable does not exist. This is required to start LabKey Server"
    exit 1
else
    POSTGRESQL_PASSWORD="$PG_PASSWORD"
fi

if [ -z "$LABKEY_ENCRYPTION_KEY" ]
then
    echo "ERROR: LABKEY_ENCRYPTION_KEY environment variable does not exist. This is required to start LabKey Server"
    exit 1
else
    MASTER_ENC_KEY="$LABKEY_ENCRYPTION_KEY"
fi


#
# Start X Virtual Frame Buffer
#

echo "X VIRTUAL FRAME BUFFER: Starting Process "
XVFB=/usr/bin/Xvfb
XVFB_OPTIONS=":2 -nolisten tcp -shmem -extension GLX"
$XVFB $XVFB_OPTIONS &
RETVAL=$?
sleep 2  # Added to ensure start-up is successful

if [ $RETVAL -eq 0 ]
then
    echo "X VIRTUAL FRAME BUFFER started successfully"
else
    echo "X VIRTUAL FRAME BUFFER did not start properly"
    exit 1
fi

#
# Start PostgreSQL
#
echo "POSTGRESQL SERVER: Starting database server "
INSTALLDIR=/labkey/apps/postgresql
PGDATA=$INSTALLDIR/data
BINDIR=$INSTALLDIR/bin

if su - postgres -c "$BINDIR/pg_ctl -w start -D \"$PGDATA\"";
then
    echo "POSTGRESQL SERVER started successfully"
else
    echo "ERROR: POSTGRESQL SERVER did not start in a timely fashion"
    exit 1
fi

# Create new user account on PostgreSQL server. Username=labkey
if [ ! -f  /labkey/apps/postgresql/data/.LABKEY-ACCOUNT-CREATED ]
then
    if su - postgres -c "$BINDIR/psql --command \"CREATE USER labkey WITH SUPERUSER PASSWORD '$POSTGRESQL_PASSWORD';\""
    then
        echo "PostgreSQL user account successfully created"
        touch /labkey/apps/postgresql/data/.LABKEY-ACCOUNT-CREATED
    else
        echo "ERROR: Failure during creation of PostgreSQL user account"
        exit 1
    fi
fi


#
# Start Tomcat
#

# Customize configuration files using EVN variables
echo "TOMCAT: Starting Tomcat Server to run LabKey Server application"
INSTALLDIR=/labkey/apps/tomcat

# Customize LabKey configuration file
sed -i s/'@@PG_PASSWORD@@'/"$POSTGRESQL_PASSWORD"/g $INSTALLDIR/conf/Catalina/localhost/ROOT.xml
sed -i s/'@@ENCRYPTION_KEY@@'/"$MASTER_ENC_KEY"/g $INSTALLDIR/conf/Catalina/localhost/ROOT.xml
sed -i s/'@@PG_HOST@@'/"$PG_HOST"/g $INSTALLDIR/conf/Catalina/localhost/ROOT.xml

if [ -f /labkey/apps/SSL/keystore.tomcat ]
then
    sed -i s/'@@KEYSTORE_PASSPHRASE@@'/"$KEYSTORE_PASSPHRASE"/g /labkey/apps/tomcat/conf/server.xml
fi


# Start Tomcat Server
if ! /labkey/bin/start_tomcat.sh start
then
    echo "ERROR: TOMCAT did not start in a timely fashion"
    exit 1
fi

echo "LabKey Server application has been successfully started"

# Tomcat has started successfully. Now execute the CMD
if [ "$1" = '/labkey/bin/check_labkey.sh' ]
then
    exec "$@"
fi

exec "$@"



