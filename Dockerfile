FROM  ubuntu:20.04

LABEL maintainer="n30f0x"
LABEL author="n30f0x"
LABEL description="A distccd image with zeroconf"

# general environment
ENV LANG=en_US.utf8
ENV USER=distcc
ENV UID=12345
ENV GID=23456

# update packages
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
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
  pkg-config \
  avahi-daemon \
  dmucs \
  ccache \
  lsb-base \
  libpopt0 \
  libc6 \
  avahi-discover \
  avahi-utils \
  libavahi-common-dev \
  libiberty-dev \
  libnss-mdns \
  libkrb5-dev \
  libgssapi-krb5-2 \
  htop \
  wget

# patch out service
# RUN rm /etc/avahi/services/*
RUN sed -i 's/.*enable-dbus=.*/enable-dbus=no/' /etc/avahi/avahi-daemon.conf

# build distcc from source
WORKDIR /temp/
RUN wget -4 https://github.com/distcc/distcc/archive/refs/tags/v3.4.tar.gz
RUN tar -zxvf v3.4.tar.gz
WORKDIR distcc-3.4/
RUN sed -i 's@sys/poll.h@poll.h@g' src/zeroconf-reg.c
RUN ./autogen.sh
RUN ./configure --with-auth=yes --enable-rfc2553=yes --enable-profile=yes 
# --with-avahi doesn't exist here, took me a while to figure out
RUN make -i
RUN make install clean -i
RUN update-distcc-symlinks


# build nss-mdns if needed, pure pain in arse
# WORKDIR /temp/
# RUN wget -4 https://github.com/lathiat/nss-mdns/archive/refs/tags/v0.15.1.tar.gz
# RUN tar -zxvf v0.15.1.tar.gz
# WORKDIR nss-mdns-0.15.1/
# RUN autoreconf -i
# RUN ./configure
# RUN make -i
# RUN make install
# poettering sucks btw

# make distcc masquarade
RUN adduser \
 --disabled-password \
    --gecos "" \
    --home "$(pwd)" \
    --no-create-home \
    --uid "$UID" \
    "$USER"

# idk why this is needed, i just seen examples
VOLUME ["/etc/avahi/services"]
# VOLUME ["/etc/default/distcc"]

# run needed service
RUN service avahi-daemon restart

# attempt to patch out zeroconf
RUN sed -i 's@ZEROCONF="false"@ZEROCONF="true"@g' /etc/default/distcc
# RUN cat /etc/default/distcc

# general entrypoint, proceed with caution
ENTRYPOINT [\
  "distccd", \
  "--daemon", \
  "--verbose", \
  "--make-me-a-botnet", \
 # "-j", "12", \
  "--port", "3632", \
  "--stats", \
  "--stats-port", "3633", \
  "--log-stderr", \
  "--allow-private", \
 # "--allow", "0.0.0.0", \
 # "--listen", "0.0.0.0" \
  "--no-detach"]
 # "--zeroconf", \ # for some unknown reason option doesn't actually exist?! ffs
 # "--log-level", "debug", \

# ports for distcc, distcc monitor and avahi
EXPOSE \
  3632/tcp \
  3633/tcp \
  5353

# general healthcheck
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:3633/ || exit 1
