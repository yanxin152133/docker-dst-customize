FROM ubuntu:18.04

RUN sed -i "s@http://.*archive.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list \
    && sed -i "s@http://.*security.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list

RUN set -x \
    && dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests libstdc++6:i386 \
        libgcc1:i386 \
        lib32gcc1 \
        lib32stdc++6 \
        libcurl4-gnutls-dev:i386 \
        wget \
        ca-certificates \
        vim \
    && mkdir -p /root/DST \
    && mkdir -p /root/steamcmd \
    && cd /root/steamcmd \
    && wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -zxvf steamcmd_linux.tar.gz \
    && ./steamcmd.sh \
        +login anonymous \
        +force_install_dir /root/DST \
        +app_update 343050  validate \
        +quit \
    && apt-get remove --purge -y wget \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN cd /root/DST/bin \
    && echo "/root/steamcmd/steamcmd.sh +@ShutdownOnFailedCommand 1 +@NoPromptForPassword 1 +login anonymous +force_install_dir /root/DST +app_update 343050 +quit" > start.sh \
    && echo "/root/DST/bin/dontstarve_dedicated_server_nullrenderer -only_update_server_mods" >> start.sh \
    && echo "/root/DST/bin/dontstarve_dedicated_server_nullrenderer -shard Master & /root/DST/bin/dontstarve_dedicated_server_nullrenderer -shard Caves" >> start.sh \
    && chmod +x start.sh

VOLUME /root/.klei/DoNotStarveTogether/Cluster_1
VOLUME /root/DST/mods

EXPOSE 10889/udp
EXPOSE 10999/udp
EXPOSE 10998/udp

WORKDIR /root/DST/bin
CMD "/root/DST/bin/start.sh"
