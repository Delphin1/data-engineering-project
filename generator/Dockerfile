FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    librdkafka-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ticks-generator-conf.py .

RUN chmod +x ticks-generator-conf.py

ENTRYPOINT ["./ticks-generator-conf.py"]

# Default arguments that can be overridden
CMD ["--bootstrap.servers", "kafka:9092", "--topic", "ticks", "--interval", "1.0"]