@REM  Upgrade script for a LabKey Remote Pipeline Server
@REM
@REM ****************************************************************************
@REM *** IMPORTANT: THIS SCRIPT SHOULD ONLY BE USED IF YOU ARE UPGRADING
@REM ***            USING AN OLD VERSION OF LABKEY SERVER. USE THIS SCRIPT
@REM ***            IF YOU ARE UPGRADING TO LABKEY SERVER v13.2 OR EARLIER.
@REM ***
@REM ***            IF YOU ARE UPGRADING TO A LATER VERSION OF LABKEY SERVER
@REM ***            (V13.3 OR LATER) THEN USE THE UPDATED SCRIPT FOUND AT
@REM ***            https://github.com/bdconnolly/labkey-ops
@REM ***
@REM ***            NOTE: LABKEY SERVER v13.3 WAS RELEASED IN NOV. 2013
@REM ****************************************************************************
@REM
@REM  This script can be used to upgrade a LabKey Remote Pipeline Server installed on Windows.
@REM
@REM  The LabKey Remote Pipeline Server is a part of the LabKey Server Enterprise Pipeline
@REM  See https://www.labkey.org/wiki/home/Documentation/page.view?name=InstallEnterprisePipeline
@REM  for more information.
@REM
@REM  If you need support, please post a message to the LabKey Support boards at 
@REM  https://www.labkey.org/project/home/Server/Forum/begin.view?
@REM
@REM  The upgrade script will do the following:
@REM  1) Verify the LabKey Distribution is ready to be installed
@REM  2) Uninstall the previous version of LabKey 
@REM  3) Install the new version of LabKey Server 
@REM
@REM This script requires the unzipped distribution directory name to be entered on the command line. 
@REM For example upgrade-remote-pipeline.bat LabKey12.1-20297-enterprise-bin

@REM Variables 
@set labkey_distdir=c:\labkey\src
@set labkey_home=c:\labkey\labkey

@ REM Tests 
@if "%1" == "" goto nodir
@if not exist %labkey_distdir%\%1 goto dirnotvalid


@echo.
@echo.
@echo ============== Shut down the Labkey Remote Pipeline Server  

NET STOP LabKeyRemoteServer


@REM Clean up previous installation 
@echo.
@echo.
@echo ============== Remove files from previous installation
@echo.
rmdir /Q /S %labkey_home%\labkeywebapp 
rmdir /Q /S %labkey_home%\modules
rmdir /Q /S %labkey_home%\pipeline-lib
del /F /Q %labkey_home%\labkeyBootstrap.jar

@REM Install new bits
@echo.
@echo.
@echo ============== Install the files from the new distribution directory
@echo.
@mkdir %labkey_home%\labkeywebapp
@mkdir %labkey_home%\modules
@mkdir %labkey_home%\pipeline-lib
xcopy /y /Q /E /H %labkey_distdir%\%1\labkeywebapp %labkey_home%\labkeywebapp
xcopy /y /Q /E /H %labkey_distdir%\%1\modules %labkey_home%\modules
xcopy /y /Q /E /H %labkey_distdir%\%1\pipeline-lib %labkey_home%\pipeline-lib
copy /y %labkey_distdir%\%1\bin\*.* "%labkey_home%\bin"
copy /y %labkey_distdir%\%1\server-lib\labkeyBootstrap.jar "%labkey_home%"

cp -f server-lib/labkeyBootstrap.jar $LABKEY_HOME/labkeyBootstrap.jar


@echo.
@echo.
@echo ============== Start the LabKey Remote Pipeline Server

NET START LabKeyRemoteServer 

@goto end

:nodir
@echo You must enter the unzipped directory name. 
@echo For example: %0 LabKey12.1-20297-bin
goto end

:dirnotvalid
@echo The distribution directory, %labkey_distdir%\%1, does not exist
@goto end


:end
