FROM nixos/nix
LABEL maintainer="n30f0x"
LABEL author="n30f0x"
LABEL description="A distccd image with zeroconf"

RUN nix-channel --update

RUN nix-env -iA nixpkgs.distcc

# general entrypoint, proceed with caution
ENTRYPOINT [\
 "nix", "run", \
 "distcc", \
 "--daemon", \
 "--make-me-a-botnet", \
 "--verbose", \
# "-j", "12", \
 "--port", "3632", \
 "--stats", \
 "--stats-port", "3633", \
 "--log-stderr", \
# "--allow-private", \
  "--allow", "192.168.0.0/24" \
# "--listen", "0.0.0.0", \
# "--no-detach", \
# "--zeroconf", \ 
# "--log-level", "debug", \
]

# ports for distcc, distcc monitor and avahi
EXPOSE \
  3632/tcp \
  3633/tcp 
  
#  5353

# general healthcheck
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:3633/ || exit 1
