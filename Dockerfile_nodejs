FROM jenkinsci/slave

ENV NODE_VERSION 12.6.0
ENV NODE_ARCH x64

USER root

RUN echo "Installing dependencies" && \
    apt-get -y update && \
    apt-get -y install jq lxc libltdl7 && \
    apt-get clean

RUN echo "Installing Node.JS" && \
    curl-LO https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz && \
    tar -xJf node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz -C /usr/local --strip-components=1 && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs && \
    rm node-v$NODE_VERSION-linux-$NODE_ARCH.tar.xz
RUN echo "Installing Yarn" && \
    npm install -g yarn

