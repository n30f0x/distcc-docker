#!/usr/bin/env sh
dbus-daemon --system
avahi-daemon --no-chroot &

distccd --daemon --port 3632 --stats --stats-port 3633 --log-stderr --allow-private --zeroconf
