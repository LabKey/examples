@REM Upgrade Script for LabKey Server.
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
@REM This script can be used when upgrading a manually installed LabKey Server, on Windows 
@REM This script should never be used to upgrade a LabKey Server that was installed using the LabKey Installer
@REM
@REM See https://www.labkey.org/announcements/home/Server/Administration/thread.view?rowId=4842 for instructions 
@REM   on using this script. 
@REM
@REM See https://www.labkey.org/wiki/home/Documentation/page.view?name=manualInstall for more information 
@REM   manually installing LabKey Server.
@REM 
@REM This script requires the unzipped distribution directory name to be entered on the command line. For example 
@REM   upgrade-windows-manual.bat LabKey11.1-r16000-enterprise-bin

@REM Variables 
@set labkey_distdir=h:\Labkey\dist
@set labkey_home=h:\LabKey
@set catalina_home=h:\tomcat

@ REM Tests 
@if "%1" == "" goto nodir
@if not exist %labkey_distdir%\%1 goto dirnotvalid


@echo.
@echo.
@echo ============== Shut down the Tomcat Server 

NET STOP "Apache Tomcat"


@REM Clean up previous installation 
@echo.
@echo.
@echo ============== Remove files from previous installation
@echo.
rmdir /Q /S %labkey_home%\labkeywebapp 
rmdir /Q /S %labkey_home%\modules
rmdir /Q /S %labkey_home%\pipeline-lib


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
copy /y %labkey_distdir%\%1\server-lib\*.jar "%catalina_home%\server\lib"
copy /y %labkey_distdir%\%1\common-lib\*.jar "%catalina_home%\common\lib"


@echo.
@echo.
@echo ============== Start the LabKey Remote Pipeline Server

NET START "Apache Tomcat" 

@goto end

:nodir
@echo You must enter the unzipped directory name. 
@echo For example: %0 LabKey12.1-20297-bin
@goto end

:dirnotvalid
@echo %labkey_distdir%\%1 is not a valid direcotry 
@goto end


:end
