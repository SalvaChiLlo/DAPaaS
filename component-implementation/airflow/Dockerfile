FROM apache/airflow:slim-2.10.0
ENV TZ=Europe/Madrid

USER airflow

COPY mods/webserver_config.py /opt/airflow/webserver_config.py
COPY mods/scripts/custom_entrypoint.sh /custom_entrypoint.sh
COPY mods/requirements.txt .

RUN pip install -r requirements.txt

USER root

ENTRYPOINT [ "/custom_entrypoint.sh" ]