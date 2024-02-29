TARGET_FILE:=${shell head -n1 go.mod | sed -r 's/.\/(.)/\1/g'}
BUILD_DIR=.build
COVER_PROFILE_FILE="${BUILD_DIR}/go-cover.tmp"
GOENV=GOPRIVATE=$(GOPRIVATE) GOOS=${OS} GOARCH=${ARCH}

install:
	go env -w GOPROXY=https://proxy.golang.org
	go env -w CGO_ENABLED="1"
	go env -w GOPRIVATE=github.com/dock-tech,github.com/cdt-baas
	go env -w GO111MODULE='on'
	go env -w GOBIN=${GOPATH}/bin
	go mod download -x
	go mod tidy

install-local:
	brew tap aws/tap
	brew list aws-sam-cli || brew_install install aws-sam-cli

sam-build:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0  sam build -t cloudformation/template/local/template.yaml

invoke-lambda:
	sam local invoke OTELFunction -e cmd/events/event.json

invoke-api:
	sam local start-api

local-build: build-OTELFunction zip sam-build


build-OTELFunction:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o bootstrap -ldflags  '-extldflags "-static"' ./cmd/main.go

zip:
	zip package bootstrap