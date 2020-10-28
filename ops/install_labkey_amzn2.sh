#!/usr/bin/env bash

#
#  Copyright (c) 2020 LabKey Corporation. All rights reserved. No portion of this work may be reproduced in
#  any form or by any electronic or mechanical means without written permission from LabKey Corporation.
#

#  This script will install LabKey and its pre-requisites on RedHat 7+ based operating systems
#  It has been tested on Amazon Linux 2
#  TBD Tested on Redhat7, CentOS7

if [[ $(whoami) != root ]]; then
    echo Please run this script as root or using sudo
    exit
fi

# ----------Configurable Variables --------------------

# ----- Default Secrets you should change!!! ----------
# -- use only alpahnumeric only as these are not escaped for bash!
TOMCAT_SSL_KEYSTORE_PASS="------Keystore-CHANGE-ME-1------"
POSTGRES_DB_USER_PASSWORD="------DBUser-CHANGE-ME-2--------"
LABKEY_MEK="------MEK----CHANGE-ME-2--------"
#
#
LABKEY_APP_HOME="/labkey"
LABKEY_SRC_HOME="$LABKEY_APP_HOME/src/labkey"
LABKEY_INSTALL_HOME="$LABKEY_APP_HOME/labkey"
LABKEY_DIST_URL="https://labkey.s3.amazonaws.com/downloads/general/r/20.7.6/LabKey20.7.6-65948.16-community-bin.tar.gz"
LABKEY_DIST_FILENAME="LabKey20.7.6-65948.16-community-bin.tar.gz"
LABKEY_DIST_FILENAME_NO_TARGZ=${LABKEY_DIST_FILENAME::-7}
TOMCAT_INSTALL_HOME="$LABKEY_APP_HOME/apps/tomcat"
TOMCAT_TIMEZONE="America/Los_Angeles"
CATALINA_HOME="$TOMCAT_INSTALL_HOME"
TOMCAT_USERNAME="tomcat"
# Tomcat Version to download and install
TOMCAT_VERSION=9.0.39
TOMCAT_UID=3000
TOMCAT_KEYSTORE_FILENAME="keystore.tomcat.p12"
TOMCAT_URL="http://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz"
# Local Postgresql vars
POSTGRES_DB_USER="labkey"
POSTGRES_DB_NAME="labkey"
POSTGRES_DB_SERVER_URL="localhost"
POSTGRES_SVR_LOCAL="TRUE"
# Java vars
JAVA_INSTALL_HOME="/usr/lib/jvm"
JAVA_DOWNLOAD_URL="https://download.java.net/java/GA/jdk15.0.1/51f4f36ad4ef43e39d0dfdbaf6549e32/9/GPL/openjdk-15.0.1_linux-x64_bin.tar.gz"
JAVA_FILE_NAME="openjdk-15.0.1_linux-x64_bin.tar.gz"
JAVA_DIST_VERSION="jdk-15.0.1"
JAVA_HOME="$JAVA_INSTALL_HOME/$JAVA_DIST_VERSION"
JAVA_HEAP_SIZE="2G"
# Local file path overide to download files - e.g. no internet access
LOCAL_FILE_SRC_PATH="/home/ec2-user"
USE_LOCAL_SRC_FILES="FALSE"
SMTP_SERVER="localhost"

# ---------- end of configurable variables --------------------

LABKEY_INSTALLER_CMD="$LABKEY_SRC_HOME/$LABKEY_DIST_FILENAME_NO_TARGZ/manual-upgrade.sh -l $LABKEY_INSTALL_HOME/ -d $LABKEY_SRC_HOME/$LABKEY_DIST_FILENAME_NO_TARGZ -c $TOMCAT_INSTALL_HOME -u $TOMCAT_USERNAME --tomcat_lk "

# define bold and normal text
bold=$(tput bold)
normal=$(tput sgr0)


