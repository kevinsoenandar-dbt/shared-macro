{% macro format_id(column_name) %}
RIGHT(CONCAT('00000000', {{ column_name }}), 8)
{% endmacro %}