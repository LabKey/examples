#temp containter only used for building
FROM alpine:latest AS labkey_build
LABEL maintainer="Labkey Systems Engineering <ops@labkey.com>"

# Following https://www.labkey.org/wiki/home/Documentation/page.view?name=manualInstall

# 1. Postgres supplied by container
#


ARG LABKEY_MAJOR_VERSION=20
ARG LABKEY_MINOR_VERSION=7.6
ARG LABKEY_BUILD_VERSION=65948.16-community
ARG LABKEY_BUILD_HOME=/labkey/labkey
ARG CATALINA_BUILD_HOME=/labkey/apps/tomcat
ARG DOWNLOAD_URL_START=http://labkey.s3.amazonaws.com/downloads/general/r

ARG LABKEY_FULL_VERSION=$LABKEY_MAJOR_VERSION.$LABKEY_MINOR_VERSION-$LABKEY_BUILD_VERSION
ARG DOWNLOAD_URL_VERSION=${LABKEY_MAJOR_VERSION}.${LABKEY_MINOR_VERSION}

RUN apk add --update curl && \
    mkdir -p ${LABKEY_BUILD_HOME}
WORKDIR /labkey

RUN mkdir -p ${LABKEY_BUILD_HOME}/externalModules && \
    mkdir -p ${CATALINA_BUILD_HOME}/lib

RUN curl -LO ${DOWNLOAD_URL_START}/${DOWNLOAD_URL_VERSION}/LabKey${LABKEY_FULL_VERSION}-bin.tar.gz && \
    tar xzf LabKey${LABKEY_FULL_VERSION}-bin.tar.gz

RUN cp -R LabKey${LABKEY_FULL_VERSION}-bin/labkeywebapp ${LABKEY_BUILD_HOME} && \
    cp -R LabKey${LABKEY_FULL_VERSION}-bin/modules ${LABKEY_BUILD_HOME} && \
    cp -R LabKey${LABKEY_FULL_VERSION}-bin/pipeline-lib ${LABKEY_BUILD_HOME} && \
    cp LabKey${LABKEY_FULL_VERSION}-bin/tomcat-lib/* ${CATALINA_BUILD_HOME}/lib/

COPY bin ${LABKEY_BUILD_HOME}/bin
RUN chmod +x ${LABKEY_BUILD_HOME}/bin/*

##
# Build complete.
# Now compile release on final containter
##
#
FROM tomcat:9-jdk15-openjdk-slim-buster
LABEL maintainer="Labkey Systems Engineering <ops@labkey.com>"

ARG LABKEY_BUILD_HOME=/labkey/labkey
ARG CATALINA_BUILD_HOME=/labkey/apps/tomcat
ARG CONTEXT_PATH=ROOT

# To change the path that labey is available at change the ENV variable LABKEY_URL_PATH (use # to denote slash)
ENV LABKEY_HOME=/usr/local/labkey \
    LABKEY_SERVER_HOSTNAME=local_test_server \
    LABKEY_URL_PATH=labkey \
    CATALINA_OPTS="-Xms128m -Xmx4096m -XX:-HeapDumpOnOutOfMemoryError" \
    DATABASE_HOST=postgres \
    DATABASE_PORT=5432

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y postgresql-client-11 xvfb r-base r-base-dev graphviz && \
    rm -rf ${CATALINA_HOME}/webapps

COPY --from=labkey_build ${LABKEY_BUILD_HOME} ${LABKEY_HOME}
COPY --from=labkey_build ${CATALINA_BUILD_HOME}/lib ${CATALINA_HOME}/lib

COPY config/labkey.xml ${CATALINA_HOME}/conf/Catalina/localhost/${CONTEXT_PATH}.xml

ENV PATH=$PATH:$LABKEY_HOME/bin

WORKDIR ${LABKEY_HOME}

VOLUME ${CATALINA_HOME}/logs

ENTRYPOINT ["wait-for-system.sh"]
CMD ["start-labkey.sh"]
