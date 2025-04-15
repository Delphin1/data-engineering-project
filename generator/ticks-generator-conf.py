#!/usr/bin/env python3
"""
Fake Ticks Generator
Generates fake trading ticks and sends them to a Kafka topic
"""

import argparse
import json
import random
import time
import os
from datetime import datetime, timezone, timedelta
from typing import Dict, Any, List, Optional

from faker import Faker
# from kafka import KafkaProducer
from confluent_kafka import Producer

def parse_args():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(description='Generate fake ticks and send to Kafka')
    parser.add_argument('--bootstrap.servers', required=True, help='Kafka brokers (comma-separated)')
    parser.add_argument('--topic', required=True, help='Kafka topic to send ticks to')
    parser.add_argument('--interval', type=float, default=1.0,
                        help='Interval between ticks in seconds (default: 1.0)')
    parser.add_argument('--count', type=int, default=0,
                        help='Number of ticks to generate (0 = infinite, default: 0)')
    parser.add_argument('--symbols', type=str, default="BTCUSD,ETHUSD,SOLUSD,XRPUSD,AVAXUSD",
                        help='Comma-separated list of trading symbols (default: BTCUSD,ETHUSD,SOLUSD,XRPUSD,AVAXUSD)')
    parser.add_argument('--sources', type=str, default="SOURCE_1,SOURCE_2,SOURCE_3",
                        help='Comma-separated list of data sources (default: SOURCE_1,SOURCE_2,SOURCE_3)')
    parser.add_argument('--security.protocol', default='PLAINTEXT',
                        help='If set, you need to pass env variables KAFKA_SASL_USERNAME, KAFKA_SASL_PASSWORD, CLIENT_ID')
    return parser.parse_args()


class TickGenerator:
    """Generates fake trading ticks using Faker"""

    def __init__(self, symbols: List[str], sources: List[str]):
        self.faker = Faker()
        self.symbols = symbols
        self.sources = sources
        # Maintain state for each symbol to make price movements realistic
        self.symbol_state: Dict[str, Dict[str, float]] = {}
        self.initialize_symbol_state()

    def initialize_symbol_state(self):
        """Initialize price state for each symbol"""
        price_ranges = {
            "BTCUSD": (50000, 70000),
            "ETHUSD": (3000, 4000),
            "SOLUSD": (120, 150),
            "XRPUSD": (0.5, 1.5),
            "AVAXUSD": (30, 50),
        }

        for symbol in self.symbols:
            # Use predefined ranges if available, otherwise use a default range
            min_price, max_price = price_ranges.get(symbol, (100, 1000))
            initial_mid = round(random.uniform(min_price, max_price), 5)

            # Set smaller spread for higher-priced assets
            spread_percentage = 0.0002 if initial_mid > 1000 else 0.001
            spread = max(0.01, initial_mid * spread_percentage)

            self.symbol_state[symbol] = {
                "mid": initial_mid,
                "spread": spread,
                "volatility": random.uniform(0.0005, 0.002)  # % price movement per tick
            }

    def generate_tick(self) -> Dict[str, Any]:
        """Generate a single tick with realistic data"""
        # Select a random symbol and source
        symbol = random.choice(self.symbols)
        source = random.choice(self.sources)

        # Get current state
        state = self.symbol_state[symbol]

        # Simulate price movement
        price_change_pct = random.normalvariate(0, state["volatility"])
        state["mid"] = max(0.01, state["mid"] * (1 + price_change_pct))

        # Occasionally change the spread
        if random.random() < 0.05:  # 5% chance to adjust spread
            state["spread"] = max(0.0001 * state["mid"], state["spread"] * random.uniform(0.95, 1.05))

        # Calculate prices
        mid = round(state["mid"], 5)
        half_spread = state["spread"] / 2
        ask = round(mid + half_spread, 5)
        bid = round(mid - half_spread, 5)

        # Generate current timestamp
        now = datetime.now(timezone.utc)
        date_time = now.strftime("%Y-%m-%dT%H:%M:%S.000")

        # Simulate a small processing delay (0-300ms)
        receive_delay_ms = random.randint(0, 300)
        receive_time = now + timedelta(milliseconds=receive_delay_ms)
        receive_date_time = receive_time.strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3]

        # Simulate occasional non-tradable ticks
        is_tradable = random.random() < 0.98  # 98% are tradable

        # # Generate a unique number (timestamp-based with some randomness)
        # number = int(now.timestamp() * 1000000) + random.randint(0, 999)

        # Occasional markup
        ask_markup = 0 if random.random() < 0.9 else round(random.uniform(0.01, 0.2), 2)
        bid_markup = 0 if random.random() < 0.9 else round(random.uniform(0.01, 0.2), 2)

        return {
            "source": source,
            "symbol": symbol,
            "ask": ask,
            "bid": bid,
            "mid": mid,
            "askMarkup": ask_markup,
            "bidMarkup": bid_markup,
            "isTradable": is_tradable,
            # "number": number,
            "dateTime": date_time,
            "receiveDateTime": receive_date_time
        }


def create_kafka_producer(args) -> Producer:
    """Create and return a Kafka producer instance"""
    config = {
        'bootstrap.servers': getattr(args, 'bootstrap.servers'),
        'security.protocol': getattr(args, 'security.protocol'),
        'sasl.mechanisms': getattr(args, 'sasl.mechanisms'),
        'sasl.username': getattr(args, 'sasl.username'),
        'sasl.password': getattr(args, 'sasl.password')
    }
    # print(f"config = {config}")
    producer = Producer(config)
    return producer


def main():
    """Main function to generate and send ticks"""
    args = parse_args()
    if getattr(args, 'security.protocol') != 'PLAINTEXT':
        setattr(args, 'sasl.mechanisms', 'PLAIN')
        setattr(args, 'sasl.username', os.environ['KAFKA_SASL_USERNAME'])
        setattr(args, 'sasl.password', os.environ['KAFKA_SASL_PASSWORD'])
        # setattr(args, 'client_id', os.environ['CLIENT_ID'])


    symbols = args.symbols.split(',')
    sources = args.sources.split(',')

    generator = TickGenerator(symbols, sources)
    producer = create_kafka_producer(args)

    count = 0
    try:
        print(f"Starting to generate ticks to topic {args.topic} at {args.interval}s intervals")
        while args.count == 0 or count < args.count:
            tick = generator.generate_tick()
            producer.produce(args.topic, value=json.dumps(tick).encode("utf-8"))

            # Print tick info
            print(f"Sent: {tick['symbol']} @ {tick['mid']} [{tick['source']}]")

            # Increase count and sleep
            count += 1
            time.sleep(args.interval)

    except KeyboardInterrupt:
        print("\nStopping tick generation")
    finally:
        # Ensure all messages are sent before exiting
        producer.flush()
        # producer.close()
        print(f"Total ticks generated: {count}")


if __name__ == "__main__":
    main()