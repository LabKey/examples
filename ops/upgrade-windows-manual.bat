@REM Upgrade Script for LabKey Server.
@REM This script can be used when upgrading a manually installed LabKey Server, on Windows.
@REM This script should never be used to upgrade a LabKey Server that was installed 
@REM   using the LabKey Installer
@REM
@REM See https://www.labkey.org/announcements/home/Server/Administration/thread.view?rowId=4842
@REM   for instructions on using this script.
@REM
@REM See https://www.labkey.org/wiki/home/Documentation/page.view?name=manualInstall for
@REM   more information on manually installing LabKey Server.
@REM
@REM This script requires the unzipped distribution directory name to be entered on
@REM   the command line. For example:
@REM
@REM   upgrade-windows-manual.bat LabKey13.3-r28123-bin


@REM Variables
@REM -------------------------------------------------------
@REM Change these variables for your server
@REM
@REM labkey_distdir is the directory which contains the LabKey distribution 
@REM labkey_home is the directory which will contain the the labkeywebapp
@REM   modules directories
@REM catalina_home is the installation directory for the Tomcat Server
@REM service_name is the name of the Windows service for Tomcat Server
@REM
@set labkey_distdir=c:\labkey\src\labkey
@set labkey_home=c:\labkey\labkey
@set catalina_home=c:\labkey\apps\tomcat
@set service_name=Tomcat7


@REM Tests
@REM -------------------------------------------------------
@echo.
@echo.
@echo ============== Verify everything is ready to go
@REM Check command line options
@if "%1" == "" goto commandlinewrong
@REM Check if Windows service exists 
@sc query state= all | find /I "%service_name%" > nul
@if ERRORLEVEL 1 GOTO servicemissing
@REM Check if the directories exist
@if not exist "%labkey_distdir%\%1" @set cdir=%labkey_distdir%\%1 && goto dirnotvalid
@if not exist "%catalina_home%" @set cdir=%catalina_home% && goto dirnotvalid
@if not exist "%labkey_home%" @set cdir=%labkey_home% && goto dirnotvalid
@echo. All checks succeeded. Starting the installation


@REM Shutdown the Tomcat Server
@REM -------------------------------------------------------
@echo.
@echo.
@echo ============== Shut down the Tomcat Server 

net stop "%service_name%"


@REM Clean up previous installation
@REM -------------------------------------------------------
@echo.
@echo.
@echo ============== Remove files from previous installation
@echo.
rmdir /Q /S %labkey_home%\labkeywebapp 
rmdir /Q /S %labkey_home%\modules
rmdir /Q /S %labkey_home%\pipeline-lib


@REM Install new bits
@REM -------------------------------------------------------
@echo.
@echo.
@echo ============== Install the files from the new distribution directory
@echo.
mkdir %labkey_home%\labkeywebapp
mkdir %labkey_home%\modules
mkdir %labkey_home%\pipeline-lib
xcopy /y /Q /E /H %labkey_distdir%\%1\labkeywebapp %labkey_home%\labkeywebapp
xcopy /y /Q /E /H %labkey_distdir%\%1\modules %labkey_home%\modules
xcopy /y /Q /E /H %labkey_distdir%\%1\pipeline-lib %labkey_home%\pipeline-lib
copy /y %labkey_distdir%\%1\bin\*.* "%labkey_home%\bin"
copy /y %labkey_distdir%\%1\tomcat-lib\*.jar "%catalina_home%\lib"


@REM Start the Tomcat Server
@REM -------------------------------------------------------
@echo.
@echo.
@echo ============== Start the Tomcat Server 

net start "%service_name%"


@REM Installation is complete
@REM -------------------------------------------------------
@echo.
@echo.
@echo ============== Upgrade script has completed
@echo.
@echo The upgrade has completed successfully
@echo.
@echo If the LabKey server does not start properly:
@echo 1. Review the output above for any errors
@echo 2. See the log files at:
@echo       - Tomcat startup log: %catalina_home%\logs\catalina.out
@echo       - LabKey specific log: %catalina_home%\logs\labkey.log
@echo.


@goto end


:commandlinewrong
@echo.
@echo ERROR:
@echo You must enter the unzipped directory name. 
@echo For example: %0 LabKey13.3-r28123-bin
@goto end

:servicemissing
@echo.
@echo ERROR:
@echo The service named, %service_name%, does not exist.
@goto end

:dirnotvalid
@echo.
@echo ERROR:
@echo %cdir% is not a valid directory 
@goto end


:end

