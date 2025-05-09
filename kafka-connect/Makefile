current_branch := $(shell git rev-parse --abbrev-ref HEAD)
build:
	docker build -t ryuk4/cp-kafka-connect:$(current_branch) ./
