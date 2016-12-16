#!/bin/sh
#
# Written by Miquel van Smoorenburg <miquels@cistron.nl>.
# Modified for Debian GNU/Linux by Ian Murdock <imurdock@gnu.ai.mit.edu>.
# Modified for Tomcat by Stefan Gybas <sgybas@debian.org>.
# Modified for Tomcat6 by Thierry Carrez <thierry.carrez@ubuntu.com>.
# Modified for Tomcat7 by Ernesto Hernandez-Novich <emhn@itverx.com.ve>.
# Additional improvements by Jason Brittain <jason.brittain@mulesoft.com>.
#
# Modified by Brian Connolly at LabKey for use with LabKey Servers running in
# docker containers
#

set -e

#
# Set variables
#
PATH=/bin:/usr/bin:/sbin:/usr/sbin
NAME=tomcat
DESC="Tomcat servlet engine"
CATALINA_HOME=/labkey/apps/tomcat
CATALINA_BASE=$CATALINA_HOME
JAVA_OPTS="-Djava.awt.headless=true -Duser.timezone=America/Los_Angeles -Xms256M -Xmx2048M -Djava.net.preferIPv4Stack=true"
JVM_TMP=$CATALINA_HOME/temp
JAVA_HOME=/labkey/apps/java

# Run Tomcat as this user ID and group ID
TOMCAT_USER=tomcat
TOMCAT_GROUP=tomcat

# Use the Java security manager? (yes/no)
TOMCAT_SECURITY=no

export JAVA_HOME

if [ `id -u` -ne 0 ]; then
    echo "You need root privileges to run this script"
    exit 1
fi



. /lib/lsb/init-functions


# Default Java options
# Set java.awt.headless=true if JAVA_OPTS is not set so the
# Xalan XSL transformer can work without X11 display on JDK 1.4+
# It also looks like the default heap size of 64M is not enough for most cases
# so the maximum heap size is set to 128M
if [ -z "$JAVA_OPTS" ]; then
    JAVA_OPTS="-Djava.awt.headless=true -Xmx128M"
fi

if [ ! -f "$CATALINA_HOME/bin/bootstrap.jar" ]; then
    log_failure_msg "$NAME is not installed"
    exit 1
fi

if [ -z "$CATALINA_TMPDIR" ]; then
    CATALINA_TMPDIR="$JVM_TMP"
fi

SECURITY=""
if [ "$TOMCAT_SECURITY" = "yes" ]; then
    SECURITY="-security"
fi

# Define other required variables
CATALINA_PID="/var/run/$NAME.pid"
CATALINA_SH="$CATALINA_HOME/bin/catalina.sh"

# Look for Java Secure Sockets Extension (JSSE) JARs
if [ -z "${JSSE_HOME}" -a -r "${JAVA_HOME}/jre/lib/jsse.jar" ]; then
    JSSE_HOME="${JAVA_HOME}/jre/"
fi

catalina_sh() {
    # Escape any double quotes in the value of JAVA_OPTS
    JAVA_OPTS="$(echo $JAVA_OPTS | sed 's/\"/\\\"/g')"

    AUTHBIND_COMMAND=""
    if [ "$AUTHBIND" = "yes" -a "$1" = "start" ]; then
        AUTHBIND_COMMAND="/usr/bin/authbind --deep /bin/bash -c "
    fi

    # Define the command to run Tomcat's catalina.sh as a daemon
    # set -a tells sh to export assigned variables to spawned shells.
    TOMCAT_SH="set -a; JAVA_HOME=\"$JAVA_HOME\"; source \"$DEFAULT\"; \
        CATALINA_HOME=\"$CATALINA_HOME\"; \
        CATALINA_BASE=\"$CATALINA_BASE\"; \
        JAVA_OPTS=\"$JAVA_OPTS\"; \
        CATALINA_PID=\"$CATALINA_PID\"; \
        CATALINA_TMPDIR=\"$CATALINA_TMPDIR\"; \
        LANG=\"$LANG\"; JSSE_HOME=\"$JSSE_HOME\"; \
        cd \"$CATALINA_BASE\"; \
        \"$CATALINA_SH\" $@"

    if [ "$AUTHBIND" = "yes" -a "$1" = "start" ]; then
        TOMCAT_SH="'$TOMCAT_SH'"
    fi

    # Run the catalina.sh script as a daemon
    set +e
    touch "$CATALINA_PID" "$CATALINA_BASE"/logs/catalina.out
    chown $TOMCAT_USER "$CATALINA_PID" "$CATALINA_BASE"/logs/catalina.out
    start-stop-daemon --start -b -u "$TOMCAT_USER" -g "$TOMCAT_GROUP" \
        -c "$TOMCAT_USER" -d "$CATALINA_TMPDIR" -p "$CATALINA_PID" \
        -x /bin/bash -- -c "$AUTHBIND_COMMAND $TOMCAT_SH"
    status="$?"
    set +a -e
    return $status
}

