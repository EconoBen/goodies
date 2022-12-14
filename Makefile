.ONESHELL:
.DELETE_ON_ERROR:

SHELL := /bin/bash

.PHONY: activate requirements integration run build tests


activate:
	@echo "Connecting pyenv & poetry..."
	poetry config virtualenvs.in-project true && \
	poetry env use $$(pyenv which python) && \
	poetry config virtualenvs.prefer-active-python true
	@echo "Done!"

requirements:
	poetry export -f requirements.txt --without-hashes | cut -f1 -d\; > requirements.txt


integration:
	export ENV=INTEGRATION && \
	poetry run uvicorn app.main:app --host localhost --reload

build:
	docker build -f ./Dockerfile -t goodies .

run: build
	docker run --env-file ./app/.integration.env --rm -it --name goodies -p 8000:8000 goodies

tests:
	poetry run black ./ && \
	poetry run isort ./ && \
	poetry run pytest ./app/
