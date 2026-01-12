@echo off
setlocal EnableDelayedExpansion
cls

Rem ******************************************************************************************
rem 			"zip a folder"
Rem ******************************************************************************************

set "BUILD_ARCH=Win64"

call "%~dp0/defaults.inc.bat"
call "%~dp0/common.inc.bat" "%BUILD_TYPE%" "%BUILD_ARCH%" master

Rem ******************************************************************************************

echo "*** Create an archive of folder: %~1 into %~2"

if "%~1" == "" (
    echo "Missing parameter: Please specify folder to archive"
    exit 1
)

if "%~2" == "" (
    echo "Missing parameter: Please specify the name of the archive to create"
    exit 1
)

if "%~3" == "" (
    echo "Missing parameter: Please specify the name of the target folder for the archive"
    exit 1
)

set "FOLDER_TO_ARCHIVE=%~1"
set "ARCHIVE_FILE_NAME=%~2"
set "TARGET_FOLDER=%~3"

Rem ******************************************************************************************

echo "* PROJECT_PATH=%PROJECT_PATH%"
echo "* VCINSTALLDIR=%VCINSTALLDIR%"
echo "* PATH=%PATH%"
echo "* FOLDER_TO_ARCHIVE=%FOLDER_TO_ARCHIVE%"
echo "* ARCHIVE_FILE_NAME=%ARCHIVE_FILE_NAME%"
echo "* TARGET_FOLDER=%TARGET_FOLDER%"

Rem ******************************************************************************************
rem 			"check for required environment variables"
Rem ******************************************************************************************

if %ERRORLEVEL% neq 0 goto onError

if "%BUILD_ARCH%" == "Win64" ( call "%VCINSTALLDIR%\Auxiliary\Build\vcvarsall.bat" x64 )
if "%BUILD_ARCH%" == "Win32" ( call "%VCINSTALLDIR%\Auxiliary\Build\vcvarsall.bat" amd64_x86 )

echo "* Create archive: tar czf %ARCHIVE_FILE_NAME% %FOLDER_TO_ARCHIVE%"
start "tar" /D "%PROJECT_PATH%" /B /wait tar czf %ARCHIVE_FILE_NAME% %FOLDER_TO_ARCHIVE%"

if %ERRORLEVEL% neq 0 goto onError

echo "* Move archive in target folder: mv %ARCHIVE_FILE_NAME% %TARGET_FOLDER%"
start "mv" /D "%PROJECT_PATH%" /B /wait mv %ARCHIVE_FILE_NAME% %TARGET_FOLDER%"

if %ERRORLEVEL% neq 0 goto onError

Rem ******************************************************************************************

echo "*** Finished creating archive: %ARCHIVE_FILE_NAME%"
exit 0

:onError
echo "*** Creating archive failed for: %FOLDER_TO_ARCHIVE% in %ARCHIVE_FILE_NAME%"
if %ERRORLEVEL% neq 0 exit %ERRORLEVEL%
if !ERRORLEVEL! neq 0 exit !ERRORLEVEL!
exit 1
