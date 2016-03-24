#!/bin/sh
export PROJECT_NAME=ckan

export SOLR_COMPOSE=docker-compose.solr.yml
export SOLR_CONTAINER=${PROJECT_NAME}_solr_1
export POSTGRES_COMPOSE=docker-compose.postgres.yml
export POSTGRES_CONTAINER=${PROJECT_NAME}_postgres_1

export CONFIG = ../open-data/ckan/test-core.ini
export VENV_PATH = ./.venv-${PROJECT_NAME}

default: up

init: build init-postgres set-permissions-postgress

build: build-postgres build-solr

rebuild: rebuild-postgres rebuild-solr

up: up-postgres up-solr

stop: stop-postgres stop-solr

down: down-postgres down-solr

# Postgres config
build-postgres: up-postgres

rebuild-postgres: down-postgres build-postgres

init-postgres:
	. ${VENV_PATH}/bin/activate && \
		paster --plugin=ckan db init -c ${CONFIG}

set-permissions-postgress:
	. ${VENV_PATH}/bin/activate && \
		paster --plugin=ckan datastore set-permissions -c ${CONFIG} | cat | \
		docker exec -i --user=postgres ${POSTGRES_CONTAINER} psql

up-postgres:
	docker-compose -f ${POSTGRES_COMPOSE} -p ${PROJECT_NAME} up -d

stop-postgres:
	docker-compose -f ${POSTGRES_COMPOSE} -p ${PROJECT_NAME} stop

down-postgres:
	docker-compose -f ${POSTGRES_COMPOSE} -p ${PROJECT_NAME} down
# Solr Config
build-solr: up-solr
	#docker exec -it --user=solr ${SOLR_CONTAINER} \
	#	/docker-entrypoint-initsolr.d/create-core.sh
	docker exec -it ${SOLR_CONTAINER} \
		/docker-entrypoint-initsolr.d/create-core-old.sh
	sleep 7

rebuild-solr: down-solr build-solr

up-solr:
	docker-compose -f ${SOLR_COMPOSE} -p ${PROJECT_NAME}  up -d

stop-solr:
	docker-compose -f ${SOLR_COMPOSE} -p ${PROJECT_NAME} stop

down-solr:
	docker-compose -f ${SOLR_COMPOSE} -p ${PROJECT_NAME} down

build-venv:
	virtualenv --no-site-packages ${VENV_PATH}
	. ${VENV_PATH}/bin/activate && \
		cd ../open-data/ckan/ && \
		pip install -r requirements.txt && \
		pip install -r dev-requirements.txt && \
		python setup.py develop && \
		find . -name "*.pyc" -exec rm -rf {} \;

down-venv:
	rm -R ${VENV_PATH}

rebuild-venv: down-venv build-venv
