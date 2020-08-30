FROM curlimages/curl:7.72.0 AS download

WORKDIR /tmp
RUN curl https://mega.nz/linux/MEGAsync/Debian_10.0/megacmd_1.3.0.orig.tar.gz --output megacmd.tar.gz

FROM busybox:1.32.0 AS builder

WORKDIR /tmp
COPY --from=download "/tmp/megacmd.tar.gz" "megacmd.tar.gz"
RUN md5sum megacmd.tar.gz
RUN echo "7c1680135a53a47c8d43e2cedbbc5137  megacmd.tar.gz" > megacmd.md5 \
    && md5sum -c megacmd.md5 \
    && tar -xvf megacmd.tar.gz

FROM debian:buster-slim

# Define labels
LABEL maintainer="lakatos.martin@gmail.com"
LABEL source_code="https://github.com/luckychap/docker-debian-megacmd"

# Install all dependecies
# https://github.com/meganz/MEGAcmd#requirements
RUN apt update -y \
    && apt install -y --no-install-recommends \
       libcrypto++ libpcrecpp0v5 libc-ares-dev zlib1g-dev libuv1 libssl-dev libsodium-dev readline-common sqlite3 curl automake make libtool g++ libcrypto++-dev libz-dev libsqlite3-dev libssl-dev libcurl4-gnutls-dev libreadline-dev libpcre++-dev libsodium-dev libc-ares-dev libfreeimage-dev libavcodec-dev libavutil-dev libavformat-dev libswscale-dev libmediainfo-dev libzen-dev \
    && rm -rf /var/lib/apt/lists/* \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && apt clean

# Get install pakage
COPY --from=builder "/tmp/megacmd*/*" "/tmp/"

# Install megacmd and clean after
RUN cd /tmp/ \
    && sh autogen.sh \
    && ./configure \
    && make \
    && make install \
    && rm -fr /tmp/*

# define command
CMD [ "megacli" ]
