{{ config(severity='warn') }}

select order_id, order_amount, net_paid_amount
from {{ ref('fct_orders') }}
where is_confirmed and net_paid_amount > order_amount + 0.01
