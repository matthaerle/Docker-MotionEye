# MotionEye
FROM alpine:latest

ENV MOTIONEYE_VERSION="0.39.2"

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories\
&&  apk --no-cache add\
    bash\
    motion\
    py2-pip\
    python\
    curl\
    openssl\
    tzdata\
&&  apk --no-cache add --virtual=buildreq\
    build-base\
    curl-dev\
    jpeg-dev\
    libressl-dev\
    python-dev\
    zlib-dev

# latest pip
RUN pip install --upgrade pip

# Install motioneye, which will automatically pull Python dependencies (tornado, jinja2, pillow and pycurl)
RUN pip install motioneye==$MOTIONEYE_VERSION

# Prepare the configuration directory and the media directory
RUN mkdir -p /etc/motioneye \
    mkdir -p /var/lib/motioneye

# Configurations, Video & Images
VOLUME ["/etc/motioneye", "/var/lib/motioneye"]

# Start the MotionEye Server
CMD test -e /etc/motioneye/motioneye.conf || \
    cp /usr/local/share/motioneye/extra/motioneye.conf.sample /etc/motioneye/motioneye.conf ; \
    /usr/local/bin/meyectl startserver -c /etc/motioneye/motioneye.conf

EXPOSE 8765
