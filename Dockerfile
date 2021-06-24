# ---- Build user sync ----
FROM rust:1-buster as user-sync-build

RUN cargo install --git https://github.com/lunix33/user-sync.git --branch main --root /build/user-sync

# ---- Build Pulseaudio XRDP module ----
FROM debian:buster as pulseaudio-rdp-build

ENV DEBIAN_FRONTEND noninteractive

COPY build/common.sh /tmp/
COPY build/pa-sink.sh /tmp/

RUN ["/bin/bash", "/tmp/common.sh"]
RUN ["/bin/bash", "/tmp/pa-sink.sh"]

# ---- Main image ----
FROM debian:buster as main

ENV DEBIAN_FRONTEND noninteractive

COPY opt/ /opt/
COPY etc/profile.d/ /etc/profile.d/
COPY etc/supervisor/conf.d/ /etc/supervisor/conf.d/

COPY build.sh /tmp/
RUN ["/bin/bash", "/tmp/build.sh"]

COPY --from=user-sync-build /build/ /opt/
COPY --from=pulseaudio-rdp-build /build/pulse/ /var/lib/xrdp-pulseaudio-installer

EXPOSE 3389/tcp

ENTRYPOINT [ "/opt/docker-entrypoint.sh" ]
CMD [ "supervisord" ]
