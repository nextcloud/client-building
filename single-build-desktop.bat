@echo off
setlocal EnableDelayedExpansion
cls

echo "*** Build: desktop (%~nx0)"

Rem ******************************************************************************************
rem 			"environment Variables"
Rem ******************************************************************************************

call "%~dp0/common.inc.bat" %1 %2

Rem ******************************************************************************************

if "%TAG%" == "" set TAG=%TAG_DESKTOP%
if "%ICON_SET%" == "" set ICON_SET=PNG

set VERSION_SUFFIX=%VERSION_SUFFIX%-%BUILD_ARCH%

set MY_REPO=%PROJECT_PATH%/desktop
set MY_BUILD_PATH=%MY_REPO%/build
set MY_INSTALL_PATH=%PROJECT_PATH%/install/%BUILD_TYPE%/%BUILD_ARCH%
set MY_QT_DEPLOYMENT_PATH=%MY_INSTALL_PATH%/qt-libs

echo "* APP_NAME=%APP_NAME%"
echo "* USE_BRANDING=%USE_BRANDING%"
echo "* ICON_SET=%ICON_SET%"
echo "* BUILD_TYPE=%BUILD_TYPE%"
echo "* BUILD_ARCH=%BUILD_ARCH%"
echo "* CMAKE_GENERATOR=%CMAKE_GENERATOR%"
echo "* CMAKE_GENERATOR_PLATFORM=%CMAKE_GENERATOR_PLATFORM%"
echo "* CMAKE_EXTRA_FLAGS_DESKTOP=%CMAKE_EXTRA_FLAGS_DESKTOP%"
echo "* PROJECT_PATH=%PROJECT_PATH%"

echo "* QT_PATH=%QT_PATH%"
echo "* QT_BIN_PATH=%QT_BIN_PATH%"

echo "* VCINSTALLDIR=%VCINSTALLDIR%"
echo "* Png2Ico_EXECUTABLE=%Png2Ico_EXECUTABLE%"
echo "* QTKEYCHAIN_INCLUDE_DIR=%QTKEYCHAIN_INCLUDE_DIR%"
echo "* QTKEYCHAIN_LIBRARY=%QTKEYCHAIN_LIBRARY%"
echo "* OPENSSL_ROOT_DIR=%OPENSSL_ROOT_DIR%"
echo "* OPENSSL_INCLUDE_DIR=%OPENSSL_INCLUDE_DIR%"
echo "* OPENSSL_LIBRARIES=%OPENSSL_LIBRARIES%"
echo "* ZLIB_INCLUDE_DIR=%ZLIB_INCLUDE_DIR%"
echo "* ZLIB_LIBRARY=%ZLIB_LIBRARY%"

echo "* Build date %BUILD_DATE%"
echo "* VERSION_SUFFIX %VERSION_SUFFIX%"
echo "* TAG %TAG%"
echo "* PULL_DESKTOP %PULL_DESKTOP%"
echo "* CHECKOUT_DESKTOP %CHECKOUT_DESKTOP%"
echo "* BUILD_UPDATER %BUILD_UPDATER%"

echo "* MY_REPO=%MY_REPO%"
echo "* MY_BUILD_PATH=%MY_BUILD_PATH%"
echo "* MY_INSTALL_PATH=%MY_INSTALL_PATH%"
echo "* MY_QT_DEPLOYMENT_PATH=%MY_QT_DEPLOYMENT_PATH%"

echo "* PATH=%PATH%"

Rem ******************************************************************************************
rem 			"check for required environment variables"
Rem ******************************************************************************************

call :testEnv APP_NAME
call :testEnv PROJECT_PATH
call :testEnv BUILD_TYPE
call :testEnv BUILD_ARCH
call :testEnv CMAKE_GENERATOR
call :testEnv CMAKE_GENERATOR_PLATFORM
call :testEnv QT_PATH
call :testEnv QT_BIN_PATH
call :testEnv VCINSTALLDIR
call :testEnv Png2Ico_EXECUTABLE
call :testEnv OPENSSL_ROOT_DIR
call :testEnv OPENSSL_INCLUDE_DIR
call :testEnv OPENSSL_LIBRARIES
call :testEnv ZLIB_INCLUDE_DIR
call :testEnv ZLIB_LIBRARY
call :testEnv BUILD_DATE
call :testEnv BUILD_UPDATER
call :testEnv TAG

if %ERRORLEVEL% neq 0 goto onError

Rem ******************************************************************************************
rem 			"Test run?"
Rem ******************************************************************************************

if "%TEST_RUN%" == "1" (
    echo "** TEST RUN - exit."
    exit
)

Rem ******************************************************************************************
rem 			"clean up"
Rem ******************************************************************************************

echo "* Remove old installation files %MY_INSTALL_PATH% from previous build."
start "rm -rf" /B /wait rm -rf "%MY_INSTALL_PATH%/"*
if %ERRORLEVEL% neq 0 goto onError

echo "* Remove old dependencies files %MY_QT_DEPLOYMENT_PATH% from previous build."
start "rm -rf" /B /wait rm -rf "%MY_QT_DEPLOYMENT_PATH%/"*
if %ERRORLEVEL% neq 0 goto onError

