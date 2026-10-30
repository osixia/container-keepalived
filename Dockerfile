ARG BASE_IMAGE="osixia/baseimage:alpine-2.0.0"
FROM ${BASE_IMAGE}

ARG IMAGE="osixia/keepalived:develop"
ENV CONTAINER_IMAGE=${IMAGE}

# Keepalived version
ARG KEEPALIVED_VERSION=2.4.3
ARG KEEPALIVED_MD5="5a5c30d3275c380c8cf1a2df67ebbc3c"

# Download and compile keepalived from sources
RUN container packages install --update --clean \
    alpine-sdk \
    autoconf \
    automake \
    curl \
    file-dev \
    gcc \
    ipset \
    ipset-dev \
    iptables \
    iptables-dev \
    libcrypto3 \
    libip4tc \
    libip6tc \
    libmagic \
    libnftnl \
    libnftnl-dev \
    libnl3 \
    libnl3-dev \
    libssl3 \
    linux-headers \
    make \
    musl \
    musl-dev \
    openssl-dev \
    pcre2 \
    pcre2-dev \
    pkgconf \
    && curl -fsSL --proto '=https' --tlsv1.2 -o keepalived.tar.gz https://keepalived.org/software/keepalived-${KEEPALIVED_VERSION}.tar.gz \
    && echo "${KEEPALIVED_MD5}  keepalived.tar.gz" | md5sum -c - \
    && mkdir -p /tmp/keepalived-sources \
    && tar -xzf keepalived.tar.gz --strip 1 -C /tmp/keepalived-sources \
    && cd /tmp/keepalived-sources \
    && (CFLAGS="-O2" ./configure \
        --enable-bfd \
        --enable-json \
        --enable-regex \
        || { cat config.log; exit 1; }) \
    && make -j1 V=1 \
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
    file-dev \
    gcc \
    ipset-dev \
    iptables-dev \
    libnftnl-dev \
    libnl3-dev \
    linux-headers \
    make \
    musl-dev \
    openssl-dev \
    pcre2-dev \
    pkgconf

COPY services /container/services

RUN container services install \
    && container services link

COPY environment /container/environment
