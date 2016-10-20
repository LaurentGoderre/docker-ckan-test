#!/bin/sh
export PROJECT_NAME=ckan

export SOLR_CONTAINER=${PROJECT_NAME}_solr_1
export POSTGRES_CONTAINER=${PROJECT_NAME}_postgres_1

export CONFIG = ../open-data/ckan/test-core.ini
export VENV_PATH = ./.venv-${PROJECT_NAME}

default: up

init: build init-postgres set-permissions-postgress

build: build-postgres build-solr

rebuild: down up

up:
	docker-compose -p ${PROJECT_NAME} up -d

stop:
	docker-compose -p ${PROJECT_NAME} stop

down:
	docker-compose -p ${PROJECT_NAME} down

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
	docker-compose -p ${PROJECT_NAME} up -d postgres

stop-postgres:
	docker-compose -p ${PROJECT_NAME} stop postgres

down-postgres:
	docker-compose -p ${PROJECT_NAME} down postgres
# Solr Config
build-solr: up-solr
	#docker exec -it --user=solr ${SOLR_CONTAINER} \
	#	/docker-entrypoint-initsolr.d/create-core.sh
	docker exec -it ${SOLR_CONTAINER} \
		/docker-entrypoint-initsolr.d/create-core-old.sh
	while ! docker logs ${SOLR_CONTAINER} | grep "Started"; \
			do sleep 0.1; \
		done

rebuild-solr: down-solr build-solr

up-solr:
	docker-compose -p ${PROJECT_NAME} up -d solr

stop-solr:
	docker-compose -p ${PROJECT_NAME} stop solr

down-solr:
	docker-compose -p ${PROJECT_NAME} down solr

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
