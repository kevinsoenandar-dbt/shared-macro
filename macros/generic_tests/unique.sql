{% macro default__test_unique(model, column_name, column_names=[], where='1=1') %}

    {% set column_names = [column_name] if (column_names | length == 0) else column_names %}

    with
        model_to_test as (
            select * from {{ model }}
            where {{ where }}
        ),

        duplicate_records as (
            {% set column_names_sql_snippet %}
                {% for column_name in column_names %}
                    model_to_test.{{ column_name }}
                    {%- if not loop.last -%},{%- endif %}
                {% endfor %}
            {% endset %}

            select
                count(*) as record_count,
                {{ column_names_sql_snippet }}
            from
                model_to_test
            group by
                {{ column_names_sql_snippet }}
            having
                count(*) > 1
        ),

        final as (
            select
                duplicate_records.record_count,
                '{{ column_names | join("|") }}' as uniqueness_check,
                model_to_test.*

            from duplicate_records
                left join model_to_test
                    on
                    {% for column_name in column_names %}
                        {%- if not loop.first -%}and{%- endif %}
                        (
                            model_to_test.{{ column_name }} = duplicate_records.{{ column_name }}
                                or (
                                model_to_test.{{ column_name }} is null
                                and duplicate_records.{{ column_name }} is null
                            )
                        )
                    {% endfor %}
        )

select * from final
{% endmacro %}
