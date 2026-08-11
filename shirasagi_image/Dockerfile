ARG NODE_VERSION=24.18.0
ARG RUBY_VERSION=4.0.6
ARG BUNDLER_VERSION=4.0.16

FROM node:${NODE_VERSION}-bookworm-slim AS node

FROM ruby:${RUBY_VERSION}-slim-bookworm
ARG BUNDLER_VERSION
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN apt-get update && apt-get -y install \
    imagemagick \
    libmagickcore-dev \
    libmagickwand-dev \
    gnupg2 \
    wget \
    curl \
    git \
    make \
    g++ \
    xz-utils \
    pkg-config \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    mecab \
    libmecab-dev \
    mecab-ipadic-utf8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && npm install --global yarn@1.22.22
RUN gem install bundler --version ${BUNDLER_VERSION} --no-document
RUN bundle config set --global force_ruby_platform true

# エントリーポイント作成
# RUN echo '#!/bin/bash\nexec /bin/bash -l -c "$*"' > /entrypoint.sh && chmod +x /entrypoint.sh
# ENTRYPOINT ["/entrypoint.sh"]
