# MongoDB 4.4 to 8.0 upgrade

MongoDB data files cannot be upgraded directly from 4.4 to 8.0. Upgrade the
same stopped volume through 5.0, 6.0, 7.0, and 8.0, setting the feature
compatibility version (FCV) at every stage.

The commands below assume the default Compose project name and therefore the
volume `shirasagi-docker_dbdata`. Confirm the exact volume name with
`docker volume ls` before running them.

## 1. Stop and back up

Stop all writers before taking the physical backup:

```sh
docker compose stop
mkdir -p backups
docker run --rm \
  --mount source=shirasagi-docker_dbdata,target=/data,readonly \
  --mount type=bind,src="$PWD/backups",dst=/backup \
  busybox:1.37 \
  tar czf /backup/mongodb-4.4-pre-upgrade.tgz -C /data .
```

Optionally start 4.4 once more and take a logical `mongodump` archive as a
second recovery path. Stop it cleanly before continuing.

## 2. Upgrade to MongoDB 5.0

```sh
docker run --rm -d --name shirasagi-mongo-upgrade-5 \
  --mount source=shirasagi-docker_dbdata,target=/data/db \
  mongo:5.0.31 --wiredTigerCacheSizeGB=1
docker exec shirasagi-mongo-upgrade-5 mongo --quiet \
  --eval 'db.adminCommand({setFeatureCompatibilityVersion: "5.0"})' admin
docker exec shirasagi-mongo-upgrade-5 mongo --quiet \
  --eval 'db.adminCommand({getParameter: 1, featureCompatibilityVersion: 1})' admin
docker stop shirasagi-mongo-upgrade-5
```

## 3. Upgrade to MongoDB 6.0

```sh
docker run --rm -d --name shirasagi-mongo-upgrade-6 \
  --mount source=shirasagi-docker_dbdata,target=/data/db \
  mongo:6.0.28 --wiredTigerCacheSizeGB=1
docker exec shirasagi-mongo-upgrade-6 mongosh --quiet \
  --eval 'db.adminCommand({setFeatureCompatibilityVersion: "6.0"})' admin
docker exec shirasagi-mongo-upgrade-6 mongosh --quiet \
  --eval 'db.adminCommand({getParameter: 1, featureCompatibilityVersion: 1})' admin
docker stop shirasagi-mongo-upgrade-6
```

## 4. Upgrade to MongoDB 7.0

```sh
docker run --rm -d --name shirasagi-mongo-upgrade-7 \
  --mount source=shirasagi-docker_dbdata,target=/data/db \
  mongo:7.0.37 --wiredTigerCacheSizeGB=1
docker exec shirasagi-mongo-upgrade-7 mongosh --quiet \
  --eval 'db.adminCommand({setFeatureCompatibilityVersion: "7.0", confirm: true})' admin
docker exec shirasagi-mongo-upgrade-7 mongosh --quiet \
  --eval 'db.adminCommand({getParameter: 1, featureCompatibilityVersion: 1})' admin
docker stop shirasagi-mongo-upgrade-7
```

## 5. Upgrade to MongoDB 8.0

```sh
docker run --rm -d --name shirasagi-mongo-upgrade-8 \
  --mount source=shirasagi-docker_dbdata,target=/data/db \
  mongo:8.0.26 --wiredTigerCacheSizeGB=1
docker exec shirasagi-mongo-upgrade-8 mongosh --quiet \
  --eval 'db.adminCommand({setFeatureCompatibilityVersion: "8.0", confirm: true})' admin
docker exec shirasagi-mongo-upgrade-8 mongosh --quiet \
  --eval 'db.adminCommand({getParameter: 1, featureCompatibilityVersion: 1})' admin
docker stop shirasagi-mongo-upgrade-8
```

Start the final Compose service and verify FCV and the application connection:

```sh
docker compose up -d mongodb
docker compose exec mongodb mongosh --quiet \
  --eval 'db.adminCommand({getParameter: 1, featureCompatibilityVersion: 1})' admin
docker compose up -d
```

## Restore

If a stage fails, stop MongoDB, create a new empty volume, and restore either
the logical archive with `mongorestore` or the stopped physical backup. Never
extract the physical archive over a running MongoDB process. Retain the backup
until application-level verification is complete.
