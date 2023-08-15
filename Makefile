SHELL := /bin/bash
.PHONY: *

all:
	echo "Please make a specific target"; exit 1

toy-service:
	. init.sh && \
	./toy-service/entrypoint.sh

opsgenie:
	. init.sh && \
	terraform init && \
	terraform apply

opsgenie-destroy:
	. init.sh && \
	terraform apply -destroy
