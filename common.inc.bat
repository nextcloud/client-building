Rem ******************************************************************************************
rem "common environment Variables"
Rem ******************************************************************************************

rem Release or Debug
::set "BUILD_TYPE=Release"

if "%~1" == "Debug" (set "BUILD_TYPE=%~1")

if "%~2" == "Win32" (set "BUILD_ARCH=%~2")

if "%BUILD_ARCH%" == "Win32" (
    set "CRAFT_PATH=d:\Craft32"
    set "QT_PATH=%CRAFT_PATH%"
    set "PATH=%CRAFT_PATH%\bin;%CRAFT_PATH%\dev-utils\bin;%PATH%"
    set "QT_BIN_PATH=%CRAFT_PATH%\bin"
    set "QT_PREFIX=%CRAFT_PATH%"
    exit 1
)

Rem ******************************************************************************************
rem Win64 or Win32, VS 2017 or 2019 - note that 2019 generator syntax excludes Arch type,
rem it's provided by the -A option (OR: CMAKE_GENERATOR_PLATFORM) instead.
rem QT msvc2017 is still the latest because it actually works for both (2019 compilery is binary compatible)
set "BUILD_ARCH=Win64"
set "CMAKE_GENERATOR=Ninja"

set "CRAFT_PATH=d:\Craft64"
set "QT_PATH=%CRAFT_PATH%"
set "PATH=%CRAFT_PATH%\bin;%CRAFT_PATH%\dev-utils\bin;%PATH%"
set "QT_BIN_PATH=%CRAFT_PATH%\bin"
set "QT_PREFIX=%CRAFT_PATH%"


Rem ******************************************************************************************
