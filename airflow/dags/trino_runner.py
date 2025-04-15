
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.utils.dates import days_ago
from airflow.models.param import Param

# Define default parameters for the DAG
default_args = {
    'owner': 'data_engineer',
    'depends_on_past': False,
    'email': ['some@email.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 3,
    'retry_delay': timedelta(minutes=1),
}

# Create the DAG
dag = DAG(
    'dbt_trino_5min',
    default_args=default_args,
    description='DAG to run dbt with Trino every 5 minutes',
    schedule_interval='*/5 * * * *',  # Cron expression to run every 5 minutes
    start_date=days_ago(1),
    catchup=False,
    max_active_runs=1,
    tags=['dbt', 'trino', 'etl'],
    params={
        'dbt_profile': Param('trino', type='string', description='dbt profile'),
        'dbt_target': Param('dev', type='string', description='dbt target environment'),
        'dbt_models': Param('tag:5minute', type='string', description='Models to run (tags/names)'),
        'dbt_project_dir': Param('/opt/airflow/dbt_projects/stock_ticks', type='string',
                                description='Path to dbt project directory')
    },
)



# Task to run dbt deps (install dependencies)
# dbt_deps = BashOperator(
#     task_id='dbt_deps',
#     bash_command="""
#     cd {{ params.dbt_project_dir }}
#     dbt deps --profiles-dir ./profiles
#     """,
#     dag=dag,
# )

# Task to compile dbt models
dbt_compile = BashOperator(
    task_id='dbt_compile',
    bash_command="""
    cd {{ params.dbt_project_dir }}
    dbt compile --profiles-dir ./profiles --profile {{ params.dbt_profile }} --target {{ params.dbt_target }}
    """,
    dag=dag,
)

# Task to run dbt models
dbt_run = BashOperator(
    task_id='dbt_run',
    bash_command="""
    cd {{ params.dbt_project_dir }}
    dbt run --profiles-dir ./profiles --profile {{ params.dbt_profile }} --target {{ params.dbt_target }} --models {{ params.dbt_models }}
    """,
    dag=dag,
)

# # Task to run dbt tests
# dbt_test = BashOperator(
#     task_id='dbt_test',
#     bash_command="""
#     cd {{ params.dbt_project_dir }}
#     dbt test --profiles-dir ./profiles --profile {{ params.dbt_profile }} --target {{ params.dbt_target }} --models {{ params.dbt_models }}
#     """,
#     dag=dag,
# )

# Task to log metadata on success
log_success = BashOperator(
    task_id='log_success',
    bash_command="""
    echo "dbt project successfully executed at $(date)"
    echo "Used profile: {{ params.dbt_profile }}, target: {{ params.dbt_target }}"
    echo "Models run: {{ params.dbt_models }}"
    """,
    dag=dag,
)

dbt_compile >> dbt_run >> log_success