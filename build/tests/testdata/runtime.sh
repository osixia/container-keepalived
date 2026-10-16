#!/bin/sh
set -eu

# This script runs as PID 1: the notify script logs to /proc/1/fd/1,
# so all output goes through a pipe, like in a real container, to a log
# file, and fd 3 keeps the original stdout.
log=/tmp/keepalived-runtime.log
pipe=/tmp/keepalived-runtime.pipe
mkfifo "$pipe"
cat "$pipe" >"$log" &
logger=$!
exec 3>&1 >"$pipe" 2>&1

runner=
cleanup() {
  status=$?
  if [ -n "$runner" ]; then
    kill -TERM "$runner" 2>/dev/null || true
    wait "$runner" 2>/dev/null || true
  fi
  exec >&3 2>&1
  wait "$logger" 2>/dev/null || true
  cat "$log"
  exit "$status"
}
trap cleanup EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

wait_for() {
  attempt=0
  until eval "$1"; do
    attempt=$((attempt + 1))
    [ "$attempt" -lt 300 ] || fail "timeout waiting for: $1"
    kill -0 "$runner" 2>/dev/null || fail "container exited while waiting for: $1"
    sleep 0.1
  done
}

interface=$(ip -o route show default | awk '{print $5; exit}')
[ -n "$interface" ] || fail 'no default route interface'

conf=/etc/keepalived/keepalived.conf
vip1=192.0.2.231
vip2=192.0.2.232

export KEEPALIVED_INTERFACE="$interface"
# TEST-NET-1 addresses: the peer never answers, so this node becomes master
export KEEPALIVED_UNICAST_PEERS="192.0.2.250"
export KEEPALIVED_VIRTUAL_IPS="$vip1"
export KEEPALIVED_PASSWORD="t3st"

container --kill-all=false &
runner=$!

# configuration generated from environment variables
wait_for "[ -s $conf ]"
grep -qF "interface $interface" "$conf" || fail 'interface not set in configuration'
grep -qF '192.0.2.250' "$conf" || fail 'unicast peer not set in configuration'
grep -qF 'auth_pass t3st' "$conf" || fail 'password not set in configuration'
grep -qF 'enable_script_security' "$conf" || fail 'script security not enabled'

# keepalived starts, the notify script logs state changes and the virtual IP is set
wait_for "grep -qF 'entered BACKUP state' $log"
wait_for "grep -qF 'entered MASTER state' $log"
wait_for "ip -o addr show dev $interface | grep -qF ' $vip1/'"
if grep -F 'SECURITY VIOLATION' "$log"; then
  fail 'keepalived reports a script security violation'
fi

# hot reload when the configuration changes
sed -i "s/^\( *\)$vip1\$/&\n\1$vip2/" "$conf"
grep -qF "$vip2" "$conf" || fail 'test could not add a virtual IP to the configuration'
wait_for "grep -qF 'Reload complete' $log"
wait_for "ip -o addr show dev $interface | grep -qF ' $vip2/'"

# virtual IPs are removed when the container stops
kill -TERM "$runner"
wait "$runner" || true
runner=
if ip -o addr show dev "$interface" | grep -E " ($vip1|$vip2)/"; then
  fail 'virtual IPs still set after stop'
fi

echo 'keepalived runtime checks: OK'
