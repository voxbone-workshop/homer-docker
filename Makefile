build:
	docker build --tag="sipcapture/homer-docker:latest" ./everything

run:
	docker run -dt --name homer5 -p 80:80 -p 9060:9060/udp sipcapture/homer-docker:latest

run-container:
	docker run -tid --name homer5 -p 80:80 -p 9060:9060/udp sipcapture/homer-docker

test:
	curl localhost

.PHONY: install build run test clean
