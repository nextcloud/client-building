#! /bin/bash

set -xe

VERSION_SUFFIX=daily

PROJECT_DIR=$(pwd)
QT_DIR=/usr/local/Qt-5.15.2
OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk
OSX_DEPLOYMENT_TARGET=10.12

USER_PASSWORD=$(security find-generic-password -w -s "USER_PASSWORD")
NOTARIZATION_ACCOUNT=$(security find-generic-password -w -s "NOTARIZATION_ACCOUNT")
NOTARIZATION_PASSWORD="@keychain:NOTARIZATION_PASSWORD"

cd $PROJECT_DIR/desktop
git checkout master
git pull origin master
git submodule update

cd ..

rm -rf build
mkdir build
cd build

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH

export PATH=$QT_DIR/bin/:$PATH
export OPENSSL_ROOT_DIR=$(brew --prefix openssl@1.1)

mkdir install

#Build QtKeychain
mkdir qtkeychain
cd $PROJECT_DIR/build/qtkeychain

cmake \
        -DCMAKE_OSX_SYSROOT=$OSX_SYSROOT \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=$OSX_DEPLOYMENT_TARGET \
        -DCMAKE_INSTALL_PREFIX=$PROJECT_DIR/build/install \
        -DBUILD_OWNCLOUD_OSX_BUNDLE=ON \
        -DCMAKE_PREFIX_PATH=$QT_DIR \
        -DQT_TRANSLATIONS_DIR=$PROJECT_DIR/build/install/translations/ \
        $PROJECT_DIR/qtkeychain/

make -j2
make install
cd ..

#Build client
mkdir desktop
cd desktop

cmake \
        -DCMAKE_OSX_SYSROOT=$OSX_SYSROOT \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=$OSX_DEPLOYMENT_TARGET \
        -DCMAKE_INSTALL_PREFIX=$PROJECT_DIR/build/install \
        -DCMAKE_PREFIX_PATH=$QT_DIR \
        -DQT_TRANSLATIONS_DIR=$PROJECT_DIR/build/install/translations/ \
        -DSPARKLE_INCLUDE_DIR= \
        -DWITH_CRASHREPORTER=OFF \
        -DBUILD_UPDATER=ON \
        -DNO_SHIBBOLETH=1 \
        -DMIRALL_VERSION_BUILD=`date +%Y%m%d` \
        -DMIRALL_VERSION_SUFFIX=$VERSION_SUFFIX \
        $PROJECT_DIR/desktop

make -j2
make install
cd ..

#Sign
echo "${USER_PASSWORD}" | sudo -S ls
echo $USER_PASSWORD | sudo -S codesign -s 'Developer ID Application: Nextcloud GmbH (NKUJUXUJ3B)' --timestamp --options=runtime --force --preserve-metadata=entitlements --verbose=4 --deep install/nextcloud.app
# Verify the signature
echo $USER_PASSWORD | sudo -S codesign -dv install/nextcloud.app
echo $USER_PASSWORD | sudo -S codesign --verify -v install/nextcloud.app

./desktop/admin/osx/create_mac.sh install/ desktop/ 'Developer ID Installer: Nextcloud GmbH (NKUJUXUJ3B)'

# Notarization by Apple
cd install/
rm Nextcloud-*.pkg.tbz
MY_PKG=`echo $(ls *.pkg)`

xcrun altool --notarize-app -u "${NOTARIZATION_ACCOUNT}" -p "${NOTARIZATION_PASSWORD}" --primary-bundle-id "${MY_PKG}" --file ${MY_PKG}
sleep 600

xcrun stapler staple -v ${MY_PKG}
xcrun stapler validate -v ${MY_PKG}

tar cf ${MY_PKG}.tar ${MY_PKG}
bzip2 -9 ${MY_PKG}.tar
mv ${MY_PKG}.tar.bz2 ${MY_PKG}.tbz

#COPY OVER
scp Nextcloud-*.pkg download:/var/www/html/desktop/daily/Mac/Installer
scp Nextcloud-*.pkg.tbz download:/var/www/html/desktop/daily/Mac/Updates

