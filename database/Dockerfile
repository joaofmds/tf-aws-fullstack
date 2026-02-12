FROM postgres:15-alpine

COPY ./scripts/init_db.sql /docker-entrypoint-initdb.d/

EXPOSE 5432
