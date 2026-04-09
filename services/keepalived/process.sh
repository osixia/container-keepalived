#!/bin/bash -e

# if container log level is trace:
# print commands and their arguments as they are executed
container log level eq trace && set -x

exec /usr/local/sbin/keepalived -f "${KEEPALIVED_CONF}" --dont-fork --log-console "$@"
