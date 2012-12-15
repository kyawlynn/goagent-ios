#!/bin/sh
#
# control script for goagent-local
#
DBGLOG=/tmp/goagent.log
LAUNCHD_PLIST=org.goagent.local.ios.plist
start() {
    touch /tmp/goagent.pid
}
stop() {
    rm -rf /tmp/goagent.pid
    killall python > /dev/null 2>/dev/null
}
# See how we were called.
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac
exit $?

