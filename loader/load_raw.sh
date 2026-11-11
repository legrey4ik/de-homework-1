#!/bin/sh
set -eu

if [ "$(psql -h greenplum -U gpadmin -d postgres -Atc "select count(*) from pg_database where datname = 'dwh'")" != '1' ]; then
    psql -h greenplum -U gpadmin -d postgres -v ON_ERROR_STOP=1 -c 'create database dwh'
fi

psql -h greenplum -U gpadmin -d dwh -v ON_ERROR_STOP=1 -f /loader/create_raw.sql

for tab in customers products product_categories orders order_items payments; do
    psql -h postgres -U student -d shop -v ON_ERROR_STOP=1 \
        -c "\copy public.${tab} to '/tmp/${tab}.csv' with (format csv, header true)"
    psql -h greenplum -U gpadmin -d dwh -v ON_ERROR_STOP=1 \
        -c "truncate table raw.${tab}"
    psql -h greenplum -U gpadmin -d dwh -v ON_ERROR_STOP=1 \
        -c "\copy raw.${tab} from '/tmp/${tab}.csv' with (format csv, header true)"
done

psql -h greenplum -U gpadmin -d dwh -v ON_ERROR_STOP=1 -At \
    -c "select 'orders ' || count(*) from raw.orders union all
        select 'order_items ' || count(*) from raw.order_items union all
        select 'payments ' || count(*) from raw.payments union all
        select 'customers ' || count(*) from raw.customers union all
        select 'products ' || count(*) from raw.products union all
        select 'product_categories ' || count(*) from raw.product_categories"

n=$(psql -h greenplum -U gpadmin -d dwh -Atc 'select count(*) from raw.orders')
if [ "$n" != '141' ]; then
    echo "Ошибка: raw.orders содержит $n строк вместо 141" >&2
    exit 1
fi

echo 'Готово: raw загружен в Greenplum (dwh).'
