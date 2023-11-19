{% macro grant_select(user_name, schema=target.dataset, project=target.project) %}

    {% set sql %}

    GRANT `roles/bigquery.dataViewer`
    ON TABLE `{{project}}`.{{schema}}
    TO "user:{{user_name}}";

    {% endset %}

    {{ log('Granting select on all tables and views in schema ' ~ schema ~ ' from project ' ~ project, info=True) }}
    {% do run_query(sql) %}
    {{ log('Privileges granted', info=True) }}

{% endmacro %}



