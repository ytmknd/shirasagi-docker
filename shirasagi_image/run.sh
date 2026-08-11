#!/bin/bash

cd /var/www/shirasagi

# It takes a considerable amount of time.
bundle config set --local without 'development test'
bundle config set --local path 'vendor/bundle'
bundle install

# Launch
rm -f /var/www/shirasagi/tmp/pids/unicorn.pid
bundle exec rake unicorn:start

# Do not terminate
bash
