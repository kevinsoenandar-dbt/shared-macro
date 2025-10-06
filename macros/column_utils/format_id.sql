{% macro format_id(column_name) %}
substr(CONCAT('0000', {{ column_name }}, '0000'), 5, 8)
{% endmacro %}