FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl openbox xterm chromium fonts-liberation ffmpeg \
      x11-xserver-utils dbus-x11 procps \
 && curl -fsSL -o /tmp/kasm.deb https://github.com/kasmtech/KasmVNC/releases/download/v1.5.2/kasmvncserver_debian_bookworm_1.5.2_amd64.deb \
 && apt-get install -y --no-install-recommends /tmp/kasm.deb \
 && rm -rf /tmp/kasm.deb /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -G ssl-cert user
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER user
ENV HOME=/home/user
EXPOSE 6901
CMD ["/entrypoint.sh"]
