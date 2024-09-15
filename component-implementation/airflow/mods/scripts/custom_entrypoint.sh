#!/bin/bash
set -e
mkdir -p $AIRFLOW__CORE__DAGS_FOLDER $AIRFLOW__CORE__PLUGINS_FOLDER $AIRFLOW__LOGGING__BASE_LOG_FOLDER $AIRFLOW__TEMP_STORE
chown -R "${AIRFLOW_UID}:0" $AIRFLOW__CORE__DAGS_FOLDER $AIRFLOW__CORE__PLUGINS_FOLDER $AIRFLOW__LOGGING__BASE_LOG_FOLDER $AIRFLOW__TEMP_STORE

if ! airflow db check-migrations; then
    # Initialize database
    echo "Populating database"
    airflow db init

else
    # Upgrade database
    echo "Upgrading database schema"
    airflow db upgrade
    true # Avoid return false when I am not root
fi

export _AIRFLOW_DB_UPGRADE=$AIRFLOW_DB_UPGRADE
export _AIRFLOW_WWW_USER_CREATE=$AIRFLOW_WWW_USER_CREATE
export _AIRFLOW_WWW_USER_USERNAME=$AIRFLOW_WWW_USER_USERNAME
export _AIRFLOW_WWW_USER_PASSWORD=$AIRFLOW_WWW_USER_PASSWORD
export _PIP_ADDITIONAL_REQUIREMENTS=$PIP_ADDITIONAL_REQUIREMENTS

/entrypoint $AIRFLOW_COMMAND