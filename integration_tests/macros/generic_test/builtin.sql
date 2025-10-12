{% test unique(model, column_name, column_names=[], where='1=1') %}

    {{ return (adapter.dispatch('test_unique', 'shared_macro')(model, column_name, column_names, where)) }}
{% endtest %}