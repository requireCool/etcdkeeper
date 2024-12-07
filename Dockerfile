FROM golang:1.20-alpine AS build

ENV GO111MODULE on

WORKDIR /opt
RUN mkdir etcdkeeper
COPY . /opt/etcdkeeper
WORKDIR /opt/etcdkeeper/src/etcdkeeper

RUN go mod download \
    && go build -o etcdkeeper.bin main.go


FROM alpine:3.10

ENV HOST="0.0.0.0"
ENV PORT="8080"

# RUN apk add --no-cache ca-certificates

RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

WORKDIR /opt/etcdkeeper
COPY --from=build /opt/etcdkeeper/src/etcdkeeper/etcdkeeper.bin .
COPY assets assets

EXPOSE ${PORT}

CMD ./etcdkeeper.bin -h $HOST -p $PORT
