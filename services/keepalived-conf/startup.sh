#!/bin/bash -e

# if container log level is trace:
# print commands and their arguments as they are executed
container logger level eq trace && set -x

if [ ! -e "${KEEPALIVED_CONF}" ]; then

  KEEPALIVED_UNICAST_PEERS=$(echo "${KEEPALIVED_UNICAST_PEERS}" | xargs -n1)
  KEEPALIVED_VIRTUAL_IPS=$(echo "${KEEPALIVED_VIRTUAL_IPS}" | xargs -n1)

  export KEEPALIVED_UNICAST_PEERS
  export KEEPALIVED_VIRTUAL_IPS

  if [ -n "${KEEPALIVED_NOTIFY_SCRIPT}" ]; then
    # shellcheck disable=SC2089
    KEEPALIVED_NOTIFY="notify \"${KEEPALIVED_NOTIFY_SCRIPT}\""

    # shellcheck disable=SC2090
    export KEEPALIVED_NOTIFY
  fi

  container envsubst file "${KEEPALIVED_CONF_TEMPLATE}" "${KEEPALIVED_CONF}"

fi
