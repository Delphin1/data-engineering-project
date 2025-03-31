-- Create schema and tables
CREATE SCHEMA IF NOT EXISTS iceberg.market_data;

-- Create table for raw tick data
CREATE TABLE IF NOT EXISTS iceberg.market_data.raw_ticks (
    source VARCHAR,
    symbol VARCHAR,
    ask DOUBLE,
    bid DOUBLE,
    mid DOUBLE,
    askMarkup DOUBLE,
    bidMarkup DOUBLE,
    isTradable BOOLEAN,
    number BIGINT,
    dateTime TIMESTAMP,
    receiveDateTime TIMESTAMP,
    _kafka_offset BIGINT
)
WITH (
    format = 'PARQUET',
    partitioning = ARRAY['day(dateTime)', 'symbol']
);