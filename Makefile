SHELL := /bin/bash
.PHONY: *

service:
	./toy-service/entrypoint.sh


opsgenie:
	. init.sh && \
	terraform init && \
	terraform apply

opsgenie-destroy:
	. init.sh && \
	terraform apply -destroy
