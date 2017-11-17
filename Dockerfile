FROM alpine:3.3
MAINTAINER J Hawkins <printgeek@gmail.com>

ENV FFMPEG_VERSION 3.4
ENV COMSKIP_VERSION 0.82.003

# Get Build deps
RUN apk update && apk add \
  gcc binutils-libs binutils build-base libgcc make pkgconf pkgconfig \
  openssl openssl-dev ca-certificates pcre autoconf automake libtool \
  musl-dev libc-dev pcre-dev zlib-dev
  
# Install Comskip
RUN cd /tmp && wget http://prdownloads.sourceforge.net/argtable/argtable2-13.tar.gz
RUN cd /tmp && tar zxf argtable2-13.tar.gz && rm argtable2-13.tar.gz
RUN cd /tmp/argtable2-13 && ./configure && make && make install && make clean

RUN cd /tmp && wget https://github.com/erikkaashoek/Comskip/archive/v${COMSKIP_VERSION}.tar.gz \
 && tar zxf v${COMSKIP_VERSION}.tar.gz && rm v${COMSKIP_VERSION}.tar.gz
RUN cd /tmp/Comskip-${COMSKIP_VERSION} \
 && ./autogen.sh \
 && ./configure \
 && make && make install && make distclean

RUN mkdir -p /opt/PlexComskip && cd /opt/PlexComskip && \
    wget https://raw.githubusercontent.com/ekim1337/PlexComskip/master/PlexComskip.py && \
    wget https://raw.githubusercontent.com/ekim1337/PlexComskip/master/comskip.ini && \ 
    touch /var/log/PlexComskip.log

RUN apk add --update nasm yasm-dev lame-dev libogg-dev x264-dev libvpx-dev libvorbis-dev x265-dev freetype-dev libass-dev libwebp-dev rtmpdump-dev libtheora-dev opus-dev
RUN echo http://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
RUN apk add --update fdk-aac-dev

# Get ffmpeg source.
RUN cd /tmp/ && wget http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz \
  && tar zxf ffmpeg-${FFMPEG_VERSION}.tar.gz && rm ffmpeg-${FFMPEG_VERSION}.tar.gz

# Compile ffmpeg.
RUN cd /tmp/ffmpeg-${FFMPEG_VERSION} && \
  ./configure \
  --enable-version3 \
  --enable-gpl \
  --enable-nonfree \
  --enable-small \
  --enable-libmp3lame \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libvpx \
  --enable-libtheora \
  --enable-libvorbis \
  --enable-libopus \
  --enable-libfdk-aac \
  --enable-libass \
  --enable-libwebp \
  --enable-librtmp \
  --enable-postproc \
  --enable-avresample \
  --enable-libfreetype \
  --enable-openssl \
  --disable-debug \
  && make && make install && make distclean
  
RUN rm -rf /var/cache/* /tmp/*

VOLUME /opt/PlexComskip

COPY PlexComskip.conf /opt/PlexComskip/PlexComskip.conf

CMD ["/opt/PlexComskip/PlexComskip.py"]  
