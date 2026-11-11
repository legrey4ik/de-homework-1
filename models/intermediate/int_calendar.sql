with borders as (
    select min(order_date) as first_day, max(order_date) as last_day
    from {{ ref('stg_shop__orders') }}
)
select days.day::date as date_day
from borders,
     generate_series(borders.first_day, borders.last_day, interval '1 day') as days(day)
