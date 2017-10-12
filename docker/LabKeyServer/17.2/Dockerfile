#
# Dockerfile for running LabKey Server in a single container
#
# Software
# ============
# Software versions are specified as ENV variables. This allows
# for a different version to be specified at build time for the image.
#
#   * Base: Ubuntu Core 16.04
#   * PostgreSQL: 9.5.5
#   * Tomcat: 8.0.38
#   * Java: 1.8u112
#   * LabKey Server: Labkey17.2-52553-community-bin
#
#
# Storage:
# =============
# The following directories will be mounted at Data Volumes
#   * PostgreSQL Database Directory
#   * Tomcat logs Directory
#   * LabKey Server Sitewide FileRoot Directory
#
# This allows for each backup and review of log files.
#
# Secrets
# ============
# IMPORTANT: This Dockerfile will read the required secrets (ie passwords, etc)
# from ENV variables. There are other methods for managing secrets; feel free to
# modify this Dockerfile or ENTRYPOINT script (start_labkey.sh) to use a
# different method.
#
# The ENTRYPOINT script (/labkey/bin/start_labkey.sh) reads
#   * PostgreSQL user account password from PG_PASSWORD ENV variable
#   * Master Encryption Key from LABKEY_ENCRYPTION_KEY ENV variable
#
# You can specify values for these variables in the Dockerfile, as an ENV variable
# during the build time or run time. We recommend specifying them as part of the run
# command.

FROM ubuntu:16.04
MAINTAINER bconn@labkey.com

ENV JAVA_VERSION=8 \
    JAVA_UPDATE=112 \
    LABKEY_VERSION=17.2 \
    LABKEY_DIST=17.2-52553-community \
    PG_MAJOR=9.5 \
    PG_VERSION=9.5.4 \
    PG_HOST=localhost \
    TOMCAT_VERSION=8.0.38 \
    LD_LIBRARY_PATH=/labkey/apps/postgresql/lib \
    LABKEY_ENCRYPTION_KEY=sh8ZLBcpKAD82MtjDwhuq2BoF3m5qkctawNuWcq2qQwsRU6Vgi7O1j981JYQhRb \
    PG_PASSWORD=tokenPassword


#
# Install PostgreSQL and configure
#

# For development split out apt-get calls
#RUN apt-get update && \
#    apt-get -y -q install build-essential ssl-cert libreadline-dev zlib1g-dev wget graphviz r-base r-recommended xvfb && \


RUN apt-get update && \
    apt-get -y -q install build-essential ssl-cert libreadline-dev zlib1g-dev wget graphviz r-base r-recommended xvfb curl && \
    mkdir -p /labkey/apps/postgresql && \
    mkdir -p /labkey/src/labkey && \
    mkdir -p /labkey/bin && \
    cd /labkey/src && \
    wget --no-verbose http://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.gz && \
    tar xzf postgresql-$PG_VERSION.tar.gz && \
    cd /labkey/src/postgresql-$PG_VERSION && \
    ./configure --prefix=/labkey/apps/postgresql && \
    make && \
    make install && \
    rm -rf /labkey/src/postgresql-$PG_VERSION && \
    rm /labkey/src/postgresql-$PG_VERSION.tar.gz && \
    apt-get -y -q purge build-essential && \
    apt-get -y -q autoremove && \
    apt-get clean -y


# Create PostgreSQL and Tomcat user account and set directory permissions
RUN useradd -m -u 2900 postgres && \
    useradd -m -u 3000 tomcat && \
    mkdir /labkey/apps/postgresql/data && \
    chown postgres.postgres /labkey/apps/postgresql/data


# Initialize PostgreSQL database, start PostgreSQL server and create user account to be used by LabKey Server
USER postgres
RUN /labkey/apps/postgresql/bin/initdb --locale=C.UTF-8 -D /labkey/apps/postgresql/data && \
    mkdir /labkey/apps/postgresql/data/pg_log && \
    mkdir /labkey/apps/postgresql/data/backup


# Add configuration file to PGDATA directory and restart the PostgreSQL server
ADD ./postgresql/postgresql.conf /labkey/apps/postgresql/data/postgresql.conf
ADD ./postgresql/pg_hba.conf /labkey/apps/postgresql/data/pg_hba.conf
USER root


#
# Install Tomcat and configure
#
RUN cd /labkey/src && \
    wget --no-verbose http://archive.apache.org/dist/tomcat/tomcat-8/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz && \
    tar xzf apache-tomcat-$TOMCAT_VERSION.tar.gz && \
    mv apache-tomcat-$TOMCAT_VERSION /labkey/apps/tomcat && \
    mkdir -p /labkey/apps/tomcat/conf/Catalina/localhost && \
    mkdir -p /labkey/apps/tomcat/temp && \
    chown -R tomcat.tomcat /labkey/apps/tomcat && \
    rm /labkey/src/apache-tomcat-$TOMCAT_VERSION.tar.gz && \
    wget --no-verbose http://www.labkey.org/download/g/server-jre-"$JAVA_VERSION"u$JAVA_UPDATE-linux-x64.tar.gz && \
    tar xzf server-jre-"$JAVA_VERSION"u$JAVA_UPDATE-linux-x64.tar.gz && \
    mv jdk1.$JAVA_VERSION.0_$JAVA_UPDATE /labkey/apps/java && \
    rm server-jre-"$JAVA_VERSION"u$JAVA_UPDATE-linux-x64.tar.gz


# Add configuration files and scripts
ADD ./tomcat/server.xml /labkey/apps/tomcat/conf/server.xml
ADD ./labkey/labkey.xml /labkey/apps/tomcat/conf/Catalina/localhost/ROOT.xml
ADD ["./labkey/start_labkey.sh","./tomcat/start_tomcat.sh","./labkey/check_labkey.sh", "/labkey/bin/"]

#
# Install the LabKey Server and Configure
#

RUN chmod +x /labkey/bin/* && \
    mkdir -p /labkey/labkey && \
    cd /labkey/src && \
    wget --no-verbose http://labkey.s3.amazonaws.com/downloads/general/r/$LABKEY_VERSION/Labkey$LABKEY_DIST-bin.tar.gz && \
    tar xzf /labkey/src/Labkey$LABKEY_DIST-bin.tar.gz && \
    cp -R Labkey$LABKEY_DIST-bin/modules /labkey/labkey && \
    cp -R Labkey$LABKEY_DIST-bin/labkeywebapp /labkey/labkey && \
    cp -R Labkey$LABKEY_DIST-bin/pipeline-lib /labkey/labkey && \
    cp -f Labkey$LABKEY_DIST-bin/tomcat-lib/*.jar /labkey/apps/tomcat/lib/ && \
    mkdir /labkey/labkey/files && \
    chown -R tomcat.tomcat /labkey/labkey && \
    rm -rf Labley$LABKEY_DIST-bin && \
    rm Labkey$LABKEY_DIST-bin.tar.gz


# Expose LabKey Server web application
EXPOSE 8080

# Add VOLUMEs to allow backup of Tomcat logs, database and Sitewide FileRoot
VOLUME  ["/labkey/apps/postgresql/data", "/labkey/labkey/files", "/labkey/apps/tomcat/logs"]

#
# Start Tomcat and PostgreSQL Daemons when container is started.
#
WORKDIR /labkey/

# Configure healthcheck for container
HEALTHCHECK --interval=60s --timeout=10s --retries=5 \
    CMD curl -fsS http://localhost:8080/ > /dev/null || exit 1

ENTRYPOINT ["/labkey/bin/start_labkey.sh"]
CMD ["/labkey/bin/check_labkey.sh"]
