#!/bin/sh

DEVICE_IP=192.168.1.231
DEB_ID=org.goagent.local.widget
VERSION=`grep Version control | cut -d ":" -f2 | tr -d " "`
DEB_NAME="${DEB_ID}_${VERSION}_iphoneos-arm.deb"

# make package, include preinst/postinst if existed
function make_package()
{
    rm -rf "./_"

    mkdir -p "./_/DEBIAN"
    cp -f "./control" "./_/DEBIAN"
    if [[ -e "preinst" ]]; then
        cp -f "./preinst" "./_/DEBIAN"
    fi
    if [[ -e "postinst" ]]; then
        cp -f "./poinst" "._/DEBIAN"
    fi
    mkdir -p "./_/Library/WeeLoader/Plugins/goagentwidget.bundle"
    rsync -a "./obj/goagentwidget.bundle/" "./_/Library/WeeLoader/Plugins/goagentwidget.bundle"
    dpkg-deb -b "./_" "./$DEB_NAME"
}

function make_deploy()
{
    scp $DEB_NAME root\@$DEVICE_IP:~/workspace
    ssh -p 22 root\@$DEVICE_IP "dpkg -i ~/workspace/$DEB_NAME"
    ssh -p 22 root\@$DEVICE_IP_IP "killall -9 SpringBoard"
}

make clean && make && make_package && make_deploy #&& make install

echo done
