{% macro clean_stale_models(database=target.project, schema=target.dataset, days=7, dry_run=True) %}
    
    {% set get_drop_commands_query %}
        with source as (
            select
                table_catalog,
                table_schema,
                table_name,
                case 
                    when table_type = 'VIEW'
                        then table_type
                    else 
                        'TABLE'
                end as drop_type
            from `{{schema}}`.INFORMATION_SCHEMA.TABLES
            where 1=1
                and table_schema = '{{schema}}'
                and table_catalog = '{{database}}'
                and DATE(creation_time) <= DATE_SUB(CURRENT_DATE(), INTERVAL {{days}} DAY)
            )

        select 
        'DROP ' || drop_type || ' `'  || table_catalog || '`.`'  ||  table_schema || '`.' || table_name || ';' as drop_query
        from source
    {% endset %} 

        {{ log('\nGenerating cleanup queries...\n', info=True) }}

        {% set drop_queries = run_query(get_drop_commands_query).columns[0].values() %}

        {% for query in drop_queries %}
            {% if dry_run %}
                {{ log(query, info=True) }}
            {% else %}
                {{ log('Dropping object with command: ' ~ query, info=True) }}
                {% do run_query(query) %} 
            {% endif %}       
        {% endfor %}
    
{% endmacro %} 