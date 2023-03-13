FROM alpine:edge

LABEL maintainer="n30f0x"
LABEL author="n30f0x"
LABEL description="A distccd image based on alpine"
ENV LANG=en_US.utf8
ENV USER=distcc
ENV UID=12345
ENV GID=23456

RUN apk add --no-cache \
  clang \
  gcc \
  g++ \
  make \
  binutils-dev \
  python3-dev \
  autoconf \
  automake \
  m4 \
  libtool \
  pkgconfig \
  avahi \
  avahi-dev \
  avahi-compat-libdns_sd \
  avahi-tools \
  musl-nscd-dev \
  gcompat \
  dbus \
  htop \
  wget
  

# RUN rm /etc/avahi/services/*
# RUN sed -i 's/.*enable-dbus=.*/enable-dbus=no/' /etc/avahi/avahi-daemon.conf
WORKDIR /temp/
RUN wget -4 https://github.com/distcc/distcc/archive/refs/tags/v3.4.tar.gz
RUN tar -zxvf v3.4.tar.gz
WORKDIR distcc-3.4/
RUN sed -i 's@sys/poll.h@poll.h@g' src/zeroconf-reg.c
RUN ./autogen.sh
RUN ./configure --with-avahi
RUN make -i
RUN make install clean
RUN update-distcc-symlinks

RUN adduser \
 --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --no-create-home \
    --uid "$UID" \
    "$USER"

WORKDIR /temp/

RUN wget -4 https://github.com/lathiat/nss-mdns/archive/refs/tags/v0.15.1.tar.gz
RUN tar -zxvf v0.15.1.tar.gz
WORKDIR nss-mdns-0.15.1/
RUN autoreconf -i
RUN ./configure
RUN make -i
RUN make install

RUN avahi-daemon -D

ENTRYPOINT [\
  "distccd", \
  "--daemon", \
  "--port", "3632", \
  "--stats", \
  "--stats-port", "3633", \
  "--log-stderr", \
  "--allow", "0.0.0.0", \
  "--zeroconf", \
  "--no-detach"]
 # "--log-level", "debug", \


VOLUME ["/etc/avahi/services"]

EXPOSE \
  3632/tcp \
  3633/tcp \
  5353

HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:3633/ || exit 1
