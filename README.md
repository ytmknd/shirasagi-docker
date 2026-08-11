# README

Powered by shirasagi (https://github.com/shirasagi/shirasagi)

## Tested environment

* Host: macOS 26.6.1 (Apple Silicon / ARM64)
* Docker Desktop 29.7.2
* SHIRASAGI container: Debian 12 (bookworm)
* MongoDB container: Ubuntu 24.04 LTS (noble)
* Nginx container: Debian 13 (trixie)

## Runtime versions

* Ruby 4.0.6 / Rails 8.1.3.1 / Puma 8.0.2 / Bundler 4.0.16
* Node.js 24.18.0 / Yarn 1.22.22
* Nginx 1.30.4
* MongoDB 8.0.26

## Install
Checkout this git repo.

`$ git clone https://github.com/ytmknd/shirasagi-docker.git`

Build ruby image.

`$ bash build.sh`

## Secret key setup

Create a local `.env` file before starting the containers. The `.env` file is
ignored by Git and must not be committed.

```sh
cp .env.example .env
openssl rand -hex 64
```

Set the generated value as `SECRET_KEY_BASE` in `.env`. Docker Compose refuses
to start the SHIRASAGI service when the value is missing or empty.

## Optional: Change settings

If use https, unccoment and edit <<your.domain>> docker-compose.yml.
and remove ports section in nginx service.

```
  # https-portal:
  #   image: steveltn/https-portal:1
  #   container_name: shirasagi_https-portal
  #   ports:
  #     - '80:80'
  #     - '443:443'
  #   environment:
  #     DOMAINS: >-
  #       your.domain -> http://nginx
  #     # STAGE: 'production' # Don't use production until staging works
  #     WORKER_PROCESSES: auto
  #     WORKER_CONNECTIONS: 2048
  #     CLIENT_MAX_BODY_SIZE: '128M'
  #   depends_on:
  #     - nginx
  #   volumes:
  #     - ./certs:/var/lib/https-portal
  #   restart: always
```


## Run

Wakeup docker container.

`$ sudo docker compose up -d`

Existing MongoDB 4.4 volumes must be upgraded one major version at a time before
starting this Compose configuration. See
[MongoDB 4.4 to 8.0 upgrade](docs/mongodb-4.4-to-8.0.md).

_**Attention**_

*The gem is built when the system is first started (including rebuilds).

*The build process takes a considerable amount of time.

After the build is finished, access the following URL with a browser

< http://localhost/.mypage/login >


## Initial User Add

After confirming that the URL is accessible, register an administrative user.

1:
`$ sudo docker compose exec -it shirasagi /bin/bash`

2:
`$ cd /var/www/shirasagi`

3:
`$ rake ss:create_user data='{ name: "システム管理者", email: "sys@example.jp", password: "pass" }'`

## Notes

*The Nginx port number specified in docker-compose.yml must be consistent across hosts and containers.
