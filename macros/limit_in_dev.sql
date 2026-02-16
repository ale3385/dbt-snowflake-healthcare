{% macro limit_in_dev(column_name, dev_days=3) %}
    {% if target.name != 'prod' %}
        WHERE {{ column_name }} >= DATEADD('day', -{{ dev_days }}, CURRENT_DATE)
    {% endif %}
{% endmacro %}
