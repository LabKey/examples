# DOCKER-VERSION 1.0.0
#
# Dockerfile for Standalone LabKey Server. 
# Database and LabKey files are a stored inside the container. This is meant for demo only. 
# Developer version of this will use host or container based volumes for Database and 
# LabKey Server file roots.

# Use Ubuntu 14.04 as our base 
from ubuntu:14.04
maintainer bconn@labkey.com

#
# Install the required packages 
#
# We will use Package Manager to install all the PostgreSQL and other required tools
# 
# Apt configuration: Add the PostgreSQL PGP key to verify their Debian packages.
# It should be the same key as https://www.postgresql.org/media/keys/ACCC4CF8.asc
run apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8

# Add PostgreSQL's repository. It contains the most recent stable release
# of PostgreSQL, ``9.3``.
run echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Update the Ubuntu and PostgreSQL repository indexes
run apt-get update

# Install latest patches 
# run DEBIAN_FRONTEND=noninteractive; apt-get -y -q upgrade 

# Install and configure PostgreSQL server 
run (DEBIAN_FRONTEND=noninteractive apt-get -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 graphviz; \
     apt-get clean -y )


# Install other required software and OS utilities
# Use this command if you are installing R
#run DEBIAN_FRONTEND=noninteractive; apt-get -y -q install zip unzip graphviz r-base r-recommended r-base-dev curl libcurl4-openssl-dev libgd2-xpm-dev libxt-dev wget netcat xvfb inetutils-ping inetutils-traceroute xvfb

#
# Create directories required for running LabKey Server
# 
run mkdir -p /labkey/labkey
run mkdir -p /labkey/src/labkey
run mkdir -p /labkey/bin
run mkdir -p /labkey/apps

#
# Install Oracle Java 
# 
add ./labkey/src/server-jre-7u60-linux-x64.tar.gz /labkey/apps/
# run tar xzf /labkey/src/server-jre-7u60-linux-x64.tar.gz
# run mv ./jdk1.7.0_60 /labkey/apps
run ls -la /labkey/apps/


# 
# Install Tomcat 
# 
# Installing this software from source instead of using the APT package 
# as we want to use the latest version and old-ish version in the APT 
# repository

# Create the Tomcat 7 user account 
run useradd -m -u 3000 tomcat7

# Install Tomcat binaries
add ./tomcat/apache-tomcat-7.0.54.tar.gz /labkey/apps
#run tar xzf /labkey/src/apache-tomcat-7.0.54.tar.gz
#run mv ./apache-tomcat-7.0.54 /labkey/apps/
run (ln -s /labkey/apps/apache-tomcat-7.0.54 /labkey/apps/tomcat; \
     mkdir -p /labkey/apps/tomcat/conf/Catalina/localhost; \
    chown -R tomcat7.tomcat7 /labkey/apps/apache-tomcat-7.0.54 )

# Install configuration files
add ./tomcat/server.xml /labkey/apps/tomcat/conf/server.xml 
add ./tomcat/init_tomcat7 /labkey/bin/tomcat7.sh


# 
# Configure the PostgreSQL Server 
# 
add ./postgresql/postgresql.conf /etc/postgresql/9.3/main/postgresql.conf

# Recreate the database server to ensure the default encoding is UTF8
run (rm -rf /var/lib/postgresql/9.3/main; \
     mkdir /var/lib/postgresql/9.3/main; \
     chown postgres.postgres /var/lib/postgresql/9.3/main)

USER postgres
run /usr/lib/postgresql/9.3/bin/initdb --locale=C.UTF-8 -D /var/lib/postgresql/9.3/main

# Create labkey user in postgresql database 
USER postgres
run /etc/init.d/postgresql start &&\
    psql --command "CREATE USER labkey WITH SUPERUSER PASSWORD 'LabKeyOnDockerIsgreaT%04';"

USER root


#
# Install the LabKey Server 
# 

# Copy files to the container 
copy ./labkey/src/LabKey14.1-31615-bin.tar.gz /labkey/src/LabKey14.1-31615-bin.tar.gz
add ./labkey/labkey.xml /labkey/apps/tomcat/conf/Catalina/localhost/ROOT.xml
add ./labkey/start_labkey.sh /labkey/bin/start_labkey.sh
add ./labkey/init_xvfb /labkey/bin/xvfb.sh
run chmod +x /labkey/bin/*

# Install the LabKey Server 
run (tar xzf /labkey/src/LabKey14.1-31615-bin.tar.gz; \
     cp -R LabKey14.1-31615-bin/bin /labkey/labkey; \
     cp -R LabKey14.1-31615-bin/modules /labkey/labkey; \
     cp -R LabKey14.1-31615-bin/labkeywebapp /labkey/labkey; \
     cp -R LabKey14.1-31615-bin/pipeline-lib /labkey/labkey; \
     cp -f LabKey14.1-31615-bin/tomcat-lib/*.jar /labkey/apps/tomcat/lib/; \
     chown -R tomcat7.tomcat7 /labkey/labkey; \
     rm -rf LabKey14.1-31615-bin)

# Clean-up 
#run rm /labkey/src/server-jre-7u60-linux-x64.tar.gz
#run rm /labkey/src/apache-tomcat-7.0.54.tar.gz
#run rm /labkey/src/LabKey14.1-31615-bin.tar.gz
#run rm -rf LabKey14.1-31615-bin


# Expose LabKey Server web application 
expose 8080

# 
# Start Tomcat and PostgreSQL Daemons when container is started.
# 
workdir /labkey/
cmd /labkey/bin/start_labkey.sh 