# output the directories and variables to be used
echo ""
echo ""
echo ""
echo "${normal}---------${bold}  $(date)  -- LabKey Install parameters ${normal} ---------"
echo "LABKEY_APP_HOME= $LABKEY_APP_HOME"
echo "LABKEY_SRC_HOME= $LABKEY_SRC_HOME"
echo "LABKEY_INSTALL_HOME= $LABKEY_INSTALL_HOME"
echo "LABKEY_DIST_URL = $LABKEY_DIST_URL"
echo "LABKEY_DIST_FILENAME = $LABKEY_DIST_FILENAME"
echo "TOMCAT_VERSION = $TOMCAT_VERSION"
echo "TOMCAT_INSTALL_HOME= $TOMCAT_INSTALL_HOME"
echo "TOMCAT-TMP = $LABKEY_APP_HOME/tomcat-tmp"
echo "TOMCAT_TIMEZONE= $TOMCAT_TIMEZONE"
echo "CATALINA_HOME= $CATALINA_HOME"
echo "TOMCAT_USERNAME= $TOMCAT_USERNAME"
echo "TOMCAT_UID = $TOMCAT_UID"
echo "TOMCAT_KEYSTORE_FILENAME = $TOMCAT_KEYSTORE_FILENAME"
echo ""
echo "${bold}----- You really should consider changing these! ...-----"
echo "use alpahnumeric chars only as these are not escaped for bash! - you have been warned!"
echo "TOMCAT_SSL_KEYSTORE_PASS = $TOMCAT_SSL_KEYSTORE_PASS"
echo "POSTGRES_DB_USER_PASSWORD = $POSTGRES_DB_USER_PASSWORD"
echo "LABKEY_MEK = $LABKEY_MEK"
echo "-------------------------------------------------------${normal}"
echo ""
echo "JAVA_INSTALL_HOME= $JAVA_INSTALL_HOME"
echo "JAVA_DOWNLOAD_URL= $JAVA_DOWNLOAD_URL"
echo "JAVA_FILE_NAME= $JAVA_FILE_NAME"
echo "JAVA_DIST_VERSION= $JAVA_DIST_VERSION"
echo "JAVA_HOME= $JAVA_HOME"
echo "JAVA_HEAP_SIZE= $JAVA_HEAP_SIZE"
echo "POSTGRES_DB_NAME= $POSTGRES_DB_NAME"
echo "POSTGRES_DB_USER = $POSTGRES_DB_USER"
echo "POSTGRES_DB_SERVER_URL = $POSTGRES_DB_SERVER_URL"
echo "POSTGRES_SVR_LOCAL = $POSTGRES_SVR_LOCAL"
echo ""
echo "SMTP_SERVER = $SMTP_SERVER"
echo ""
echo "USE_LOCAL_SRC_FILES = $USE_LOCAL_SRC_FILES"
echo ""
echo "${normal}---------${bold} End of parameters ${normal}---------"
echo " --- ${bold} Does this information look correct? Shall I proceed at installing the prerequsites files and directories? ${normal} (1=Yes/2=No) no exits this script --- "
select yn in "Yes" "No"; do
     case $yn in
         Yes ) echo " ---${bold} Installing prerequsites and creating directories ${normal}----" ; break;;
          No ) echo " ---${bold} exiting - no action taken ${normal} ----" && exit;;
        esac
done

sudo yum update -y

# add tomcat user
useradd -r -m -u $TOMCAT_UID -U -s '/bin/false' $TOMCAT_USERNAME
echo "a tomcat service acount user as been as $TOMCAT_USERNAME "

#create directories
mkdir -p "$LABKEY_APP_HOME"
mkdir -p "$LABKEY_SRC_HOME"
mkdir -p "$TOMCAT_INSTALL_HOME"
mkdir -p "$JAVA_INSTALL_HOME"

mkdir -p "$LABKEY_APP_HOME/bin"
mkdir -p "$LABKEY_INSTALL_HOME"
mkdir -p "$LABKEY_INSTALL_HOME/externalModules"
mkdir -p "$LABKEY_INSTALL_HOME/labkeywebapp"
mkdir -p "$LABKEY_INSTALL_HOME/logs"
mkdir -p "$LABKEY_INSTALL_HOME/modules"
mkdir -p "$LABKEY_INSTALL_HOME/pipeline-lib"
mkdir -p "$LABKEY_INSTALL_HOME/startup"