case "$1" in
  start)
    if [ -z "$JAVA_HOME" ]; then
        log_failure_msg "no JDK or JRE found - please set JAVA_HOME"
        exit 1
    fi

    if [ ! -d "$CATALINA_BASE/conf" ]; then
        log_failure_msg "invalid CATALINA_BASE: $CATALINA_BASE"
        exit 1
    fi

    log_daemon_msg "Starting $DESC" "$NAME"
    if start-stop-daemon --test --start --pidfile "$CATALINA_PID" \
        --user $TOMCAT_USER --exec "$JAVA_HOME/bin/java" \
        >/dev/null; then

        catalina_sh start $SECURITY
        if [ $? -eq 0 ]; then
            log_end_msg 0
        else
            log_end_msg 1
            if [ -f "$CATALINA_PID" ]; then
                rm -f "$CATALINA_PID"
            fi
        fi
        sleep 5
    else
        log_progress_msg "(already running)"
        log_end_msg 0
    fi
    ;;
  stop)
    log_daemon_msg "Stopping $DESC" "$NAME"

    set +e
    if [ -f "$CATALINA_PID" ]; then
        start-stop-daemon --stop --pidfile "$CATALINA_PID" \
            --user "$TOMCAT_USER" \
            --retry=TERM/20/KILL/5 >/dev/null
        if [ $? -eq 1 ]; then
            log_progress_msg "$DESC is not running but pid file exists, cleaning up"
        elif [ $? -eq 3 ]; then
            PID="`cat $CATALINA_PID`"
            log_failure_msg "Failed to stop $NAME (pid $PID)"
            exit 1
        fi
        rm -f "$CATALINA_PID"
    else
        log_progress_msg "(not running)"
    fi
    log_end_msg 0
    set -e
    ;;
   status)
    set +e
    start-stop-daemon --test --start --pidfile "$CATALINA_PID" \
        --user $TOMCAT_USER --exec "$JAVA_HOME/bin/java" \
        >/dev/null 2>&1
    if [ "$?" = "0" ]; then

        if [ -f "$CATALINA_PID" ]; then
            log_success_msg "$DESC is not running, but pid file exists."
            exit 1
        else
            log_success_msg "$DESC is not running."
            exit 3
        fi
    else
        log_success_msg "$DESC is running with pid `cat $CATALINA_PID`"
    fi
    set -e
        ;;
  restart|force-reload)
    if [ -f "$CATALINA_PID" ]; then
        $0 stop
        sleep 1
    fi
    $0 start
    ;;
  try-restart)
        if start-stop-daemon --test --start --pidfile "$CATALINA_PID" \
        --user $TOMCAT_USER --exec "$JAVA_HOME/bin/java" \
        >/dev/null; then
        $0 start
    fi
        ;;
  *)
    log_success_msg "Usage: $0 {start|stop|restart|try-restart|force-reload|status}"
    exit 1
    ;;
esac

exit 0