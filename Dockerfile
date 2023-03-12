FROM alpine:edge

LABEL maintainer="n30f0x"
LABEL author="n30f0x, Konrad Kleine <kkleine@redhat.com>"
LABEL description="A distccd image based on alpine based on Konrad Kleine's Fedora 29 version, https://github.com/kwk/distcc-docker-images"
ENV LANG=en_US.utf8

RUN apk add --no-cache \
	clang \
	distcc \
	distcc-pump \
	gcc \
	htop \
	python3 \
	make \
	dbus \
	avahi \
	avahi-dev \
	avahi-compat-libdns_sd  

ENV HOME=~./
# Define how to start distccd by default
# (see "man distccd" for more information)
ENTRYPOINT ["./startup.sh"]

# 3632 is the default distccd port
# 3633 is the default distccd port for getting statistics over HTTP
EXPOSE \
  3632/tcp \
  3633/tcp

# We check the health of the container by checking if the statistics
# are served. (See
# https://docs.docker.com/engine/reference/builder/#healthcheck)
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:3633/ || exit 1
