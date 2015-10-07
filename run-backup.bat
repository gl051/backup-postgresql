@echo off

:: Set Parameters as needed
:: 
SET PATH_PGADMIM="C:\Program Files (x86)\pgAdmin III\1.20"
SET SERVER=hit-gianluca
SET DB_LIST=dbmmeta700,dbmmeta830,dbmmeta900,hitsw,gl051
SET BACKUP_FOLDER="G:\Products\PostgreSQL\hit-gianluca\backups"
SET FILE_INFO=%BACKUP_FOLDER%\log.txt
SETLOCAL enabledelayedexpansion

:: ----------------------------------------------
:: -   Do not change the rest of the script     -
:: ----------------------------------------------
echo -----------------------------------------------------------------------------
echo - Backup script for PostgreSQL                                              -
echo -----------------------------------------------------------------------------
echo - SERVER: %SERVER%
echo - DATABASE LIST: %DB_LIST%
echo - BACKUP FOLDER: %BACKUP_FOLDER%
echo -----------------------------------------------------------------------------
echo Press a key to run the dump of the postgreSQL database
pause 

date /T
time /T

SET ORIGIN=%cd%

cd /d %PATH_PGADMIM%

:: Loop through the list of datbases and issue a pg_dump command

:: pg_dump options used:
:: 	-c = write the drop database command before creating the new one when restoring it
:: 	-C = write the create database command and the connect statement
::  -U = username to connect
:: 	-w = don't ask for a password (use a config file or use pgAdmin to remember the password).
::       This option could be removed if you don't plan to schedule an automatic execution.
::  -h = hostname
:: 	-Fp = plain text sql script as ouptut
:: 	-inserts = dump data as insert statements (rather than copy), to eventualy import in other rdbms
::  -d = to specify the database name
:: 	-N = to exclude a schema 

FOR %%i in (%DB_LIST%) DO (	
	copy %BACKUP_FOLDER%\db_%%i.sql %BACKUP_FOLDER%\db_%%i.sql.old > nul
	echo Executing dump command for database %%i @ %SERVER%	
	SET CURTIME=!DATE:~10,4!-!DATE:~4,2!-!DATE:~7,2!T!TIME:~0,2!:!TIME:~3,2!:!TIME:~6,2!.!TIME:~9,2!
	echo !CURTIME! - Executing dump command for database %%i @ %SERVER% >> %FILE_INFO%
		
	if "%%i"=="gl051" (
		echo Excluding schema 'sample' from the sql dump text file
		SET CURTIME=!DATE:~10,4!-!DATE:~4,2!-!DATE:~7,2!T!TIME:~0,2!:!TIME:~3,2!:!TIME:~6,2!.!TIME:~9,2!
		echo !CURTIME! - Excluding 'schema' sample from the sql dump text file >> %FILE_INFO%
		pg_dump -c -C -U postgres -w -h %SERVER% -Fp --inserts -d %%i -N sample > %BACKUP_FOLDER%\db_%%i_nosample.sql
		echo Dumping schema sample as compressed file, suitable for input into pg_restore 		
		pg_dump -c -C -U postgres -w -h %SERVER% -Fc -d %%i -n sample -b > %BACKUP_FOLDER%\db_%%i_sample.bk
		SET CURTIME=!DATE:~10,4!-!DATE:~4,2!-!DATE:~7,2!T!TIME:~0,2!:!TIME:~3,2!:!TIME:~6,2!.!TIME:~9,2!
		echo !CURTIME! - Schema sample has been compressed with option FC, provide this as input into pg_restore >> %FILE_INFO%
	) else (
		pg_dump -c -C -U postgres -w -h %SERVER% -Fp --inserts -d %%i > %BACKUP_FOLDER%\db_%%i.sql 
	)	
	echo Completed
	SET CURTIME=!DATE:~10,4!-!DATE:~4,2!-!DATE:~7,2!T!TIME:~0,2!:!TIME:~3,2!:!TIME:~6,2!.!TIME:~9,2!
	echo !CURTIME! - Completed dump of %%i >> %FILE_INFO%
)

:: Go back where you started 
cd /d %ORIGIN%

time /T

pause 
