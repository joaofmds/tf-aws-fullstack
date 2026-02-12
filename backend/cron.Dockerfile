FROM python:3.11-slim

WORKDIR /app

COPY ./requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY ./src /app/src
COPY cron.sh /app/cron.sh

RUN chmod +x /app/cron.sh && mkdir -p /app/uploads

ENV UPLOAD_DIR=/app/uploads

CMD ["sh", "-c", "while true; do sh /app/cron.sh; sleep 300; done"]