mkdir -p "$LABKEY_APP_HOME/tomcat-tmp"
mkdir -p "$CATALINA_HOME/lib"
mkdir -p "$CATALINA_HOME/conf/Catalina/localhost"
mkdir -p "$TOMCAT_INSTALL_HOME/temp"
mkdir -p "$TOMCAT_INSTALL_HOME/SSL"

# download and install java
cd $LABKEY_SRC_HOME || exit
if [ "$USE_LOCAL_SRC_FILES" == "TRUE" ]; then
    cp -a /$LOCAL_FILE_SRC_PATH/$JAVA_FILE_NAME /$LABKEY_SRC_HOME
  else
wget $JAVA_DOWNLOAD_URL
fi

tar -xvzf $LABKEY_SRC_HOME/$JAVA_FILE_NAME -C $JAVA_INSTALL_HOME/
# set java path for all users
JavaEnvFile='/etc/profile.d/java_env.sh'
(
/bin/cat << JAVAHEREDOC
export JAVA_HOME=$JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH
JAVAHEREDOC
) > $JavaEnvFile

# download and install tomcat v9
cd $LABKEY_SRC_HOME || exit
if [ "$USE_LOCAL_SRC_FILES" == "TRUE" ]; then
    cp -a /$LOCAL_FILE_SRC_PATH/apache-tomcat-$TOMCAT_VERSION.tar.gz $LABKEY_SRC_HOME
  else
    wget --no-verbose $TOMCAT_URL
