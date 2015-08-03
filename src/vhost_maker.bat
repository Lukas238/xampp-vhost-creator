@ECHO off
setlocal EnableDelayedExpansion

REM VARIABLES
cd /D %~dp0
SET SCRIPTPATH=%~dp0
SET vhostname=false
SET vhostpath=false
SET XAMPPDIR=false
SET BASEURL=false
SET PREFIX=false
SET SUFFIX=false




REM START	********************************************************
:start
cls

@ECHO =======================================================
@ECHO:
@ECHO                XAMPP Virtual Host Creator
@ECHO                    ~ by Lucas Dasso ~
@ECHO:
@ECHO:  https://github.com/Lukas238/xampp-vhost-creator.git  
@ECHO:
@ECHO =======================================================


REM CONFIG *******************************************************

IF NOT EXIST "%SCRIPTPATH%\config.ini" (
	ECHO:
	ECHO No config file found!
	ECHO:
	ECHO ----------------------------------------------
	ECHO:
	ECHO ### Setting initial config ###	
	
	REM :xamppdir
	ECHO:
	SET XAMPPDIR=false
	SET /p XAMPPDIR="[1/4] Absolute path of Xampp install folder (C:\Xampp\): " %=%
	
	IF !XAMPPDIR!==false  (
		SET XAMPPDIR=C:\Xampp\
	) ELSE (
		IF NOT "!XAMPPDIR:~-1!"=="\" (
			SET XAMPPDIR=!XAMPPDIR!\
		)
	)
	
	REM :baseurl
	ECHO:
	SET BASEURL=false
	SET /p BASEURL="[2/4] Absolute path of Xampp document root folder (C:\Xampp\htdocs\): " %=%
	IF !BASEURL!==false  (
		SET BASEURL=C:\Xampp\htdocs\
	) ELSE (
		IF NOT "!BASEURL:~-1!"=="\" (
			SET BASEURL=!BASEURL!\
		)
	)
		
	REM :prefix
	ECHO:
	SET PREFIX=false
	SET /p PREFIX="[3/4] Domain prefix (dev): " %=%
	IF !PREFIX!==false  (
		SET PREFIX=dev
	)
		
	REM :suffix
	ECHO:
	SET SUFFIX=false
	SET /p SUFFIX="[4/4] Domain suffix (local): " %=%
	IF !SUFFIX!==false (
		SET SUFFIX=local
	)
		
	ECHO: 
	ECHO ----------------------------------------------
	ECHO: 
	
	ECHO Xampp install dir: !XAMPPDIR!
	ECHO     Document root: !BASEURL!
	ECHO     Domain prefix: !PREFIX!
	ECHO     Domain suffix: !SUFFIX!
	ECHO:
	choice /M "Is the information correct?" /c YN
	IF ERRORLEVEL 2 GOTO start
	
	REM SAVE THE CONFIG FILE
	(
		ECHO xamppdir=!XAMPPDIR!
		ECHO baseurl=!BASEURL!
		ECHO prefix=!PREFIX!
		ECHO suffix=!SUFFIX!
	) >>%SCRIPTPATH%\config.ini
	
	GOTO start
	
) ELSE (
	for /f "tokens=1,2 delims==" %%a in (config.ini) do (
		if %%a==xamppdir set XAMPPDIR=%%b
		if %%a==baseurl set BASEURL=%%b
		if %%a==suffix set SUFFIX=%%b
		if %%a==prefix set PREFIX=%%b
	)
)


REM *****************************************************************

:getvhostname
ECHO: 
SET /p vhostname="Domain name (ex.: %PREFIX%.[domain].%SUFFIX%): " %=%
IF !vhostname!==false (
	ECHO You must enter a valid domain name.
	GOTO getvhostname
)
REM ECHO !vhostname!


:getvhostpath
ECHO:
SET /p vhostpath="Path to site root (relative to !BASEURL!): " %=%
IF !vhostpath!==false (
	ECHO You must enter a valid name for the virtual host. 
	GOTO getvhostpath
)
IF NOT EXIST %BASEURL%%vhostpath% (
	ECHO The folder must exists! Please try again. 
	GOTO getvhostpath 
) 
REM ECHO !vhostpath!


REM *****************************************************************

ECHO: 
ECHO ----------------------------------------------
ECHO: 
ECHO Domain: %PREFIX%.%vhostname%.%SUFFIX%
ECHO   Path: %BASEURL%%vhostpath%
ECHO:
choice /M "Is the information correct?" /c YN
IF ERRORLEVEL 2 GOTO start
ECHO: 
ECHO ----------------------------------------------
ECHO: 


ECHO [1/2] Adding virtualhost to httpd.conf
(
	ECHO:
	ECHO:
	ECHO    ###%vhostname%###
	ECHO    ^<VirtualHost *^>
	ECHO        DocumentRoot "%BASEURL%%vhostpath%"
	ECHO        ServerName %PREFIX%.%vhostname%.%SUFFIX%
	ECHO        ^<Directory "%BASEURL%%vhostpath%"^>
	ECHO            Order allow,deny
	ECHO            Allow from all
	ECHO        ^</Directory^>
	ECHO    ^</VirtualHost^>
) >>%XAMPPDIR%apache\conf\extra\httpd-vhosts.conf

ECHO [2/2] Write into hosts file:

TYPE "%SystemRoot%\system32\drivers\etc\hosts" | find "127.0.0.1 %PREFIX%.%vhostname%.%SUFFIX%" || ECHO.127.0.0.1 %PREFIX%.%vhostname%.%SUFFIX% >>"%SystemRoot%\system32\drivers\etc\hosts"


REM DONE ************************************************************

cls
ECHO: 
ECHO ================== All Done! ==================
ECHO:
ECHO The new vhost domain is: [%PREFIX%.%vhostname%.%SUFFIX%]
ECHO Restart Apache to see the changes
ECHO: 
ECHO: 
PAUSE
:exit