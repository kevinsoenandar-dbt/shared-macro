with source as (
    select 
        {{ shared_macro.snake_case_columns(ref("customers")) }}

    from {{ ref("customers") }}
)

select
    {{ shared_macro.format_id("id") }} as customer_id,
    first_name,
    last_name, 
    email,
    gender,
    ip_address_v4

from source