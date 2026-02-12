#!/bin/sh

export $(grep -v '^#' .env | xargs)

docker run --rm \
  -e POSTGRES_USER=$POSTGRES_USER \
  -e POSTGRES_PASSWORD=$POSTGRES_PASSWORD \
  -e POSTGRES_DB=$POSTGRES_DB \
  -e TZ=$TZ \
  -p 5432:5432 \
  -v "$PWD/scripts":/docker-entrypoint-initdb.d \
  postgres:15-alpine
