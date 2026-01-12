Rem ******************************************************************************************
rem "common environment Variables"
Rem ******************************************************************************************

set "BUILD_ARCH=%~2"
set "CMAKE_GENERATOR=Ninja"
set "BRANCH_NAME=%~3"

if "%BUILD_ARCH%" == "Win32" ( set "CRAFT_PATH=c:\Craft32" )
if "%BUILD_ARCH%" == "Win32" ( set "QT_PATH=%CRAFT_PATH%" )
if "%BUILD_ARCH%" == "Win32" ( set "PATH=%CRAFT_PATH%\bin;%CRAFT_PATH%\dev-utils\bin;%PATH%" )
if "%BUILD_ARCH%" == "Win32" ( set "QT_BIN_PATH=%CRAFT_PATH%\bin" )
if "%BUILD_ARCH%" == "Win32" ( set "QT_PREFIX=%CRAFT_PATH%" )

if "%BUILD_ARCH%" == "Win64" ( set "CRAFT_PATH=c:\Nextcloud\%BRANCH_NAME%\windows-msvc2022_64-cl" )
if "%BUILD_ARCH%" == "Win64" ( set "QT_PATH=%CRAFT_PATH%" )
if "%BUILD_ARCH%" == "Win64" ( set "PATH=%CRAFT_PATH%\bin;%CRAFT_PATH%\dev-utils\bin;%PATH%" )
if "%BUILD_ARCH%" == "Win64" ( set "QT_BIN_PATH=%CRAFT_PATH%\bin" )
if "%BUILD_ARCH%" == "Win64" ( set "QT_PREFIX=%CRAFT_PATH%" )
