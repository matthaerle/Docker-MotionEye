# MotionEye
FROM alpine:latest

ENV MOTIONEYE_VERSION="0.39.2"

RUN apk add --no-cache python3-dev && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories\
&&  apk --no-cache add\
    bash\
    gifsicle \
    motion\
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
