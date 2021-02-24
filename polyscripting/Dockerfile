# Copyright (c) 2020 Polyverse Corporation
FROM golang

COPY src/transformer /polyscripting/
COPY scripts /polyscripting/
RUN go env -w GO111MODULE=auto



COPY ./src/scrambler/* /go/src/github.com/polyverse/scrambler/

WORKDIR  /go/src/github.com/polyverse/scrambler
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o /polyscripting/php-scrambler
