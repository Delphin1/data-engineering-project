-- stream
--DROP STREAM IF EXISTS stock_ticks DELETE TOPIC;
CREATE OR REPLACE STREAM stock_ticks (
    source VARCHAR,
    symbol VARCHAR,
    ask DOUBLE,
    bid DOUBLE,
    mid DOUBLE,
    askMarkup DOUBLE,
    bidMarkup DOUBLE,
    isTradable BOOLEAN,
    dateTime VARCHAR,
    receiveDateTime VARCHAR
       )
  WITH (kafka_topic='stock_ticks',
        value_format='json',
       timestamp='dateTime',
       PARTITIONS=8,
       timestamp_format='yyyy-MM-dd''T''HH:mm:ss.SSS')
  ;

-- 1minute
--drop table IF EXISTS CANDLE_1MINUTE DELETE TOPIC;
CREATE OR REPLACE TABLE CANDLE_1MINUTE
WITH (KAFKA_TOPIC='candle_1minute', KEY_FORMAT='JSON', VALUE_FORMAT='JSON') AS
SELECT
  AS_VALUE(SOURCE) as SRC,
  AS_VALUE(SYMBOL) as SMB,
  TIMESTAMPTOSTRING(WINDOWSTART, 'yyyy-MM-dd''T''HH:mm:ss.SSS') AS WINDOW_START_TS,
  TIMESTAMPTOSTRING(WINDOWEND, 'yyyy-MM-dd''T''HH:mm:ss.SSS') AS WINDOW_END_TS,
  SOURCE,
  SYMBOL,
  EARLIEST_BY_OFFSET(MID) AS OPEN,
  MAX(MID) AS HIGH,
  MIN(MID) AS LOW,
  LATEST_BY_OFFSET(MID) AS CLOSE,
  COUNT(*) AS VOLUME
FROM STOCK_TICKS
WINDOW TUMBLING (SIZE 1 MINUTE)
-- WINDOW HOPPING (SIZE 1 MINUTE, ADVANCE BY 1 MINUTE)
GROUP BY SOURCE, SYMBOL
-- EMIT FINAL;
EMIT CHANGES;

-- 10 minutes
--drop table IF EXISTS CANDLE_10MINUTE DELETE TOPIC;
CREATE OR REPLACE TABLE CANDLE_10MINUTE
WITH (KAFKA_TOPIC='candle_10minute', KEY_FORMAT='JSON', VALUE_FORMAT='JSON') AS
SELECT
  AS_VALUE(SOURCE) as SRC,
  AS_VALUE(SYMBOL) as SMB,
  TIMESTAMPTOSTRING(WINDOWSTART, 'yyyy-MM-dd''T''HH:mm:ss.SSS') AS WINDOW_START_TS,
  TIMESTAMPTOSTRING(WINDOWEND, 'yyyy-MM-dd''T''HH:mm:ss.SSS') AS WINDOW_END_TS,
  SOURCE,
  SYMBOL,
  EARLIEST_BY_OFFSET(MID) AS OPEN,
  MAX(MID) AS HIGH,
  MIN(MID) AS LOW,
  LATEST_BY_OFFSET(MID) AS CLOSE,
  COUNT(*) AS VOLUME
FROM STOCK_TICKS
WINDOW TUMBLING (SIZE 10 MINUTE)
-- WINDOW HOPPING (SIZE 10 MINUTE, ADVANCE BY 1 MINUTE)
GROUP BY SOURCE, SYMBOL
EMIT CHANGES;
--EMIT FINAL;

-- 1 hour
--drop table IF EXISTS CANDLE_1HOUR DELETE TOPIC;
CREATE OR REPLACE TABLE CANDLE_1HOUR
WITH (KAFKA_TOPIC='candle_1hour', KEY_FORMAT='JSON', VALUE_FORMAT='JSON') AS
SELECT
  AS_VALUE(SOURCE) as SRC,
  AS_VALUE(SYMBOL) as SMB,
  TIMESTAMPTOSTRING(WINDOWSTART, 'yyyy-MM-dd''T''HH:mm:ss.SSS') AS WINDOW_START_TS,
  TIMESTAMPTOSTRING(WINDOWEND, 'yyyy-MM-dd''T''HH:mm:ss.SSS') AS WINDOW_END_TS,
  SOURCE,
  SYMBOL,
  EARLIEST_BY_OFFSET(MID) AS OPEN,
  MAX(MID) AS HIGH,
  MIN(MID) AS LOW,
  LATEST_BY_OFFSET(MID) AS CLOSE,
  COUNT(*) AS VOLUME
FROM STOCK_TICKS
WINDOW TUMBLING (SIZE 1 HOUR)
-- WINDOW HOPPING (SIZE 1 HOUR, ADVANCE BY 1 MINUTE)
GROUP BY SOURCE, SYMBOL
EMIT CHANGES;
-- EMIT FINAL;


-- 1 day
--drop table IF EXISTS CANDLE_1DAY DELETE TOPIC;
CREATE OR REPLACE TABLE CANDLE_1DAY
WITH (KAFKA_TOPIC='candle_1day', KEY_FORMAT='JSON', VALUE_FORMAT='JSON') AS
SELECT
  AS_VALUE(SOURCE) as SRC,
  AS_VALUE(SYMBOL) as SMB,
  TIMESTAMPTOSTRING(WINDOWSTART, 'yyyy-MM-dd''T''HH:mm:ss.SSS') AS WINDOW_START_TS,
  TIMESTAMPTOSTRING(WINDOWEND, 'yyyy-MM-dd''T''HH:mm:ss.SSS') AS WINDOW_END_TS,
  SOURCE,
  SYMBOL,
  EARLIEST_BY_OFFSET(MID) AS OPEN,
  MAX(MID) AS HIGH,
  MIN(MID) AS LOW,
  LATEST_BY_OFFSET(MID) AS CLOSE,
  COUNT(*) AS VOLUME
FROM STOCK_TICKS
WINDOW TUMBLING (SIZE 1 DAY)
-- WINDOW HOPPING (SIZE 1 DAY, ADVANCE BY 1 MINUTE, TIME_UNIT 'DAY')
GROUP BY SOURCE, SYMBOL
EMIT CHANGES;
-- EMIT FINAL;







-- check
/*
show topics;
PRINT 'stock_ticks';

DESCRIBE stock_ticks;


SET 'auto.offset.reset' = 'earliest';
select * from STOCK_TICKS EMIT CHANGES limit 10;
select dateTime, STRINGTOTIMESTAMP(dateTime, 'yyyy-MM-dd''T''HH:mm:ss.SSS') as dt
from CANDLE_1MINUTE EMIT CHANGES LIMIT 5;


SELECT
      TIMESTAMPTOSTRING(WINDOWSTART, 'HH:mm') AS WINDOW_START,
      TIMESTAMPTOSTRING(WINDOWEND, 'HH:mm') AS WINDOW_END,
      SOURCE,
      SYMBOL,
      OPEN,
      HIGH,
      LOW,
      CLOSE,
      VOLUME
FROM CANDLE_1MINUTE
EMIT CHANGES;
*/