{{ config(materialized='table', distributed_replicated=true) }}

select
    date_day,
    extract(year from date_day)::int as year,
    extract(quarter from date_day)::int as quarter,
    extract(month from date_day)::int as month,
    extract(day from date_day)::int as day,
    extract(isodow from date_day)::int as day_of_week,
    extract(isodow from date_day) in (6, 7) as is_weekend
from {{ ref('int_calendar') }}
