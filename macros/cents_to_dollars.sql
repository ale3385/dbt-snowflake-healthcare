{% macro cents_to_dollars(column_name) %}
    ROUND({{ column_name }}::NUMERIC / 100, 2)
{% endmacro %}
