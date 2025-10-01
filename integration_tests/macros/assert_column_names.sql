{% test assert_column_names(model, expected_column_names) %}
    {{ return (adapter.dispatch('assert_column_names', 'shared_macro')(model, expected_column_names)) }}
{% endtest %}

{% macro default__assert_column_names(model, expected_column_names) %}

    {% set actual_column_names = adapter.get_columns_in_relation(model) | map(attribute="name") | list | sort %}
    {% set expected_column_names = expected_column_names | sort %}

    {% if actual_column_names != expected_column_names %}
        -- Test fails: return rows to indicate failure
        select 
            '{{ actual_column_names | join(", ") }}' as actual_columns,
            '{{ expected_column_names | join(", ") }}' as expected_columns,
            'Column names do not match' as error_message
    {% else %}
        -- Test passes: return empty result set
        select 
            null as actual_columns,
            null as expected_columns,
            null as error_message
        where false
    {% endif %}

{% endmacro %}