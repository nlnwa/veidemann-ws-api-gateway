FROM golang:1.10.0

RUN apt-get update && apt-get install -y --no-install-recommends \
		unzip \
	&& rm -rf /var/lib/apt/lists/*

COPY . /go/src/github.com/nlnwa/veidemann-ws-api-gateway

RUN cd /go/src/github.com/nlnwa/veidemann-ws-api-gateway \
 && go generate \
 && CGO_ENABLED=0 go build -tags netgo


FROM alpine:3.7

LABEL maintainer="Norsk nettarkiv"
EXPOSE 3010
ENV CONTROLLER_HOST=localhost CONTROLLER_PORT=50051 PATH_PREFIX=/api

COPY --from=0 /go/src/github.com/nlnwa/veidemann-ws-api-gateway/veidemann-ws-api-gateway /
COPY --from=0 /go/src/github.com/nlnwa/veidemann-ws-api-gateway/html /html

ENTRYPOINT exec /veidemann-ws-api-gateway -logtostderr -path_prefix ${PATH_PREFIX} -controller_endpoint ${CONTROLLER_HOST}:${CONTROLLER_PORT}
