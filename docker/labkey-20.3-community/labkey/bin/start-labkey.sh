#!/bin/bash
ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_PASS=${ADMIN_PASS:-tomcat}
MAX_UPLOAD_SIZE=${MAX_UPLOAD_SIZE:-52428800}

export CATALINA_OPTS=${CATALINA_OPTS:-"-Xms128m -Xmx1024m -XX:PermSize=128m -XX:MaxPermSize=256m -Djava.security.egd=file:/dev/./urandom"}

export JAVA_OPTS="${JAVA_OPTS} \
-Dlabkey.home=${LABKEY_HOME} \
-Ddatabase.host=${DATABASE_HOST} \
-Ddatabase.port=${DATABASE_PORT} \
-Dlabkey.server.hostname=${LABKEY_SERVER_HOSTNAME}"
#-Ddevmode=true"

# Copy in admin user for the tomcat admin
cat << EOF > ${CATALINA_HOME}/conf/tomcat-users.xml
<?xml version='1.0' encoding='utf-8'?>
<tomcat-users>
<user username="${ADMIN_USER}" password="${ADMIN_PASS}" roles="admin-gui,manager-gui"/>
</tomcat-users>
EOF

# Copy in the max upload size
if [ -f "${CATALINA_HOME}/webapps/manager/WEB-INF/web.xml" ]
then
	sed -i "s#.*max-file-size.*#\t<max-file-size>${MAX_UPLOAD_SIZE}</max-file-size>#g" ${CATALINA_HOME}/webapps/manager/WEB-INF/web.xml
	sed -i "s#.*max-request-size.*#\t<max-request-size>${MAX_UPLOAD_SIZE}</max-request-size>#g" ${CATALINA_HOME}/webapps/manager/WEB-INF/web.xml
fi

# Make sure the labkey.xml file is in the correct path location
>&2 echo "Labkey available at path ${LABKEY_URL_PATH}"
mv ${CATALINA_HOME}/conf/Catalina/localhost/labkey.xml ${CATALINA_HOME}/conf/Catalina/localhost/${LABKEY_URL_PATH}.xml

## Start X Virtual Frame Buffer for R
>&2 echo "Starting xvfb..."
xvfb.sh start

# Start Tomcat
>&2 echo "Starting Labkey"
catalina.sh run

