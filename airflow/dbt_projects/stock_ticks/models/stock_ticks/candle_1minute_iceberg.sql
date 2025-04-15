{{
  config(
    materialized = 'incremental',
    unique_key = ['source', 'symbol', 'window_start_ts'],
    incremental_strategy = 'merge',
    merge_update_columns = ['window_end_ts', 'open', 'high', 'low', 'close', 'volume']
  )
}}

with source_data as (
    select
        CAST(window_start_ts AS timestamp(6)) as window_start_ts,
        CAST(window_end_ts AS timestamp(6)) as window_end_ts,
        source,
        symbol,
        open,
        high,
        low,
        close,
        volume,
        ROW_NUMBER() OVER (PARTITION BY source, symbol, window_start_ts  ORDER BY _timestamp DESC) AS row_num
    from {{ source('kafka', 'candle_1minute') }}

    {% if is_incremental() %}
    where window_start_ts >= date_add('minute', -1, COALESCE((select min(max_window_start_ts) from (select source, symbol, max(window_start_ts) as max_window_start_ts from {{ this }} group by  source, symbol)), from_iso8601_timestamp('1971-01-01T00:00:00.000')))
    {% endif %}
)

,
final as (
    select
        window_start_ts,
        window_end_ts,
        source,
        symbol,
        open,
        high,
        low,
        close,
        volume
    from source_data
    where row_num = 1
)

select * from final