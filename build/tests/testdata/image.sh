#!/bin/sh
set -eu

fail() {
  echo "$*" >&2
  exit 1
}

# keepalived starts and all its libraries are installed
keepalived --version
if ldd /usr/local/sbin/keepalived | grep -F 'not found'; then
  fail 'keepalived has missing libraries'
fi

# library loaded with dlopen at runtime
[ -e /usr/lib/libipset.so.13 ] || fail 'missing runtime library: libipset.so.13'

# keepalived runs iptables to detect the firewall backend: without it,
# vrrp_iptables silently sets no rules instead of falling back to nftables
command -v iptables >/dev/null || fail 'missing iptables command'

# optional features enabled at build time
options=$(keepalived --version 2>&1 | grep '^Config options:')
for option in BFD REGEX JSON NFTABLES; do
  echo "$options" | grep -qw "$option" || fail "keepalived built without $option"
done

interface=$(ip -o route show default | awk '{print $5; exit}')
cat > /tmp/keepalived-features.conf <<EOF
bfd_instance BFD_1 {
  neighbor_ip 192.0.2.250
}
vrrp_instance VI_1 {
  interface ${interface:-eth0}
  virtual_router_id 51
  priority 100
  virtual_ipaddress {
    192.0.2.231
  }
  track_bfd {
    BFD_1
  }
}
virtual_server 192.0.2.231 80 {
  lb_algo rr
  lb_kind NAT
  protocol TCP
  real_server 192.0.2.10 80 {
    HTTP_GET {
      url {
        path /health
        regex "^ok$"
      }
    }
  }
}
EOF
keepalived -f /tmp/keepalived-features.conf --config-test || fail 'BFD and HTTP_GET regex configuration rejected'

# packages only needed to build keepalived, or not needed at all
for file in /usr/sbin/snmpd /usr/bin/openssl /usr/bin/file /usr/bin/inotifywait /usr/bin/gcc /usr/bin/make /usr/bin/curl; do
  [ ! -e "$file" ] || fail "unexpected file in image: $file"
done