echo "* Remove %MY_BUILD_PATH%/CMakeFiles from previous build."
start "rm -rf" /B /wait rm -rf "%MY_BUILD_PATH%/"*
if %ERRORLEVEL% neq 0 goto onError

Rem ******************************************************************************************
rem 			"git pull, build, collect dependencies"
Rem ******************************************************************************************

rem Reference: https://ss64.com/nt/setlocal.html
rem Reference: https://ss64.com/nt/start.html

if "%PULL_DESKTOP%" == "1" (
    Rem Checkout master first to have it clean for git pull
    if "%CHECKOUT_DESKTOP%" == "1" (
        echo "* git checkout master at %MY_REPO%/."
        start "git checkout master" /D "%MY_REPO%/" /B /wait git checkout master
    )
    if !ERRORLEVEL! neq 0 goto onError

    echo "* git pull master at %MY_REPO%/."
    start "git pull master" /D "%MY_REPO%/" /B /wait git pull --tags origin master
)
if %ERRORLEVEL% neq 0 goto onError

if "%CHECKOUT_DESKTOP%" == "1" (
    echo "* git checkout %TAG% at %MY_REPO%/."
    start "git checkout %TAG%" /D "%MY_REPO%/" /B /wait git checkout %TAG%
    if !ERRORLEVEL! neq 0 goto onError

    if "%PULL_DESKTOP%" == "1" (
        echo "* git pull %TAG% at %MY_REPO%/."
        start "git pull %TAG%" /D "%MY_REPO%/" /B /wait git pull
    )
)
if %ERRORLEVEL% neq 0 goto onError

echo "* save git HEAD commit hash from repo %MY_REPO%/."
start "git rev-parse HEAD" /D "%MY_REPO%/" /B /wait git rev-parse HEAD > "%PROJECT_PATH%"/tmp
if %ERRORLEVEL% neq 0 goto onError
set /p GIT_REVISION= < "%PROJECT_PATH%"\tmp
if %ERRORLEVEL% neq 0 goto onError
del "%PROJECT_PATH%"\tmp

echo "* Run cmake with CMAKE_INSTALL_PREFIX and CMAKE_BUILD_TYPE set at %MY_BUILD_PATH%."
start "cmake.." /D "%MY_BUILD_PATH%" /B /wait cmake "-G%CMAKE_GENERATOR%" -DICON_SET="%ICON_SET%" -DCMAKE_GENERATOR_PLATFORM="%CMAKE_GENERATOR_PLATFORM%" .. -DCMAKE_PREFIX_PATH="%QT_PREFIX%;%QTKEYCHAIN_PREFIX%" -DMIRALL_VERSION_SUFFIX="%VERSION_SUFFIX%" -DWITH_CRASHREPORTER=OFF -DBUILD_UPDATER=%BUILD_UPDATER% -DMIRALL_VERSION_BUILD="%BUILD_DATE%" -DCMAKE_INSTALL_PREFIX="%MY_INSTALL_PATH%" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" -DNO_SHIBBOLETH=1 -DPng2Ico_EXECUTABLE="%Png2Ico_EXECUTABLE%" -DOPENSSL_ROOT_DIR="%OPENSSL_ROOT_DIR%" -DOPENSSL_INCLUDE_DIR="%OPENSSL_INCLUDE_DIR%" -DOPENSSL_LIBRARIES="%OPENSSL_LIBRARIES%" -DZLIB_INCLUDE_DIR="%ZLIB_INCLUDE_DIR%" -DZLIB_LIBRARY="%ZLIB_LIBRARY%" %CMAKE_EXTRA_FLAGS_DESKTOP%
if %ERRORLEVEL% neq 0 goto onError

echo "* Run cmake to compile and install."
start "cmake build" /D "%MY_BUILD_PATH%" /B /wait cmake --build . --config %BUILD_TYPE% --target install
if %ERRORLEVEL% neq 0 goto onError

if "%BUILD_TYPE%" == "Debug" (
    set WINDEPLOYQT_BUILD_TYPE=debug
) else (
    set WINDEPLOYQT_BUILD_TYPE=release
)
echo "* Run windeployqt to collect all %APP_NAME%.exe dependencies and output it to %MY_QT_DEPLOYMENT_PATH%/."
start "windeployqt" /B /wait %QT_BIN_PATH%/windeployqt.exe --%WINDEPLOYQT_BUILD_TYPE% --compiler-runtime "%MY_INSTALL_PATH%/bin/%APP_NAME%.exe" --dir "%MY_QT_DEPLOYMENT_PATH%/" --qmldir "%MY_REPO%/src/gui"
if %ERRORLEVEL% neq 0 goto onError

Rem ******************************************************************************************

echo "*** Finished Build: desktop %BUILD_TYPE% %BUILD_ARCH% (GIT_REVISION=%GIT_REVISION%) (%~nx0)"
exit 0

:onError
echo "*** Build FAILED: desktop %BUILD_TYPE% %BUILD_ARCH% (%~nx0)"
if %ERRORLEVEL% neq 0 exit %ERRORLEVEL%
if !ERRORLEVEL! neq 0 exit !ERRORLEVEL!
exit 1

:testEnv
if "!%*!" == "" (
    echo "Missing environment variable: %*"
    exit /B 1
)
exit /B