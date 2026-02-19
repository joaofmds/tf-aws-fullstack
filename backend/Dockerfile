FROM python:3.11-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update \
    && apt-get install -y build-essential gcc \
    && pip install --upgrade pip

COPY ./requirements.txt /app/
RUN pip install --prefix=/install --no-cache-dir -r requirements.txt

FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# curl required for ECS container health check
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /install /usr/local
COPY ./src /app/src
COPY ./start.sh /app/start.sh
COPY ./alembic.ini /app/alembic.ini
COPY ./migrations /app/migrations

RUN chmod +x /app/start.sh

EXPOSE 8081

CMD ["/app/start.sh"]