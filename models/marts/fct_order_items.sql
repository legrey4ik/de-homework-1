{{ config(
    materialized='incremental',
    unique_key='order_item_id',
    distributed_by='order_id',
    orientation='column'
) }}

select
    order_item_id,
    order_id,
    product_id,
    customer_id,
    order_date,
    quantity,
    unit_price,
    discount_amount,
    line_amount,
    is_confirmed
from {{ ref('int_order_items_enriched') }}
where not is_test_order
{% if is_incremental() %}
    and order_id > (select coalesce(max(order_id), 0) from {{ this }})
{% endif %}
