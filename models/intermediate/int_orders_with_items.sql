select
    o.order_id,
    o.customer_id,
    o.order_date,
    o.ordered_at,
    o.order_status,
    o.order_amount,
    o.paid_amount,
    o.refunded_amount,
    o.net_paid_amount,
    o.successful_payments_count,
    o.first_paid_at,
    o.is_confirmed,
    o.is_test_order,
    coalesce(i.items_count, 0) as items_count
from {{ ref('int_orders_with_payments') }} as o
left join {{ ref('int_order_item_counts') }} as i
    on i.order_id = o.order_id
