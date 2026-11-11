with confirmed as (
    select
        order_id,
        customer_id,
        order_amount,
        first_paid_at,
        row_number() over (
            partition by customer_id
            order by first_paid_at, order_id
        ) as rn
    from {{ ref('int_orders_with_payments') }}
    where is_confirmed and not is_test_order
)
select
    customer_id,
    max(case when rn = 1 then order_id end) as first_confirmed_order_id,
    min(first_paid_at) as first_confirmed_at,
    count(*) as confirmed_orders_count,
    sum(order_amount) as confirmed_revenue
from confirmed
group by customer_id
