APP      := $(shell basename $(shell git remote get-url origin))
REGISTRY ?= serg267
VERSION  := $(shell (git describe --tags --abbrev=0 2>/dev/null || echo v0.0.0))-$(shell git rev-parse --short HEAD)

# За замовчуванням беремо хостові GOOS/GOARCH
TARGETOS  ?= $(shell go env GOOS)
TARGETARCH?= $(shell go env GOARCH)

IMAGE_TAG := $(REGISTRY)/$(APP):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

format:
	gofmt -s -w ./

lint:
	golint ./...

test:
	go test -v ./...

get:
	go get ./...

build:
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) \
		go build -v -o kbot \
		-ldflags "-X=github.com/tkachsi/kbot/cmd.appVersion=$(VERSION)"

image:
	docker build \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		-t $(IMAGE_TAG) .

push:
	docker push $(IMAGE_TAG)

clean:
	rm -rf kbot
	- docker rmi $(IMAGE_TAG) 2>/dev/null || true

help:
	@echo "Usage:"
	@echo "  make build TARGETOS=linux TARGETARCH=amd64"
	@echo "  make image TARGETOS=darwin TARGETARCH=arm64"
	@echo "  make push"
