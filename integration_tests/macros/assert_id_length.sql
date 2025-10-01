{% test assert_column_value_length(model, column_name,length) %}

    {{ return (adapter.dispatch('assert_column_value_length', 'shared_macro')(model, column_name, length)) }}
{% endtest %}

{% macro default__assert_column_value_length(model, column_name, length) %}

    select *

    from {{ model }}

    where typeof({{ column_name }}) != 'string'
        or length({{ column_name }}) != {{ length }}

{% endmacro %}