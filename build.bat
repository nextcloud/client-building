@echo off
cls

Rem ******************************************************************************************
rem 			"enviroment Varibles"
Rem ******************************************************************************************

call local_variables.bat

rem Release or Debug
set BUILD_TYPE=Release
if [%1] == "Release" (set BUILD_TYPE=%1)

echo "* BUILD_TYPE=%BUILD_TYPE%"
echo "* PATH=%PATH%"

echo "* VCINSTALLDIR=%VCINSTALLDIR%"
echo "* VCVER=%VCVER%"
echo "* QT_PATH=%QT_PATH%"
echo "* PROJECT_PATH=%PROJECT_PATH%"
echo "* Png2Ico_EXECUTABLE=%Png2Ico_EXECUTABLE%"
echo "* QTKEYCHAIN_INCLUDE_DIR=%QTKEYCHAIN_INCLUDE_DIR%"
echo "* QTKEYCHAIN_LIBRARY=%QTKEYCHAIN_LIBRARY%"
echo "* OPENSSL_PATH=%OPENSSL_PATH%"
echo "* OPENSSL_INCLUDE_DIR=%OPENSSL_INCLUDE_DIR%"
echo "* OPENSSL_LIBRARIES=%OPENSSL_LIBRARIES%"
echo "* ZLIB_PATH=%ZLIB_PATH%"
echo "* ZLIB_LIBRARY=%ZLIB_LIBRARY%"
echo "* ZLIB_INCLUDE_DIR=%ZLIB_INCLUDE_DIR%"

Rem ******************************************************************************************
rem 			"clean up"
Rem ******************************************************************************************

rem start "rm -rf" /B /wait ...
echo "* Remove old installation files %PROJECT_PATH%\install from previous build."
if not exist "%PROJECT_PATH%\install" mkdir "%PROJECT_PATH%\install"
rm -rf %PROJECT_PATH%\install\*

echo "* Remove old dependencies files %PROJECT_PATH%\libs from previous build."
if not exist "%PROJECT_PATH%\libs" mkdir "%PROJECT_PATH%\libs"
rm -rf %PROJECT_PATH%\libs\*

echo "* Remove %PROJECT_PATH%\desktop\build from previous build."
if not exist "%PROJECT_PATH%\desktop\build" mkdir "%PROJECT_PATH%\desktop\build"
rm -rf %PROJECT_PATH%\desktop\build\*

Rem ******************************************************************************************
rem 			"git pull, build, collect dependencies"
Rem ******************************************************************************************

rem Reference: https://ss64.com/nt/start.html

echo "* git pull from origin master at %PROJECT_PATH%\desktop\"
start "git pull origin master" /D "%PROJECT_PATH%\desktop\" /B /wait git pull origin master

echo "* save git HEAD commit hash from repo %PROJECT_PATH%\desktop\"
start "git rev-parse HEAD" /D "%PROJECT_PATH%\desktop\" /B /wait git rev-parse HEAD > tmp
set /p GIT_REVISION= < tmp
del tmp
echo "* GIT_REVISION=%GIT_REVISION%"

rem set BUILD_DATE=%date:~10,4%%date:~4,2%%date:~7,2%
set BUILD_DATE=%date:~6,4%%date:~3,2%%date:~0,2%
echo "* BUILD_DATE=%BUILD_DATE%"
set MIRALL_VERSION_SUFFIX=daily
echo "* MIRALL_VERSION_SUFFIX=%MIRALL_VERSION_SUFFIX%"

echo "* Run cmake with CMAKE_INSTALL_PREFIX and CMAKE_BUILD_TYPE set at %PROJECT_PATH%\desktop\build."
start "cmake.." /D "%PROJECT_PATH%\desktop\build" /B /wait cmake "-GVisual Studio 15 2017 Win64" .. ^
    -DMIRALL_VERSION_SUFFIX="%MIRALL_VERSION_SUFFIX%" -DWITH_CRASHREPORTER=OFF -DMIRALL_VERSION_BUILD="%BUILD_DATE%" ^
    -DCMAKE_PREFIX_PATH="%QT_PATH%" -DCMAKE_INSTALL_PREFIX="%PROJECT_PATH%\install" -DCMAKE_BUILD_TYPE="%BUILD_TYPE%" ^
    -DNO_SHIBBOLETH=1 -DPng2Ico_EXECUTABLE="%Png2Ico_EXECUTABLE%" ^
    -DQTKEYCHAIN_LIBRARY="%QTKEYCHAIN_LIBRARY%" -DQTKEYCHAIN_INCLUDE_DIR="%QTKEYCHAIN_INCLUDE_DIR%" ^
    -DOPENSSL_ROOT_DIR="%OPENSSL_PATH%" -DOPENSSL_INCLUDE_DIR="%OPENSSL_INCLUDE_DIR%" -DOPENSSL_LIBRARIES="%OPENSSL_LIBRARIES%" ^
    -DZLIB_LIBRARY=%ZLIB_LIBRARY% -DZLIB_INCLUDE_DIR=%ZLIB_INCLUDE_DIR%

echo "* Run cmake to compile and install."
start "cmake build" /D "%PROJECT_PATH%/desktop/build" /B /wait cmake --build . --config %BUILD_TYPE% --target install

echo "* Run windeployqt to collect all nextcloud.exe dependencies and output it to %PROJECT_PATH%\libs\."
start "windeployqt" /B /wait windeployqt.exe --release %PROJECT_PATH%\install\bin\nextcloud.exe --dir %PROJECT_PATH%\libs\

echo "* Run NSIS script with parameters BUILD_TYPE=%BUILD_TYPE% and GIT_REVISION=%GIT_REVISION% to create installer."
start "NSIS" /B /wait makensis.exe /DBUILD_TYPE=%BUILD_TYPE% /DMIRALL_VERSION_SUFFIX=%MIRALL_VERSION_SUFFIX% /DGIT_REVISION=%GIT_REVISION:~0,6% nextcloud.nsi

exit