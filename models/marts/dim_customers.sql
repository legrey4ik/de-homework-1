{{ config(materialized='table', distributed_replicated=true) }}

select
    c.customer_id,
    c.registered_at,
    c.registration_date,
    c.city,
    c.acquisition_channel,
    m.first_confirmed_order_id,
    m.first_confirmed_at,
    coalesce(m.confirmed_orders_count, 0) as confirmed_orders_count,
    coalesce(m.confirmed_revenue, 0) as confirmed_revenue,
    coalesce(m.confirmed_orders_count, 0) > 0 as is_buyer
from {{ ref('stg_shop__customers') }} as c
left join {{ ref('int_customer_metrics') }} as m
    on c.customer_id = m.customer_id
