{%- macro sanitise_column_name(dirty_column_name) -%}
    {%- set re = modules.re -%}
    {%- set clean_column_name = dirty_column_name -%}
    {%- set clean_column_name = re.sub('[\s\.]', '_', clean_column_name.strip()) -%}
    {%- set clean_column_name = re.sub('HiQ', 'HIQ', clean_column_name) -%}
    {%- set clean_column_name = re.sub('([^_])([A-Z][a-z]+)', '\\1_\\2', clean_column_name) -%}
    {%- set clean_column_name = re.sub('([^a-zA-Z0-9_])', '', clean_column_name) -%}
    {%- set clean_column_name = re.sub('([a-z0-9])([A-Z])', '\\1_\\2', clean_column_name).lower() -%}
    {%- do return(clean_column_name) -%}
{%- endmacro -%}