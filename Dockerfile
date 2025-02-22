FROM ghcr.io/linuxserver/baseimage-alpine:3.15

ARG UNRAR_VERSION=6.1.4
ARG BUILD_DATE
ARG VERSION
ARG TRANSMISSION_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --upgrade --virtual=build-dependencies \
    make \
    g++ \
    gcc && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    ca-certificates \
    curl \
    findutils \
    jq \
    openssl \
    p7zip \
    python3 \
    rsync \
    tar \
    transmission-cli \
    transmission-daemon \
    unzip && \
  echo "**** install transmission ****" && \
  apk add --no-cache \
    transmission-cli \
    transmission-daemon && \
  echo "**** install unrar from source ****" && \
  mkdir /tmp/unrar && \
  curl -o \
    /tmp/unrar.tar.gz -L \
    "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" && \  
  tar xf \
    /tmp/unrar.tar.gz -C \
    /tmp/unrar --strip-components=1 && \
  cd /tmp/unrar && \
  make && \
  install -v -m755 unrar /usr/local/bin && \
  echo "**** install third party themes ****" && \
  TRANSMISSIONIC_VERSION=$(curl -s "https://api.github.com/repos/6c65726f79/Transmissionic/releases/latest" | jq -r .tag_name) && \
  curl -o \
    /tmp/transmissionic.zip -L \
    "https://github.com/6c65726f79/Transmissionic/releases/download/${TRANSMISSIONIC_VERSION}/Transmissionic-webui-${TRANSMISSIONIC_VERSION}.zip" && \
  unzip \
    /tmp/transmissionic.zip -d \
    /tmp && \
  mv /tmp/web /transmissionic && \
  curl -o \
    /tmp/combustion.zip -L \
    "https://github.com/Secretmapper/combustion/archive/release.zip" && \
  unzip \
    /tmp/combustion.zip -d \
    / && \
  mkdir -p /tmp/twctemp && \
  TWCVERSION=$(curl -s "https://api.github.com/repos/ronggang/transmission-web-control/releases/latest" | jq -r .tag_name) && \
  curl -o \
    /tmp/twc.tar.gz -L \
    "https://github.com/ronggang/transmission-web-control/archive/${TWCVERSION}.tar.gz" && \
  tar xf \
    /tmp/twc.tar.gz -C \
    /tmp/twctemp --strip-components=1 && \
  mv /tmp/twctemp/src /transmission-web-control && \
  # Enables the original UI button in transmission-web-control
  ln -s /usr/share/transmission/web/style /transmission-web-control && \
  ln -s /usr/share/transmission/web/images /transmission-web-control && \
  ln -s /usr/share/transmission/web/javascript /transmission-web-control && \
  ln -s /usr/share/transmission/web/index.html /transmission-web-control/index.original.html && \
  mkdir -p /kettu && \
  curl -o \
    /tmp/kettu.tar.gz -L \
    "https://github.com/endor/kettu/archive/master.tar.gz" && \
  tar xf \
    /tmp/kettu.tar.gz -C \
    /kettu --strip-components=1 && \
  curl -o \
    /tmp/flood-for-transmission.tar.gz -L \
    "https://github.com/johman10/flood-for-transmission/releases/download/latest/flood-for-transmission.tar.gz" && \
  tar xf \
    /tmp/flood-for-transmission.tar.gz -C \
    / && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9091 51413/tcp 51413/udp
VOLUME /config
