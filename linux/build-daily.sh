#! /bin/bash

set -xe

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATE=`date +%Y%m%d`

mkdir -p ~/output/$DATE

#Build
docker run \
    --name desktop-$DATE \
    -v $DIR:/input \
    -v ~/output/$DATE:/output \
    ghcr.io/nextcloud/continuous-integration-client-appimage:client-appimage-2 \
    /input/build-appimage-daily.sh $(id -u)

#Save the logs!
docker logs desktop-$DATE > ~/output/$DATE/log

#Kill the container!
docker rm desktop-$DATE

#Copy to the download server
scp ~/output/$DATE/*.AppImage daily_desktop_uploader@download.nextcloud.com:/var/www/html/desktop/daily/Linux

# remove all but the latest 5 dailies
/bin/ls -t ~/output | awk 'NR>6' | xargs rm -fr