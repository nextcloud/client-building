## Update 2023-10

- Uses dependencies installed with KDE Craft via https://github.com/nextcloud/desktop-client-blueprints

## Update: 2020-09-08

MSI build support:
- Will be available with NC 3.0.2 and up
- Install the WiX Toolset build tools: https://wixtoolset.org/releases/
- Set: `BUILD_INSTALLER_MSI=1`

## Update: 2020-08-21

Build support for NC 3.0:
- Shell extensions changed by: https://github.com/nextcloud/desktop/pull/2288
- New client-building branches to ease building: stable-2.5, stable-2.6, stable-3.0

## Update: 2020-07-22

Upgrade / new default version:
- Qt 5.12.9

The previous patch of the Qt 5.12.8 include file is not required anymore :)

## Update: 2020-07-16

Added new option to build the Updater (disabled by default):

```
BUILD_UPDATER=ON ./build.bat Release
```

## Update: 2020-06-20

When building from a tag it is best to set PULL_DESKTOP to 0:

```
TAG_DESKTOP=v2.7.0-beta1 PULL_DESKTOP=0 ./build.bat Release
```

Otherwise the build might exit with the following error:

```
You are not currently on a branch.
Please specify which branch you want to merge with.
```

## Update: 2020-06-13

The VC Runtime redistributable filenames have changed in VS 2019.

If you still want to use VS 2017 you may have to change them, see: https://github.com/nextcloud/client-building/pull/28

## Update: 2020-06-11

Upgrades / new default versions:
- Qt 5.12.8
- OpenSSL 1.1.1g
- Visual Studio 2019 (and 2017) support
- can build Desktop client series 2.6 and 2.7 (QML)

Note: You need to patch an include file of Qt 5.12.8 for use with MSVC, see: https://github.com/nextcloud/client-building/blob/e7b04ac00f0cfd7f9b3b4a3651ce0adc5ca07c29/README.md#install-list

Patched file: https://raw.githubusercontent.com/nextcloud/client-building/e7b04ac00f0cfd7f9b3b4a3651ce0adc5ca07c29/Windows/Qt-5.12.8-QtCore-Patch/qlinkedlist.h

Also note that the Qt Maintenance tool now requires you to register an Qt Account (free).

VS2019 is now default, if you want to use 2017, set: `VS_VERSION=2017`

## Update: 2019-09-27

Upgrades / new default versions:
- Qt 5.12.5
- OpenSSL 1.1.1d

## Update: 2019-08-18

Qt 5.12.4 and up for Windows don't require the old 1.0.x DLL's anymore (libeay32.dll + ssleay32.dll)
and is linked against OpenSSL 1.1.1

This finally removes the odd mixture of diverging DLL versions.
Now the Desktop Client finally uses OpenSSL 1.1.1 components only, reports the correct
library version and also supports TLS 1.3 :-)

See here for details: https://blog.qt.io/blog/2019/06/17/qt-5-12-4-released-support-openssl-1-1-1/

- Code Signing of the client binaries (exe + dll's), the installer and the uninstaller
- Uploading the generated installer package via SSH connection (scp)
- Script file to be invoked by the Windows Task Scheduler for automatic builds (e.g.: daily)
