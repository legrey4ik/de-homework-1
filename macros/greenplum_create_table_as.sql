{% macro postgres__create_table_as(temporary, relation, sql) -%}
    {%- set distributed_by = config.get('distributed_by') -%}
    {%- set distributed_replicated = config.get('distributed_replicated', false) -%}
    {%- set orientation = config.get('orientation') -%}
    create {% if temporary %}temporary {% endif %}table {{ relation }}
    {% if orientation == 'column' and not temporary %}
        with (appendoptimized=true, orientation=column)
    {% endif %}
    as (
        {{ sql }}
    )
    {% if distributed_replicated %}
        distributed replicated
    {% elif distributed_by %}
        distributed by ({{ distributed_by }})
    {% endif %};
{%- endmacro %}
