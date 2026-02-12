#!/bin/sh

export DATABASE_HOST=localhost
export DATABASE_USER=root
export DATABASE_PASS=secret
export DATABASE_DBNAME=db_prova
export UPLOAD_DIR=uploads

uvicorn src.main:api --reload --port 8081 --host 0.0.0.0