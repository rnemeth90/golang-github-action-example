OWNER := rnemeth90
PROJECT := golang-github-action-example
VERSION := 1.0.0
OPV := $(OWNER)/$(PROJECT):$(VERSION)
WEBPORT := 8080:8080

# you may need to change to "sudo docker" if not a member of 'docker' group
DOCKERCMD := "docker"

BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')
# unique id from last git commit
MY_GITREF := $(shell git rev-parse --short HEAD)

BUILT_BY := Dockerfile
BUILD_ARGS := --build-arg MY_VERSION=$(VERSION) --build-arg MY_BUILTBY=$(BUILT_BY)

## builds docker image
docker-build:
	echo MY_GITREF is $(MY_GITREF)
	$(DOCKERCMD) build $(BUILD_ARGS) -f Dockerfile -t $(OPV) .

docker-builder-then-stop:
	echo MY_GITREF is $(MY_GITREF)
	$(DOCKERCMD) build --target builder $(BUILD_ARGS) -f Dockerfile -t $(OPV) .

## cleans docker image
clean:
	$(DOCKERCMD) image rm $(OPV) | true

## runs container in foreground
docker-test-fg:
	$(DOCKERCMD) run -it -p $(WEBPORT) --rm $(OPV)

docker-hub-pull-latest:
	git describe --tags
	docker pull $(OWNER)/$(PROJECT):latest
	$(DOCKERCMD) run -it -p $(WEBPORT) --rm $(OWNER)/$(PROJECT):latest

## runs container in foreground, override entrypoint to use use shell
docker-test-cli:
	$(DOCKERCMD) run -it --rm --entrypoint "/bin/sh" $(OPV)

## run container in background
docker-run-bg:
	$(DOCKERCMD) run -d -p $(WEBPORT) --rm --name $(PROJECT) $(OPV)

## get into console of container running in background
docker-cli-bg:
	$(DOCKERCMD) exec -it $(PROJECT) /bin/sh

## tails $(DOCKERCMD)logs
docker-logs:
	$(DOCKERCMD) logs -f $(PROJECT)

## stops container running in background
docker-stop:
	$(DOCKERCMD) stop $(PROJECT)

## pushes to $(DOCKERCMD)hub
docker-push:
	$(DOCKERCMD) push $(OPV)

# test source program build from host (must have GoLang installed)
golang-build-local:
	mkdir -p build
	cp src/main.go build/main.go
	cd build && \
	[ -f go.mod ] || go mod init $(OWNER)/$(PROJECT) && \
	go mod tidy && \
	go build -ldflags "-X main.Version=$(VERSION) -X main.BuiltBy=makefile" main.go

## pushes to kubernetes cluster
k8s-apply:
	sed -e 's/1.0.0/$(VERSION)/' golang-signal-web.yaml | kubectl apply -f -

k8s-delete:
	kubectl delete -f golang-signal-web.yaml

