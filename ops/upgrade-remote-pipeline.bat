@REM Upgrade script for a LabKey Remote Pipeline Server 
@REM This script can be used to upgrade a LabKey Remote Pipeline Server installed on Windows.
@REM
@REM The LabKey Remote Pipeline Server is a part of the LabKey Server Enterprise Pipeline
@REM See https://www.labkey.org/wiki/home/Documentation/page.view?name=InstallEnterprisePipeline
@REM for more information.
@REM
@REM If you need support, please post a message to the LabKey Support boards at 
@REM https://www.labkey.org/project/home/Server/Forum/begin.view?
@REM
@REM The upgrade script will do the following:
@REM 1) Verify the LabKey Distribution is ready to be installed
@REM 2) Uninstall the previous version of LabKey Remote Pipeline Server
@REM 3) Install the new version of LabKey Remote Pipeline Server
@REM
@REM This script requires the unzipped distribution directory name to be entered on
@REM the command line. For example:
@REM   upgrade-remote-pipeline.bat LabKey13.3-r28123-bin


@REM Variables
@REM -------------------------------------------------------
@REM Change these variables for your server
@REM
@REM labkey_distdir is the directory which contains the LabKey distribution 
@REM labkey_home is the directory which will contain the the labkeywebapp
@REM   modules directories
@REM service_name is the name of the Windows service for the Remote Pipeline
@REM   Server.
@REM
@set labkey_distdir=c:\labkey\src\labkey
@set labkey_home=c:\labkey\labkey
@set service_name=LabKeyRemoteServer

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
@if not exist "%labkey_home%" @set cdir=%labkey_home% && goto dirnotvalid
@echo. All checks succeeded. Starting the installation


@REM Shutdown the Remote Pipeline Server
@REM -------------------------------------------------------
@echo.
@echo.
@echo ============== Shut down the Remote Pipeline Server

net stop "%service_name%"


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
mkdir %labkey_home%\labkeywebapp
mkdir %labkey_home%\modules
mkdir %labkey_home%\pipeline-lib
xcopy /y /Q /E /H %labkey_distdir%\%1\labkeywebapp %labkey_home%\labkeywebapp
xcopy /y /Q /E /H %labkey_distdir%\%1\modules %labkey_home%\modules
xcopy /y /Q /E /H %labkey_distdir%\%1\pipeline-lib %labkey_home%\pipeline-lib
copy /y %labkey_distdir%\%1\bin\*.* "%labkey_home%\bin"
copy /y %labkey_distdir%\%1\tomcat-lib\labkeyBootstrap.jar "%labkey_home%"


@REM Start the Remote Pipeline Server
@REM -------------------------------------------------------
@echo.
@echo.
@echo ============== Start the Remote Pipeline Server 

net start "%service_name%"


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

