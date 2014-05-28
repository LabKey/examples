@REM ======================================================
@REM Sample backup script for PostgreSQL database
@REM This script can be used to perform a nightly backup (using pg_dump) 
@REM of databases on a PostgreSQL server instance. The script will 
@REM 1. Execute pg_dump to backup for postgres and labkey databases
@REM 2. Dump archives will be placed in the %BACKUP_DIR% directory 
@REM 3. Dump archive file names will be in the format postgresql-backup-%DB%_YYYYMMDD 
@REM   - where YYYY is the year, MM is the month and DD is the day of the month
@REM 4. Write status message to STDOUT 
@REM 5. Write status and error messages to the logfile (%LOGFILE%)
@REM ======================================================


@REM Variables
@REM ======================================================
@set BACKUP_DIR=C:\labkey\backup\database
@set POSTGRES_HOME="C:\Program Files\PostgreSQL\9.2"
@set POSTGRES_USER=postgres
@set POSTGRES_HOST=localhost
@set POSTGRES_PORT=5432
@set PGPASSFILE=C:\DIR\PG_BACKUP\PGPASSFILE\pgpass.conf
@set LOGFILE=%BACKUP_DIR%\labkey-database-backup.log
@echo off
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set DATESTR=%%c%%a%%b)
for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set TIMESTR=%%a:%%b:%%c)
@echo on

@REM Tests
@REM ======================================================
@if not exist %BACKUP_DIR%\ goto bdirnotvalid


@REM Perform the backup 
@REM ======================================================
@echo.
@echo.
@echo [%DATESTR% %TIMESTR%] ============== Start the PostgreSQL backup of all databases 
@echo [%DATESTR% %TIMESTR%] Start the PostgreSQL backup of all databases >> %LOGFILE%

@REM Backup postgres database 
@set DB=postgres
@echo off
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set DATESTR=%%c%%a%%b)
for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set TIMESTR=%%a:%%b:%%c)
@echo [%DATESTR% %TIMESTR%] ======= Start the backup of %DB% database 
@echo [%DATESTR% %TIMESTR%] Start the backup of %DB% database >> %LOGFILE%
@set BACKUP_FILENAME1=%BACKUP_DIR%\postgresql-backup-%DB%_%DATESTR%.bak
%POSTGRES_HOME%\bin\pg_dump --format=c --compress=9 -h %POSTGRES_HOST% -p %POSTGRES_PORT% -U %POSTGRES_USER% -f %BACKUP_FILENAME1% %DB% 1>> %LOGFILE% 2>&1

@REM Backup labkey database 
@set DB=labkey
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set DATESTR=%%c%%a%%b)
for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set TIMESTR=%%a:%%b:%%c)
@echo [%DATESTR% %TIMESTR%] ======= Start the backup of %DB% database 
@echo [%DATESTR% %TIMESTR%] Start the backup of %DB% database >> %LOGFILE%
@set BACKUP_FILENAME2=%BACKUP_DIR%\postgresql-backup-%DB%_%DATESTR%.bak
%POSTGRES_HOME%\bin\pg_dump --format=c --compress=9 -h %POSTGRES_HOST% -p %POSTGRES_PORT% -U %POSTGRES_USER% -f %BACKUP_FILENAME2% %DB% 1>> %LOGFILE% 2>&1


@REM Verify Dump Archives were successful, by checking if two archives exist 
@REM NOTE: This is not ideal solution, but a good first approximation
@REM ======================================================
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set DATESTR=%%c%%a%%b)
for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set TIMESTR=%%a:%%b:%%c)
@echo.
@echo.
@echo [%DATESTR% %TIMESTR%] ============== Verify the database backup files have been created
@echo [%DATESTR% %TIMESTR%] Verify the database backup files have been created >> %LOGFILE%

IF EXIST %BACKUP_FILENAME1% (
    @set /a CNT=1
) ELSE (
    @echo [%DATESTR% %TIMESTR%] ======= ERROR: %BACKUP_FILENAME1% does not exist
    @echo [%DATESTR% %TIMESTR%] ERROR: %BACKUP_FILENAME1% does not exist >> %LOGFILE%
) 

IF EXIST %BACKUP_FILENAME2% (
    @set /a CNT=%CNT%+1
) ELSE (
    @echo [%DATESTR% %TIMESTR%] ======= ERROR: %BACKUP_FILENAME2% does not exist
    @echo [%DATESTR% %TIMESTR%] ERROR: %BACKUP_FILENAME2% does not exist >> %LOGFILE%
)

IF %CNT% NEQ 2 (
    @echo.
    @echo [%DATESTR% %TIMESTR%] ERROR: One or both of the database backup tasks are has failed. 
    @echo [%DATESTR% %TIMESTR%]    See %LOGFILE% for more information 
    @echo [%DATESTR% %TIMESTR%] ERROR: One or both of the database backup tasks are has failed. >> %LOGFILE%
    @echo [%DATESTR% %TIMESTR%]    See %LOGFILE% for more information >> %LOGFILE%
    
    @goto end
)



@REM The backups have been completed. Write an entry to the log file.
@REM ======================================================
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set DATESTR=%%c%%a%%b)
for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set TIMESTR=%%a:%%b:%%c)
@echo on
@echo [%DATESTR% %TIMESTR%] ============== PostgreSQL backup has completed
@echo [%DATESTR% %TIMESTR%] ============== PostgreSQL backup has completed >> %LOGFILE%


@goto end


:bdirnotvalid
@REM ======================================================
@echo.
@echo ERROR: The directory which will hold the backups, %BACKUP_DIR%, 
@echo        is not a valid directory
@echo [%DATESTR% %TIMESTR%] Start the PostgreSQL backup of all databases >> %LOGFILE%
@echo [%DATESTR% %TIMESTR%] ERROR: The directory which will hold the backups, %BACKUP_DIR% is not a valid directory >> %LOGFILE%
@goto end


:end
@REM ======================================================
@echo.
