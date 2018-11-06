FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive
ENV MOTIONEYE_VERSION="0.39.2"

# Install motion, ffmpeg, v4l-utils and the dependencies from the repositories
RUN apt-get update && \
    apt-get -y -f install \
        ffmpeg \
        v4l-utils \
        gdebi-core \
        wget \
        python-pip \
        python-dev \
        curl \
        libssl-dev \
        libcurl4-openssl-dev \
        libjpeg-dev

RUN cd /tmp \
    && wget https://github.com/Motion-Project/motion/releases/download/release-4.2/bionic_motion_4.2-1_amd64.deb \
    && gdebi bionic_motion_4.2-1_amd64.deb

# Install motioneye, which will automatically pull Python dependencies (tornado, jinja2, pillow and pycurl)
RUN pip install motioneye==$MOTIONEYE_VERSION

# Prepare the configuration directory and the media directory
RUN mkdir -p /etc/motioneye \
    mkdir -p /var/lib/motioneye

# Configurations, Video & Images
VOLUME ["/etc/motioneye", "/var/lib/motioneye"]

# clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Start the MotionEye Server
CMD test -e /etc/motioneye/motioneye.conf || \
    cp /usr/local/share/motioneye/extra/motioneye.conf.sample /etc/motioneye/motioneye.conf ; \
    /usr/local/bin/meyectl startserver -c /etc/motioneye/motioneye.conf

EXPOSE 8765