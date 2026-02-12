#!/bin/sh
set -e

: "${PORT:=8081}"
: "${APP_WORKERS:=2}"

exec uvicorn src.main:api \
  --host 0.0.0.0 \
  --port "${PORT}" \
  --workers "${APP_WORKERS}" \
  --timeout-keep-alive 30
