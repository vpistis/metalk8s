FROM centos:7

ENV LANG=en_US.utf8
ENV CYPRESS_CACHE_FOLDER=/home/node/.cache

RUN curl -sL https://rpm.nodesource.com/setup_16.x | bash -
RUN yum install -y --setopt=skip_missing_names_on_install=False \
        epel-release \
        && \
    yum install -y --setopt=skip_missing_names_on_install=False \
        git \
        nginx \
        nodejs

COPY standalone-nginx.conf /etc/nginx/conf.d/default.conf
RUN rm -rf /usr/share/nginx/html/*

# UI build (cannot use build stages for now) {{{

RUN adduser -u 1000 --home /home/node node

#USER node
WORKDIR /home/node

COPY package.json package-lock.json /home/node/

RUN npm config set unsafe-perm true && npm ci
# CP libstdc++.so.6 to /lib64 to workarround https://github.com/Automattic/node-canvas/issues/1796
RUN cp node_modules/canvas/build/Release/libstdc++.so.6 /lib64

COPY .babelrc webpack.common.js webpack.prod.js /home/node/
COPY public /home/node/public/
COPY src /home/node/src/

RUN npm run build

#USER root

# }}}

RUN shopt -s dotglob && cp -r build/* /usr/share/nginx/html/

CMD ["nginx", "-g", "daemon off;"]
