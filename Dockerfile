FROM lsiobase/alpine.python:3.7

# set version label
ARG BUILD_DATE
ARG VERSION
ARG HEADPHONES_COMMIT
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"

# copy patches folder
COPY patches/ /tmp/patches/

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	g++ \
	gcc \
	make && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	ffmpeg \
	flac \
	mc && \
 echo "**** compile shntool *** *" && \
 mkdir -p \
	/tmp/shntool && \
 tar xf /tmp/patches/shntool-3.0.10.tar.gz -C \
	/tmp/shntool --strip-components=1 && \
 cp /tmp/patches/config.* /tmp/shntool && \
 cd /tmp/shntool && \
 ./configure \
	--infodir=/usr/share/info \
	--localstatedir=/var \
	--mandir=/usr/share/man \
	--prefix=/usr \
	--sysconfdir=/etc && \
 make && \
 make install && \
 echo "**** install app ****" && \
 mkdir -p \
  /app/headphones && \
 curl -o \
 /tmp/headphones.tar.gz -L \
	"https://github.com/rembo10/headphones/archive/${HEADPHONES_COMMIT}.tar.gz" && \
 tar xf \
 /tmp/headphones.tar.gz -C \
	/app/headphones --strip-components=1 && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/* \
	/usr/lib/*.la

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8181
VOLUME /config /downloads /music
