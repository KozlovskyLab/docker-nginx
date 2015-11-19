all: build

build:
	@docker build -t ${USER}/nginx -—no-cache .
