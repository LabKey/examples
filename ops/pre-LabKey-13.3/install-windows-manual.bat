@REM Manual Installation Script for LabKey Server.
@REM
@REM ****************************************************************************
@REM *** IMPORTANT: THIS SCRIPT SHOULD ONLY BE USED IF YOU ARE INSTALLING
@REM ***            AN OLD VERSION OF LABKEY SERVER. USE THIS SCRIPT
@REM ***            IF YOU ARE INSTALLING LABKEY SERVER v13.2 OR EARLIER.
@REM ***
@REM ***            IF YOU ARE INSTALL A LATER VERSION OF LABKEY SERVER
@REM ***            (V13.3 OR LATER) THEN USE THE UPDATED SCRIPT FOUND AT
@REM ***            https://github.com/bdconnolly/labkey-ops
@REM ***
@REM ***            NOTE: LABKEY SERVER v13.3 WAS RELEASED IN NOV. 2013
@REM ****************************************************************************
@REM
@REM This script can be used when performing a manual installation of LabKey Server, on Windows 
@REM This script will install the LabKey Web application binaries. It will not install the 
@REM   pre-requisite software such as JAVA, TOMCAT.
@REM
@REM This script assumes that 
@REM    - pre-requisite software has been already been installed.
@REM     -- Apache Tomcat
@REM     -- Oracle JAVA
@REM    - Tomcat is installed as a Windows Service
@REM
@REM See https://www.labkey.org/wiki/home/Documentation/page.view?name=manualInstall 
@REM   for more information on manually installing LabKey Server.
@REM
@REM This script requires the unzipped distribution directory name to be entered on 
@REM the command line. For example 
@REM   install-windows-manual.bat LabKey13.1-r23489-bin


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
@set service_name=Tomcat6


@REM Tests
@REM -------------------------------------------------------
@echo.
@echo.
@echo ============== Verify everything is ready to go
@REM Check command line options
@if "%1" == "" goto commandlinewrong
@REM Check if Windows service exists 
@sc query | find /I "%service_name%" > nul
@if ERRORLEVEL 1 GOTO servicemissing
@REM Check if the directories exist
@if not exist "%labkey_distdir%\%1" @set cdir=%labkey_distdir%\%1 && goto dirnotvalid
@if not exist "%catalina_home%" @set cdir=%catalina_home% && goto dirnotvalid
@echo. All checks succeeded. Starting the installation



@REM Shutdown the Tomcat Server
@REM -------------------------------------------------------
@echo.
@echo.
@echo ============== Shut down the Tomcat Server 

net stop "%service_name%"


@REM Install the LabKey Server software 
@REM -------------------------------------------------------
@echo.
@echo.
@echo ============== Install the LabKey Server software
@echo.
@if not exist "%labkey_home%" (
    mkdir "%labkey_home%"
    @if not exist "%labkey_home%" goto labkeyhomemissing
)

@REM Check if labkey_home contains any files of subdirectories
@dir /b /a "%labkey_home%"|@findstr .>nul:&&(goto containsfile)

@REM Create directories in labkey_home
mkdir "%labkey_home%\labkeywebapp"
mkdir "%labkey_home%\modules"
mkdir "%labkey_home%\pipeline-lib"
mkdir "%labkey_home%\bin"
xcopy /y /Q /E /H "%labkey_distdir%\%1\labkeywebapp" "%labkey_home%\labkeywebapp"
xcopy /y /Q /E /H "%labkey_distdir%\%1\modules" "%labkey_home%\modules"
xcopy /y /Q /E /H "%labkey_distdir%\%1\pipeline-lib" "%labkey_home%\pipeline-lib"
xcopy /y /Q /E /H "%labkey_distdir%\%1\bin" "%labkey_home%\bin"
copy /y "%labkey_distdir%\%1\server-lib"\*.jar "%catalina_home%\lib"
copy /y "%labkey_distdir%\%1\common-lib"\*.jar "%catalina_home%\lib"

@REM Create the %catalina_home%\Catalina\localhost directory if it does not exist
@if not exist "%catalina_home%\Catalina\localhost" (
    mkdir "%catalina_home%\Catalina\localhost"
    @if not exist "%catalina_home%\Catalina\localhost" goto labkeyhomemissing
)



@REM Installation is complete
@REM -------------------------------------------------------
@echo.
@echo.
@echo ============== Installation script has completed
@echo.
@echo To complete the installation you will need to 
@echo 1. Review the output above for any errors
@echo 2. Copy the labkey.xml file from 
@echo       %labkey_distdir%\%1 to %catalina_home%\conf\Catalina\localhost
@echo 3. Configure the labkey.xml file for you server: 
@echo       - See https://www.labkey.org/wiki/home/Documentation/page.view?name=cpasxml
@echo       - appdocbase attribute should be set to %labkey_home%\labkeywebapp
@echo 4. Start the Tomcat Server by running
@echo       net start "%service_name"

@goto end


:commandlinewrong
@echo.
@echo ERROR:
@echo You must enter the unzipped directory name. 
@echo For example: %0 LabKey13.1-r23489-bin
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

:containsfiles
@echo.
@echo ERROR:
@echo %labkey_home% is not empty. LabKey cannot be installed into
@echo a directory containing other files. Please choose another directory
@goto end

:labkeyhomemissing
@echo.
@echo ERROR:
@echo Creation of %labkey_home% has failed. See above for error message
@goto end



:end
