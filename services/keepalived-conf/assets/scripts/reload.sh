#!/bin/bash -e

# if container log level is trace:
# print commands and their arguments as they are executed
container logger level eq trace && set -x

KEEPALIVED_PID_FILE="/run/container/processes/keepalived.pid"

container logger info "Reloading Keepalived ..."
if [ ! -e "${KEEPALIVED_PID_FILE}" ]; then
  container logger error "Keepalived PID file not found: ${KEEPALIVED_PID_FILE}"
  exit 1
fi

kill -HUP "$(cat "${KEEPALIVED_PID_FILE}")"
