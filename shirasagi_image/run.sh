#!/bin/bash

cd /var/www/shirasagi

# It takes a considerable amount of time.
bundle config set --local without 'development test'
bundle config set --local path 'vendor/bundle'
bundle install

# Puma is the currently supported application server in SHIRASAGI. Keep it in
# the foreground so Docker can supervise the real server process.
export RAILS_ENV="${RAILS_ENV:-production}"
export WEB_CONCURRENCY="${WEB_CONCURRENCY:-2}"
exec bundle exec puma -C config/samples/puma.rb -w "$WEB_CONCURRENCY"
