CREATE SCHEMA IF NOT EXISTS iceberg.market_data;
CREATE SCHEMA  iceberg.market_data;

drop table iceberg.market_data.stock_ticks;
CREATE TABLE  iceberg.market_data.stock_ticks (
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
    _kafka_timestamp TIMESTAMP
)
WITH (
    format = 'PARQUET',
    partitioning = ARRAY['day(dateTime)', 'source', 'symbol']
);

drop table iceberg.market_data.candle_m1;
CREATE TABLE  iceberg.market_data.candle_m1 (
    source VARCHAR,
    symbol VARCHAR,
    dateTime TIMESTAMP(3),
    open DOUBLE,
    high DOUBLE,
    low DOUBLE,
    close DOUBLE,
    volume BIGINT,
    _kafka_timestamp TIMESTAMP
)
WITH (
    format = 'PARQUET',
    partitioning = ARRAY['day(dateTime)', 'source', 'symbol']
);


-- every 1 minute
insert into iceberg.market_data.stock_ticks
select
    source,
    symbol,
    ask,
    bid,
    mid,
    askmarkup,
    bidmarkup,
    istradable,
    number,
    datetime,
    receivedatetime,
    "_timestamp"
from kafka.market_data.stock_ticks
where
    _timestamp > (select coalesce(max("_kafka_timestamp"), TIMESTAMP '1970-01-01 00:00:00') from iceberg.market_data.stock_ticks)
;

-- m1
insert into iceberg.market_data.candle_m1
    SELECT
        source,
        symbol,
        -- Truncate timestamp to minute
        date_trunc('minute', dateTime) AS dateTime,
        -- Open: First price in the interval
        first_value(mid) OVER (
            PARTITION BY source, symbol, date_trunc('minute', dateTime)
            ORDER BY dateTime
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS open,
        -- High: Maximum price in the interval
        max(mid) OVER (
            PARTITION BY source, symbol, date_trunc('minute', dateTime)
        ) AS high,
        -- Low: Minimum price in the interval
        min(mid) OVER (
            PARTITION BY source, symbol, date_trunc('minute', dateTime)
        ) AS low,
        -- Close: Last price in the interval
        last_value(mid) OVER (
            PARTITION BY source, symbol, date_trunc('minute', dateTime)
            ORDER BY dateTime
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS close,
        -- Count ticks as volume
        count(*) OVER (
            PARTITION BY source, symbol, date_trunc('minute', dateTime)
        ) AS volume,
        max(_timestamp) OVER (
            PARTITION BY source, symbol, date_trunc('minute', dateTime)
        ) as _kafka_timestamp
from kafka.market_data.stock_ticks
where
    _timestamp > (select coalesce(max("_kafka_timestamp"), TIMESTAMP '1970-01-01 00:00:00') from iceberg.market_data.candle_m1)
;
