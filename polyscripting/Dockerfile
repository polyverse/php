FROM golang

COPY ./src/tokenizer/ /polyscripting/src/
COPY ./scripts /polyscripting/scripts/

COPY ./src/scrambler/* /go/src/github.com/polyverse/scrambler/

WORKDIR  /go/src/github.com/polyverse/scrambler
RUN GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o /polyscripting/src/php-scrambler