fi
tar xzf apache-tomcat-$TOMCAT_VERSION.tar.gz
cp -aR $LABKEY_SRC_HOME/apache-tomcat-$TOMCAT_VERSION/* $TOMCAT_INSTALL_HOME/
chmod 0755 $TOMCAT_INSTALL_HOME
chown -R $TOMCAT_USERNAME.$TOMCAT_USERNAME $TOMCAT_INSTALL_HOME
chown -R $TOMCAT_USERNAME.$TOMCAT_USERNAME "$LABKEY_APP_HOME/tomcat-tmp"
chown -R $TOMCAT_USERNAME.$TOMCAT_USERNAME $LABKEY_INSTALL_HOME
rm $LABKEY_SRC_HOME/apache-tomcat-$TOMCAT_VERSION.tar.gz
rm -Rf $LABKEY_SRC_HOME/apache-tomcat-$TOMCAT_VERSION
chmod 0700 "$CATALINA_HOME/conf/Catalina/localhost"

#create tomcat_lk systemd service file
NewFile='/etc/systemd/system/tomcat_lk.service'
(
/bin/cat << HEREDOC
# Systemd unit file for tomcat_lk

[Unit]
Description=lk Apache Tomcat Application
After=syslog.target network.target

[Service]
Type=forking
Environment="JAVA_HOME=$JAVA_HOME"
Environment="CATALINA_BASE=$TOMCAT_INSTALL_HOME"
Environment="CATALINA_OPTS=-Djava.library.path=/usr/lib64 -Djava.awt.headless=true -Duser.timezone=$TOMCAT_TIMEZONE -Xms$JAVA_HEAP_SIZE -Xmx$JAVA_HEAP_SIZE -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$LABKEY_APP_HOME/tomcat-tmp -Djava.net.preferIPv4Stack=true"
Environment="CATALINA_TMPDIR=$LABKEY_APP_HOME/tomcat-tmp"


ExecStart=$TOMCAT_INSTALL_HOME/bin/catalina.sh start
ExecStop=$TOMCAT_INSTALL_HOME/bin/catalina.sh stop
SuccessExitStatus=0 143
Restart=on-failure
RestartSec=2

User=tomcat
Group=tomcat

[Install]
WantedBy=multi-user.target
HEREDOC
) > $NewFile

# create tomcat context.xml
TomcatContextFile="$CATALINA_HOME/conf/context.xml"
(
/bin/cat << "CONTEXTHERE"
<?xml version='1.0' encoding='utf-8' ?>
<Context useHttpOnly="true" >
    <WatchedResource>WEB-INF/web.xml</WatchedResource>
    <WatchedResource>${catalina.base}/conf/web.xml</WatchedResource>
</Context>
CONTEXTHERE
) > $TomcatContextFile
chmod 600 $TomcatContextFile

#create self-signed cert
chown -R $TOMCAT_USERNAME.$TOMCAT_USERNAME "$TOMCAT_INSTALL_HOME/SSL"
$JAVA_HOME/bin/keytool -genkeypair -dname 'CN=127.0.0.1, OU=LabKey, O=LabKey, L=Seatle, S=Washington, C=US' -alias tomcat -keyalg RSA -keysize 4096 -validity 720 -keystore  $TOMCAT_INSTALL_HOME/SSL/$TOMCAT_KEYSTORE_FILENAME -storepass $TOMCAT_SSL_KEYSTORE_PASS -keypass $TOMCAT_SSL_KEYSTORE_PASS -ext SAN=dns:localhost,ip:127.0.0.1
$JAVA_HOME/bin/keytool -exportcert -alias tomcat -file $TOMCAT_INSTALL_HOME/SSL/tomcat.cer -keystore $TOMCAT_INSTALL_HOME/SSL/$TOMCAT_KEYSTORE_FILENAME -storepass $TOMCAT_SSL_KEYSTORE_PASS

echo "A Self signed SSL certificate has been created and stored in the keystoreFile at $TOMCAT_INSTALL_HOME/SSL/$TOMCAT_KEYSTORE_FILENAME"

# create tomcat server.xml
TomcatServerFile="$CATALINA_HOME/conf/server.xml"
(
/bin/cat << SERVERXMLHERE
<?xml version='1.0' encoding='utf-8' ?>
<!--
    Licensed to the Apache Software Foundation (ASF) under one or more
    contributor license agreements. See the NOTICE file distributed with
    this work for additional information regarding copyright ownership.
    The ASF licenses this file to You under the Apache License, Version 2.0
    (the "License"); you may not use this file except in compliance with
    the License. You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
-->

<!--
    Note: A "Server" is not itself a "Container", so you may not define
    subcomponents such as "Valves" at this level.
    Documentation at /docs/config/server.html
-->
<Server port="8005" shutdown="SHUTDOWN">

    <!--
        APR library loader.
        Documentation at /docs/apr.html
    -->
    <Listener
        className="org.apache.catalina.core.AprLifecycleListener"
        SSLEngine="on"
        useAprConnector="true"
    />

    <Listener className="org.apache.catalina.startup.VersionLoggerListener" />

    <!--
        Security listener.
        Documentation at /docs/config/listeners.html
    -->
    <Listener className="org.apache.catalina.security.SecurityListener" />

    <!--
        Prevent memory leaks due to use of particular java/javax APIs
    -->
    <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
    <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
    <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

    <!--
        Global JNDI resources
        Documentation at /docs/jndi-resources-howto.html
    -->
    <GlobalNamingResources>

        <!--
            Editable user database that can also be used by UserDatabaseRealm
            to authenticate users
        -->
        <Resource
            name="UserDatabase"
            auth="Container"
            type="org.apache.catalina.UserDatabase"
            description="User database that can be updated and saved"
            factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
            pathname="conf/tomcat-users.xml"
        />

    </GlobalNamingResources>

    <!--
        A "Service" is a collection of one or more "Connectors" that share a
        single "Container" Note: A "Service" is not itself a "Container", so
        you may not define subcomponents such as "Valves" at this level.
        Documentation at /docs/config/service.html
    -->
    <Service name="Catalina">

        <!--
            The connectors will use a shared executor, you can define one or
            more named thread pools. For LabKey Server, a single shared pool
            will be used for all connectors.
        -->
        <Executor
            name="tomcatSharedThreadPool"
            namePrefix="catalina-exec-"
            maxThreads="300"
            minSpareThreads="25"
            maxIdleTime="20000"
        />

        <!-- Define HTTP connector -->
        <Connector
            port="8080"
            redirectPort="8443"
            scheme="http"
            protocol="org.apache.coyote.http11.Http11AprProtocol"
            executor="tomcatSharedThreadPool"
            acceptCount="100"
            connectionTimeout="20000"
            disableUploadTimeout="true"
            enableLookups="false"
            maxHttpHeaderSize="8192"
            minSpareThreads="25"
            useBodyEncodingForURI="true"
            URIEncoding="UTF-8"
            compression="on"
            compressionMinSize="2048"
            noCompressionUserAgents="gozilla, traviata"
            compressableMimeType="text/html,text/xml,text/css,application/json"
        >
            <UpgradeProtocol className="org.apache.coyote.http2.Http2Protocol" />
        </Connector>


        <!-- Define HTTPS connector -->
        <Connector
            port="8443"
            scheme="https"
            secure="true"
            SSLEnabled="true"
            sslEnabledProtocols="TLSv1.2"
            sslProtocol="TLSv1.2"
            ciphers="TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA,
                     TLS_ECDH_ECDSA_WITH_AES_128_CBC_SHA256,
                     TLS_ECDH_ECDSA_WITH_AES_128_GCM_SHA256,
                     TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA,
                     TLS_ECDH_ECDSA_WITH_AES_256_CBC_SHA384,
                     TLS_ECDH_ECDSA_WITH_AES_256_GCM_SHA384,
                     TLS_ECDH_RSA_WITH_AES_128_CBC_SHA,
                     TLS_ECDH_RSA_WITH_AES_128_CBC_SHA256,
                     TLS_ECDH_RSA_WITH_AES_128_GCM_SHA256,
                     TLS_ECDH_RSA_WITH_AES_256_CBC_SHA,
                     TLS_ECDH_RSA_WITH_AES_256_CBC_SHA384,
                     TLS_ECDH_RSA_WITH_AES_256_GCM_SHA384,
                     TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA,
                     TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256,
                     TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256,
                     TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA,
                     TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384,
                     TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384,
                     TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,
                     TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256,
                     TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,
                     TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA,
                     TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384,
                     TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
            protocol="org.apache.coyote.http11.Http11AprProtocol"
            executor="tomcatSharedThreadPool"
            acceptCount="100"
            connectionTimeout="20000"
            clientAuth="false"
            disableUploadTimeout="true"
            enableLookups="false"
            maxHttpHeaderSize="8192"
            minSpareThreads="25"
            useBodyEncodingForURI="true"
            URIEncoding="UTF-8"
            compression="on"
            compressionMinSize="2048"
            noCompressionUserAgents="gozilla, traviata"
            compressableMimeType="text/html,text/xml,text/css,application/json"
            keystoreType="pkcs12"
            keystorePass="$TOMCAT_SSL_KEYSTORE_PASS"
            keystoreFile="$TOMCAT_INSTALL_HOME/SSL/$TOMCAT_KEYSTORE_FILENAME"
            maxThreads="150"
        >
            <UpgradeProtocol className="org.apache.coyote.http2.Http2Protocol" />
        </Connector>

        <!--
             Define an AJP 1.3 Connector on port 8009 -->
        <!-- Disable AJP -->
        <!--
        <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
        -->

        <!--
            An Engine represents the entry point (within Catalina) that
            processes every request. The Engine implementation for Tomcat stand
            alone analyzes the HTTP headers included with the request, and
            passes them on to the appropriate Host (virtual host).
            Documentation at /docs/config/engine.html
        -->
        <Engine name="Catalina" defaultHost="localhost">

            <!--
                Use the LockOutRealm to prevent attempts to guess user passwords
                via a brute-force attack
            -->
            <Realm className="org.apache.catalina.realm.LockOutRealm">

                <!--
                    This Realm uses the UserDatabase configured in the global JNDI
                    resources under the key "UserDatabase". Any edits
                    that are performed against this UserDatabase are immediately
                    available for use by the Realm.
                -->
                <Realm
                    className="org.apache.catalina.realm.UserDatabaseRealm"
                    resourceName="UserDatabase"
                />

            </Realm>

            <Host
                name="localhost"
                appBase="webapps"
                unpackWARs="true"
                autoDeploy="true"
            >

                <!--
                    pulls the remote IP from the XForward-For header
                -->
                <!-- Remote IP Valve -->
                <Valve className="org.apache.catalina.valves.RemoteIpValve" />

                <!--
                    Access log processes all example.
                    Documentation at: /docs/config/valve.html
                    Note: The pattern used is equivalent to using pattern="common"
                -->
                <Valve
                    className="org.apache.catalina.valves.AccessLogValve"
                    directory="logs"
                    prefix="localhost_access_log"
                    suffix=".txt"
                    resolveHosts="false"
                    pattern="%{org.apache.catalina.AccessLog.RemoteAddr}r %l %u %t &quot;%r&quot; %s %b %D %S &quot;%{Referer}i&quot; &quot;%{User-Agent}i&quot; %{LABKEY.username}s %q"
                />

            </Host>
        </Engine>
    </Service>
</Server>

SERVERXMLHERE
) >$TomcatServerFile
chmod 600 $TomcatServerFile
echo "Tomcat Server XML file created at $TomcatServerFile"

# create Tomcat ROOT.xml
TomcatROOTXMLFile="$CATALINA_HOME/conf/Catalina/localhost/ROOT.xml"
(
/bin/cat << ROOTXMLHERE
<?xml version='1.0' encoding='utf-8'?>
<Context docBase="/labkey/labkey/labkeywebapp" reloadable="true" crossContext="true">

    <Resource name="jdbc/labkeyDataSource" auth="Container"
        type="javax.sql.DataSource"
        username="$POSTGRES_DB_USER"
        password="$POSTGRES_DB_USER_PASSWORD"
        driverClassName="org.postgresql.Driver"
        url="jdbc:postgresql://$POSTGRES_DB_SERVER_URL/$POSTGRES_DB_NAME"
        accessToUnderlyingConnectionAllowed="true"
        initialSize="5"
        maxTotal="50"
        maxIdle="5"
        minIdle="4"
        testOnBorrow="true"
        testOnReturn="false"
        testWhileIdle="true"
        timeBetweenEvictionRunsMillis="60000"
        minEvictableIdleTimeMillis="300000"
        validationQuery="SELECT 1" />

    <Resource name="mail/Session" auth="Container"
        type="javax.mail.Session"
        mail.smtp.host="$SMTP_SERVER"
        mail.smtp.user="anonymous"
        mail.smtp.port="25"/>

    <Loader loaderClass="org.labkey.bootstrap.LabkeyServerBootstrapClassLoader" />

    <!-- Encryption key for encrypted property store -->
    <Parameter name="MasterEncryptionKey" value="$LABKEY_MEK" />


</Context>

ROOTXMLHERE
) >$TomcatROOTXMLFile
chmod 600 $TomcatROOTXMLFile
echo "Tomcat ROOT.xml file created at $TomcatROOTXMLFile"
chown -R $TOMCAT_USERNAME.$TOMCAT_USERNAME $TOMCAT_INSTALL_HOME


# TODO - Add Question to install local postgresql server
# TODO - Determine Amazon or RedHat for local postgresql install
#  cat /etc/os-release |grep "PRETTY_NAME=" | cut -c 13-

# install local postgresql
if [ "$POSTGRES_SVR_LOCAL" == "TRUE" ]; then
    sudo amazon-linux-extras enable postgresql11 epel
    #amazon-linux-extras install epel
    sudo yum clean metadata
    sudo yum install epel-release postgresql.x86_64 postgresql-server.x86_64  -y
    sudo yum install tomcat-native.x86_64 apr fontconfig -y

    if [ ! -f /var/lib/pgsql/data/PG_VERSION ]; then
        /usr/bin/postgresql-setup --initdb
    fi
    sudo systemctl enable postgresql
    sudo systemctl start postgresql
    sudo -u postgres psql -c "create user $POSTGRES_DB_USER password '$POSTGRES_DB_USER_PASSWORD';"
    sudo -u postgres psql -c "create database $POSTGRES_DB_NAME with owner $POSTGRES_DB_USER;"
    sudo -u postgres psql -c "revoke all on database $POSTGRES_DB_NAME from public;"
    sed -i 's/host    all             all             127.0.0.1\/32            ident/host    all             all             127.0.0.1\/32            md5/' /var/lib/pgsql/data/pg_hba.conf
    sudo systemctl restart postgresql
    echo "Postgres Server and Client Installed ..."
  else
    sudo amazon-linux-extras enable postgresql11 epel
    #amazon-linux-extras install epel
    sudo yum clean metadata
    sudo yum install epel-release postgresql.x86_64 -y
    sudo yum install tomcat-native.x86_64 apr fontconfig -y
fi



# create files directory and symbolic link if data volume exists
if [ -f  /media/ebs_volume/.ebs_volume ]; then
    mkdir -p /media/ebs_volume/files
    chown -R $TOMCAT_USERNAME.$TOMCAT_USERNAME /media/ebs_volume/files
    ln -s /media/ebs_volume/files "$LABKEY_INSTALL_HOME/files"
    fi

# get labkey build
cd $LABKEY_SRC_HOME || exit
if [ "$USE_LOCAL_SRC_FILES" == "TRUE" ]; then
    cp -a $LOCAL_FILE_SRC_PATH/$LABKEY_DIST_FILENAME $LABKEY_SRC_HOME
  else
wget $LABKEY_DIST_URL
fi

tar -xzf $LABKEY_DIST_FILENAME
echo "LabKey distribution $LABKEY_DIST_FILENAME downloaded and exploded at $LABKEY_SRC_HOME/$LABKEY_DIST_FILENAME "

echo "${normal}---------${bold} Finished installing prerequsites and directories ${normal}---------"
echo " ----- You are now ready to install LabKey using the manual-upgrade.sh command in the distribution tar.gz -----"
echo ""
echo ""
echo "${normal}---------${bold} Shall I proceed to install and run LabKey? Yes=1/No=2? ${normal}---------"
select yn in "Yes" "No"; do
     case $yn in
         Yes ) echo " ---${bold} Installing and running LabKey...${normal}----" ; break;;
          No ) echo " ---${bold} exiting - no action taken ${normal} ----";
               echo -e "\n To install LabKey use this command: $LABKEY_INSTALLER_CMD \n" && exit;;
        esac
done

# Enables the Tomcat Service and runs the installer if user selects yes
sudo systemctl enable tomcat_lk.service

$LABKEY_INSTALLER_CMD

echo "${normal}---------${bold} Installation Complete. LabKey is now running.  ${normal}---------"
echo "${normal}---------${bold} It may take a few minutes for the inital startup to complete.      ${normal}---------"
echo "${normal}---------${bold} Review the startup logs in $TOMCAT_INSTALL_HOME/logs/  ${normal}---------"
echo "${normal}---------${bold} You can monitor startup with the following commands:               ${normal}---------"
echo "${normal}---------${bold} sudo tail -f $TOMCAT_INSTALL_HOME/logs/catalina.out                ${normal}---------"
echo "${normal}---------${bold} sudo tail -f $TOMCAT_INSTALL_HOME/logs/labkey.log                  ${normal}---------"
echo "${normal}---------${bold} When startup is completed you may access the LabKey application on ${normal}---------"
echo "${normal}---------${bold} TCP port 8080 or 8443 e.g. https:<IP_ADDRESS>:8443                 ${normal}---------"
echo "${normal}---------${bold} Installation Finished. Goodbye.                                    ${normal}---------"
