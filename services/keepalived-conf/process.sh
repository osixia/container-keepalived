#!/bin/bash -e

# if container log level is trace:
# print commands and their arguments as they are executed
container logger level eq trace && set -x

exec container watch "${KEEPALIVED_CONF}" --exec "${KEEPALIVED_CONF_RELOAD_SCRIPT}"
