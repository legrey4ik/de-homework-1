with paid_orders as (
    select distinct order_id
    from {{ source('shop', 'payments') }}
    where payment_status = 'success' and amount >= 0
),
raw_total as (
    select count(*) as orders_count, coalesce(sum(o.total_amount), 0) as revenue
    from {{ source('shop', 'orders') }} as o
    join paid_orders as p on p.order_id = o.order_id
    where o.status = 'paid'
),
mart_total as (
    select count(*) as orders_count, coalesce(sum(order_amount), 0) as revenue
    from {{ ref('fct_orders') }}
    where is_confirmed
)
select r.orders_count as raw_count, m.orders_count as mart_count,
       r.revenue as raw_revenue, m.revenue as mart_revenue
from raw_total as r cross join mart_total as m
where r.orders_count <> m.orders_count or abs(r.revenue - m.revenue) > 0.01
