ARG BASE_IMAGE="osixia/baseimage:alpine-2.0.0-alpha2"
FROM ${BASE_IMAGE}

ARG IMAGE="osixia/keepalived:develop"
ENV CONTAINER_IMAGE=${IMAGE}

# Keepalived version
ARG KEEPALIVED_VERSION=2.3.4

# Download and compile keepalived from sources
RUN container packages install --update --clean \
    alpine-sdk \
    autoconf \
    automake \
    curl \
    file \
    file-dev \
    gcc \
    inotify-tools \
    ipset \
    ipset-dev \
    iptables \
    iptables-dev \
    libip4tc \
    libip6tc \
    libnftnl \
    libnftnl-dev \
    libnl3 \
    libnl3-dev \
    linux-headers \
    make \
    musl \
    musl-dev \
    net-snmp \
    net-snmp-dev \
    openssl \
    openssl-dev \
    pcre2 \
    pcre2-dev \
    pkgconf \
    && curl -o keepalived.tar.gz -SL https://keepalived.org/software/keepalived-${KEEPALIVED_VERSION}.tar.gz \
    && mkdir -p /tmp/keepalived-sources \
    && tar -xzf keepalived.tar.gz --strip 1 -C /tmp/keepalived-sources \
    && cd /tmp/keepalived-sources \
    && ./configure \
    && CFLAGS="-O0" CXXFLAGS="-O0" make -j1 \
    && make install \
    && cd - \
    && rm -rf keepalived.tar.gz \
    /tmp/keepalived-sources \
    /usr/local/etc/keepalived/samples \
    /usr/local/share/doc/keepalived \
    /etc/keepalived/keepalived.conf.sample\
    && container packages remove \
    alpine-sdk \
    autoconf \
    automake \
    curl \
    file-dev \
    gcc \
    ipset-dev \
    iptables-dev \
    libnftnl-dev \
    libnl3-dev \
    linux-headers \
    make \
    musl-dev \
    net-snmp-dev \
    openssl-dev \
    pcre2-dev \
    pkgconf

COPY services /container/services

RUN container services install \
    && container services link

COPY environment /container/environment
