# MotionEye
FROM alpine:latest

ENV MOTIONEYE_VERSION="0.39.2"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories\
&&  apk --no-cache add\
    bash\
    gifsicle \
    motion\
    curl\
    py2-pip\
    python\
    openssl\
    tzdata\
&&  apk --no-cache add --virtual=buildreq\
    build-base\
    curl-dev\
    jpeg-dev\
    libressl-dev\
    python-dev\
    zlib-dev

# Install motioneye, which will automatically pull Python dependencies (tornado, jinja2, pillow and pycurl)
RUN pip install motioneye==$MOTIONEYE_VERSION

ENV FFMPEG_VERSION="4.1"
ENV FFMPEG_VERSION_URL="http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.bz2"
ENV BIN="/usr/bin"

RUN cd && \
apk update && \
apk upgrade && \
apk add \
  freetype-dev \
  gnutls-dev \
  lame-dev \
  libass-dev \
  libogg-dev \
  libtheora-dev \
  libvorbis-dev \ 
  libvpx-dev \
  libwebp-dev \ 
  libssh2 \
  opus-dev \
  rtmpdump-dev \
  x264-dev \
  x265-dev \
  yasm-dev && \
apk add --no-cache --virtual \ 
  .build-dependencies \ 
  build-base \ 
  bzip2 \ 
  coreutils \ 
  gnutls \ 
  nasm \ 
  tar \ 
  x264 && \
DIR=$(mktemp -d) && \
cd "${DIR}" && \
wget "${FFMPEG_VERSION_URL}" && \
tar xjvf "ffmpeg-${FFMPEG_VERSION}.tar.bz2" && \
cd ffmpeg* && \
PATH="$BIN:$PATH" && \
./configure --help && \
./configure --bindir="$BIN" --disable-debug \
  --disable-doc \ 
  --disable-ffplay \ 
  --enable-avresample \ 
  --enable-gnutls \
  --enable-gpl \ 
  --enable-libass \ 
  --enable-libfreetype \ 
  --enable-libmp3lame \ 
  --enable-libopus \ 
  --enable-librtmp \ 
  --enable-libtheora \ 
  --enable-libvorbis \ 
  --enable-libvpx \ 
  --enable-libwebp \ 
  --enable-libx264 \ 
  --enable-libx265 \ 
  --enable-nonfree \ 
  --enable-postproc \ 
  --enable-small \ 
  --enable-version3 && \
make -j4 && \
make install && \
make distclean && \
rm -rf "${DIR}"  && \
apk del --purge .build-dependencies && \
rm -rf /var/cache/apk/* 

# Prepare the configuration directory and the media directory
RUN mkdir -p /etc/motioneye \
    mkdir -p /var/lib/motioneye

# Configurations, Video & Images
VOLUME ["/etc/motioneye", "/var/lib/motioneye"]

# Start the MotionEye Server
CMD test -e /etc/motioneye/motioneye.conf || \
    cp /usr/share/motioneye/extra/motioneye.conf.sample /etc/motioneye/motioneye.conf ; \
    /usr/bin/meyectl startserver -c /etc/motioneye/motioneye.conf

EXPOSE 8765
