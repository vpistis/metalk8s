FROM centos:7

ARG BUILDBOT_VERSION=2.0.1

ENV LANG=en_US.utf8
ENV CYPRESS_CACHE_FOLDER=/home/eve/.cache

RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash -
RUN yum install -y --setopt=skip_missing_names_on_install=False \
    epel-release \
    && yum install -y --setopt=skip_missing_names_on_install=False \
    gcc \
    sudo \
    python36 \
    python36-devel \
    python36-pip \
    git \
    nodejs \
    alsa-lib \
    gtk3 \
    libXtst \
    libXScrnSaver \
    xorg-x11-server-Xvfb \
    && adduser -u 1042 --home /home/eve eve \
    && chown -R eve:eve /home/eve \
    && python3.6 -m pip install buildbot-worker==${BUILDBOT_VERSION}

# Add eve to sudoers.
RUN echo "eve ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/eve

USER eve

# Installing dependencies to generate a re-usable cache under /home/eve/.npm
WORKDIR /tmp
COPY package.json package-lock.json ./
RUN npm ci
# CP libstdc++.so.6 to /lib64 to workarround https://github.com/Automattic/node-canvas/issues/1796
RUN cp node_modules/canvas/build/Release/libstdc++.so.6 /lib64

WORKDIR /home/eve/workspace/
