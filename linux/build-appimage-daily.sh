#! /bin/bash

set -xe

useradd user -u ${1:-1000}

mkdir /app
mkdir /build

#Set Qt-5.12
export QT_BASE_DIR=/opt/qt5.12.10
export QTDIR=$QT_BASE_DIR
export PATH=$QT_BASE_DIR/bin:$PATH
export LD_LIBRARY_PATH=$QT_BASE_DIR/lib/x86_64-linux-gnu:$QT_BASE_DIR/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=$QT_BASE_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

#QtKeyChain 0.10.0
cd /build
git clone https://github.com/frankosterfeld/qtkeychain.git
cd qtkeychain
git checkout v0.10.0
mkdir build
cd build
cmake -D CMAKE_INSTALL_PREFIX=/usr ../
make -j4
make install

#Build client
cd /build
git clone --depth 1 https://github.com/nextcloud/desktop.git
mkdir build-client
cd build-client
cmake -D CMAKE_INSTALL_PREFIX=/usr \
    -D BUILD_TESTING=OFF \
    -D BUILD_UPDATER=ON \
    -D QTKEYCHAIN_LIBRARY=/app/usr/lib/x86_64-linux-gnu/libqt5keychain.so \
    -D QTKEYCHAIN_INCLUDE_DIR=/app/usr/include/qt5keychain/ \
    -DMIRALL_VERSION_SUFFIX=daily \
    -DMIRALL_VERSION_BUILD=`date +%Y%m%d` \
    /build/desktop
make -j4
make DESTDIR=/app install

# Move stuff around
cd /app

mv ./usr/lib/x86_64-linux-gnu/* ./usr/lib/
rm -rf ./usr/lib/cmake
rm -rf ./usr/include
rm -rf ./usr/mkspecs
rm -rf ./usr/lib/x86_64-linux-gnu/

# Don't bundle nextcloudcmd as we don't run it anyway
rm -rf ./usr/bin/nextcloudcmd

# Don't bundle the explorer extentions as we can't do anything with them in the AppImage
rm -rf ./usr/share/caja-python/
rm -rf ./usr/share/nautilus-python/
rm -rf ./usr/share/nemo-python/

# Move sync exclude to right location
mv ./etc/Nextcloud/sync-exclude.lst ./usr/bin/
rm -rf ./etc

# com.nextcloud.desktopclient.nextcloud.desktop
DESKTOP_FILE=$(ls /app/usr/share/applications/*.desktop)
sed -i -e 's|Icon=nextcloud|Icon=Nextcloud|g' ${DESKTOP_FILE} # Bug in desktop file?
cp ./usr/share/icons/hicolor/512x512/apps/Nextcloud.png . # Workaround for linuxeployqt bug, FIXME


# Because distros need to get their shit together
cp -R /usr/lib/x86_64-linux-gnu/libssl.so* ./usr/lib/
cp -R /usr/lib/x86_64-linux-gnu/libcrypto.so* ./usr/lib/
cp -P /usr/local/lib/libssl.so* ./usr/lib/
cp -P /usr/local/lib/libcrypto.so* ./usr/lib/

# NSS fun
cp -P -r /usr/lib/x86_64-linux-gnu/nss ./usr/lib/

# Use linuxdeployqt to deploy
cd /build
wget --ca-directory=/etc/ssl/certs -c "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
chmod a+x linuxdeployqt*.AppImage
./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
rm ./linuxdeployqt-continuous-x86_64.AppImage
unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/app/usr/lib/
./squashfs-root/AppRun ${DESKTOP_FILE} -bundle-non-qt-libs -qmldir=/build/desktop/src/gui

# Set origin
./squashfs-root/usr/bin/patchelf --set-rpath '$ORIGIN/' /app/usr/lib/libnextcloudsync.so.0

# Build AppImage
./squashfs-root/AppRun ${DESKTOP_FILE} -appimage

export VERSION_MAJOR=$(cat build-client/version.h | grep MIRALL_VERSION_MAJOR | cut -d ' ' -f 3)
export VERSION_MINOR=$(cat build-client/version.h | grep MIRALL_VERSION_MINOR | cut -d ' ' -f 3)
export VERSION_PATCH=$(cat build-client/version.h | grep MIRALL_VERSION_PATCH | cut -d ' ' -f 3)
export VERSION_BUILD=$(cat build-client/version.h | grep MIRALL_VERSION_BUILD | cut -d ' ' -f 3)

mv Nextcloud*.AppImage Nextcloud-${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${VERSION_BUILD}-daily-x86_64.AppImage

mv Nextcloud*.AppImage /output/
chown user /output/Nextcloud*.AppImage
