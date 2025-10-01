
{%- macro snake_case_columns(
    relation,
    relation_alias=None,
    exclude = var('dw_columns'),
    skip_rename = var('dw_columns'),
    empty_string_to_null = False,
    nvarchar_max_to_varchar_8k = False
) -%}

{# query database for the relation's original column names #}
{%- set relation_columns = adapter.get_columns_in_relation(relation) -%}
{%- set columns_mapped = [] -%}

{%- for relation_column in relation_columns -%}
    {%- set name = relation_column.name -%}

    {# create a dict list of original_name and sanitised_name, replacing bad characters #}
    {%- if name not in exclude -%}

        {# only rename if it's not in skip_rename #}
        {%- if name not in skip_rename -%}
            {%- set sanitised_name = shared_macro.sanitise_column_name(name) -%}
        {%- else -%}
            {%- set sanitised_name = name -%}
        {%- endif -%}

        {# append to list of mapped columns #}
        {%- do columns_mapped.append({ 'original_name': name, 'sanitised_name': sanitised_name, 'relation_column': relation_column }) -%}
    {%- endif -%}
{%- endfor -%}

{# business end #}
{%- set output_sql_snippet -%}
    {% for column in columns_mapped -%}

        {# handle string columns #}
        {%- if (column.relation_column.is_string() or column.relation_column.dtype in ['varchar', 'string']) -%}

            {# cast opener #}
            {%- if (nvarchar_max_to_varchar_8k and column.relation_column.dtype in ['varchar', 'string']) -%}
                cast(
            {%- endif -%}

            {# empty strings to null #}
            {%- if (empty_string_to_null) -%}
                    coalesce({{ relation_alias ~ '.' if relation_alias is not none }}{{ column.original_name }}, '')
            {%- else -%}
                    {{ relation_alias ~ '.' if relation_alias is not none }}{{ column.original_name }}
            {%- endif -%}

            {# cast closer #}
            {%- if (nvarchar_max_to_varchar_8k and column.relation_column.dtype in ['varchar', 'string']) %} as varchar(8000)){%- endif %}
                as {{ adapter.quote(column.sanitised_name) }}{%- if not loop.last %},{% endif %}

        {# handle non-string columns #}
        {%- else -%}
            {{ relation_alias ~ '.' if relation_alias is not none }}{{ column.original_name }} as {{ adapter.quote(column.sanitised_name) }}{% if not loop.last %},{% endif %}
        {%- endif -%}

    {% endfor -%}
{%- endset -%}

{{ output_sql_snippet }}

{%- endmacro -%}