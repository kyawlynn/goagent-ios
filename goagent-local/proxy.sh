#!/bin/sh
#
# control script for goagent-local
#
DBGLOG=/var/mobile/goagent/goagent.log
GOAGENT_PID=/var/mobile/goagent/goagent.pid
LAUNCHD_PLIST=org.goagent.local.ios.plist
start() {
    touch "$GOAGENT_PID"
}
stop() {
    rm -rf "$GOAGENT_PID"
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

