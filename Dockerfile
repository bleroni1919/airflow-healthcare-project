FROM quay.io/astronomer/astro-runtime:12.5.0

# system dependencies
USER root
RUN apt-get update --fix-missing && apt-get install -y \
    libpq-dev \
    build-essential

# switch user
USER astro

COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt

COPY dags/healthcare_project /usr/local/airflow/dags/healthcare_project
COPY dags/myenv /usr/local/airflow/dags/myenv
COPY dags/logs /usr/local/airflow/dags/logs

COPY packages.txt /packages.txt
RUN if [ -s /packages.txt ]; then \
    apt-get update --fix-missing && apt-get -y install $(cat /packages.txt); \
    fi

# Initialize the database and start Airflow services
CMD ["bash", "-c", "airflow db init && airflow webserver & airflow scheduler"]
