#!/bin/bash
#
# ****************************************************************************
# *** IMPORTANT: THIS SCRIPT SHOULD ONLY BE USED IF YOU ARE UPGRADING
# ***            USING AN OLD VERSION OF LABKEY SERVER. USE THIS SCRIPT
# ***            IF YOU ARE UPGRADING TO LABKEY SERVER v13.2 OR EARLIER.
# ***
# ***            IF YOU ARE UPGRADING TO A LATER VERSION OF LABKEY SERVER
# ***            (V13.3 OR LATER) THEN USE THE UPDATED SCRIPT FOUND AT
# ***            https://github.com/bdconnolly/labkey-ops
# ***
# ***            NOTE: LABKEY SERVER v13.3 WAS RELEASED IN NOV. 2013
# ****************************************************************************
#
# Upgrade script for a LabKey Remote Pipeline Server 
# This script can be used to upgrade a LabKey Remote Pipeline Server installed 
# on Linux, Solaris or MacOSX server.
# 
# The LabKey Remote Pipeline Server is a part of the LabKey Server 
# Enterprise Pipeline. See https://www.labkey.org/wiki/home/Documentation/page.view?name=InstallEnterprisePipeline
# for more information 
# 
# If you need support, please post a message to the LabKey Support boards at 
# https://www.labkey.org/project/home/Server/Forum/begin.view?
# 
# The upgrade script will do the following:
#  1) Verify the LabKey Distribution is ready to be installed
#  2) Uninstall the previous version of LabKey 
#  3) Install the new version of LabKey Server 
#
# This script requires the unzipped distribution directory name to be entered on the command line. 
# For example upgrade-remote-pipeline.sh LabKey12.1-20297-enterprise-bin

# Variables 
LABKEY_HOME='/labkey/labkey'
LABKEY_DISTDIR='/labkey/src/labkey'
DATE=$(date +20%y%m%d%H%M)
lkUser='labkey'
lkGroup='labkey'


# Test if command-line arg present
if [ -n "$1" ]; then
  dist=$LABKEY_DISTDIR/$1
else  
  echo "You must specify the name of the LabKey distribution."
  echo "For example, upgrade-remote-pipeline.sh LabKey12.1-20297-bin"
  exit 1
fi

if [ -d $dist ]; then
  # directory exists
  test=1
else
  echo "The distribution directory, $dist , does not exist" 
  exit 1
fi


echo ' '
echo ' '
echo '-------------  Start the Upgrade at ' `date` 
echo ' '

# Remove all the LabKey files from previous version. 
echo 'Begin the Installation Process: '
echo '   --- Remove all files from previous version '
rm -rf $LABKEY_HOME/modules
rm -rf $LABKEY_HOME/labkeywebapp
rm -rf $LABKEY_HOME/pipeline-lib
rm -rf $LABKEY_HOME/labkeyBootstrap.jar

echo ' ' 
echo '   -- Install the new bits ' 
cd $dist

cp -R modules $LABKEY_HOME
cp -R labkeywebapp $LABKEY_HOME
cp -R pipeline-lib $LABKEY_HOME
cp -f server-lib/labkeyBootstrap.jar $LABKEY_HOME/labkeyBootstrap.jar


echo ' ' 
echo '   --- Change Permission of the newly installed files ' 
chown -R $lkUser:$lkGroup $LABKEY_HOME


echo ' '
echo '----------------  The installation is complete at ' `date`  
echo ' '
