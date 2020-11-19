#!/bin/bash

# if container log level is trace:
# print commands and their arguments as they are executed
container logger level eq trace && set -x

# for ANY state transition.
# "notify" script is called AFTER the notify_* script(s) and
# is executed with 4 additional arguments after the configured
# arguments provided by Keepalived:
#   $1 = "GROUP"|"INSTANCE"
#   $2 = name of the group or instance
#   $3 = target state of transition (stop only applies to instances)
#            ("MASTER"|"BACKUP"|"FAULT"|"STOP"|"DELETED")
#   $4 = priority value
#   $1 and $3 are ALWAYS sent in uppercase, and the possible
# strings sent are the same ones listed above
#   ("GROUP"/"INSTANCE", "MASTER"/"BACKUP"/"FAULT"/"STOP"/"DELETED")
# (note: DELETED is only applicable to instances)

INSTANCE=$1
NAME=$2
STATE=$3

case ${STATE} in
    "MASTER")
        container logger info "VRRP ${INSTANCE} ${NAME} entered MASTER state"
        exit 0
    ;;
    "BACKUP")
        container logger info "VRRP ${INSTANCE} ${NAME} entered BACKUP state"
        exit 0
    ;;
    "FAULT")
        container logger warning "VRRP ${INSTANCE} ${NAME} entered FAULT state"
        exit 0
    ;;
    "STOP")
        container logger warning "VRRP ${INSTANCE} ${NAME} entered STOP state"
        exit 0
    ;;
    "DELETED")
        container logger warning "VRRP ${INSTANCE} ${NAME} entered DELETED state"
        exit 0
    ;;
    *)
        container logger error "VRRP ${INSTANCE} ${NAME} entered unknown keepalived state: ${STATE}"
        exit 1
    ;;
esac
