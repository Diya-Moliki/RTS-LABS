# Base build image
FROM golang:1.12-alpine AS build_base

# Install some dependencies needed to build the project
RUN apk add bash git zip 
WORKDIR /src

# Force the go compiler to use modules
ENV GO111MODULE=on
ENV GOOS=linux
ENV GOARCH=amd64
ENV CGO_ENABLED=0

# We want to populate the module cache based on the go.{mod,sum} files.
COPY go.mod .
COPY go.sum .

#This is the ‘magic’ step that will download all the dependencies that are specified in
# the go.mod and go.sum file.
# Because of how the layer caching system works in Docker, the  go mod download
# command will _ only_ be re-run when the go.mod or go.sum file change
# (or when we add another docker instruction this line)
RUN go mod download

FROM build_base AS server_builder
COPY . .
RUN go build -o sqs-cleanup main.go
RUN zip sqs-cleanup.zip sqs-cleanup
