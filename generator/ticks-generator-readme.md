# Ticks Generator

A containerized application that generates fake trading ticks and sends them to a Kafka topic. This tool is useful for testing and development of financial data processing pipelines.

## Overview

The Ticks Generator creates realistic simulated market data ticks with the following features:

- Configurable trading symbols (default: BTCUSD, ETHUSD, SOLUSD, XRPUSD, AVAXUSD)
- Multiple data sources simulation
- Realistic price movements with appropriate volatility
- Configurable tick generation interval
- Kafka integration with support for authentication

## Quick Start

### Prerequisites

- Docker installed on your system
- Access to a Kafka cluster (local or remote)

### Building the Docker Image

Clone this repository and build the Docker image:

```bash
git clone <repository-url>
cd ticks-generator
docker build -t ticks-generator .
```

### Basic Usage

Run the container with default settings (connects to `kafka:9092` and publishes to topic `ticks`):

```bash
docker run ticks-generator
```

## Configuration Options

The ticks generator can be configured using command-line arguments:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--bootstrap.servers` | Kafka brokers (comma-separated) | Required |
| `--topic` | Kafka topic to send ticks to | Required |
| `--interval` | Interval between ticks in seconds | 1.0 |
| `--count` | Number of ticks to generate (0 = infinite) | 0 |
| `--symbols` | Comma-separated list of trading symbols | BTCUSD,ETHUSD,SOLUSD,XRPUSD,AVAXUSD |
| `--sources` | Comma-separated list of data sources | SOURCE_1,SOURCE_2,SOURCE_3 |
| `--security.protocol` | Security protocol for Kafka connection | PLAINTEXT |

## Usage Examples

### Custom Symbols and Interval

Generate ticks for specific symbols at a faster rate:

```bash
docker run ticks-generator \
  --bootstrap.servers kafka:9092 \
  --topic crypto-ticks \
  --interval 0.1 \
  --symbols BTCUSD,ETHUSD
```

### Connect to External Kafka Cluster

```bash
docker run ticks-generator \
  --bootstrap.servers broker1.example.com:9092,broker2.example.com:9092 \
  --topic market-data
```

### Authentication with SASL

For secured Kafka clusters, you can use SASL authentication:

```bash
docker run \
  -e KAFKA_SASL_USERNAME=your-username \
  -e KAFKA_SASL_PASSWORD=your-password \
  ticks-generator \
  --bootstrap.servers kafka-secured.example.com:9092 \
  --topic secured-ticks \
  --security.protocol SASL_SSL
```

### Limiting Generated Ticks

Generate a specific number of ticks and then exit:

```bash
docker run ticks-generator \
  --bootstrap.servers kafka:9092 \
  --topic ticks \
  --count 1000
```

## Data Format

The generated ticks are sent to Kafka as JSON messages with the following structure:

```json
{
  "source": "SOURCE_1",
  "symbol": "BTCUSD",
  "ask": 65432.12345,
  "bid": 65430.12345,
  "mid": 65431.12345,
  "askMarkup": 0,
  "bidMarkup": 0,
  "isTradable": true,
  "number": 1713283464123456,
  "dateTime": "2024-04-16T12:34:56.000",
  "receiveDateTime": "2024-04-16T12:34:56.123"
}
```



## Troubleshooting

- **Connection issues**: Ensure the Kafka brokers are reachable from the Docker container
- **Authentication failures**: Check your SASL credentials and security protocol settings
- **No data flowing**: Verify the topic exists and has proper permissions
