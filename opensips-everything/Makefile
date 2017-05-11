NAME ?= homer5
PARAMS ?= -E

all: build start run

.PHONY: build start run
build:
	docker build --tag="sipcapture/homer-docker-opensips:local" .

start:
	docker run -tid --name $(NAME) sipcapture/homer-docker-opensips:local $(PARAMS)
