# BUILD Stages
## build core functionality
FROM ubuntu:24.04 AS core-builder
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get update -y && apt-get -y install tzdata && rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN apt-get update -y \
    && apt-get install -y build-essential cmake clang-20 openssl libssl-dev zlib1g-dev \
                   gperf wget git curl ccache libmicrohttpd-dev liblz4-dev \
                   pkg-config libsecp256k1-dev libsodium-dev libhiredis-dev python3-dev libpq-dev \
                   automake libjemalloc-dev lsb-release software-properties-common gnupg \
                   autoconf libtool \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/
COPY ion-index-worker/external/ /app/external/
COPY ion-index-worker/pgion/ /app/pgion/
COPY ion-index-worker/celldb-migrate/ /app/celldb-migrate/
COPY ion-index-worker/ion-index-clickhouse/ /app/ion-index-clickhouse/
COPY ion-index-worker/ion-index-postgres/ /app/ion-index-postgres/
COPY ion-index-worker/ion-integrity-checker/ /app/ion-integrity-checker/
COPY ion-index-worker/ion-smc-scanner/ /app/ion-smc-scanner/
COPY ion-index-worker/ion-trace-emulator/ /app/ion-trace-emulator/
COPY ion-index-worker/ion-trace-task-emulator/ /app/ion-trace-task-emulator/
COPY ion-index-worker/iondb-scanner/ /app/iondb-scanner/
COPY ion-index-worker/ion-marker/ /app/ion-marker/
COPY ion-index-worker/CMakeLists.txt /app/

WORKDIR /app/build
ENV CC=clang-20
ENV CXX=clang++-20
RUN touch /app/suppression_mappings.txt && cmake -DCMAKE_BUILD_TYPE=Release -DION_USE_JEMALLOC=ON -DPORTABLE=1 .. && make -j$(nproc) ion-index-postgres ion-index-postgres-migrate ion-index-clickhouse ion-smc-scanner \
     ion-integrity-checker ion-trace-emulator ion-trace-task-emulator ion-marker-cli ion-marker-core ion-marker


## build index api service ion-index-go
FROM golang:trixie AS index-api-builder

RUN apt-get update -y \
    && apt install -y dnsutils libpq-dev libsecp256k1-dev libsodium-dev libhiredis-dev \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN go install github.com/swaggo/swag/cmd/swag@latest

ADD ion-index-go/index/ /go/app/index/
ADD ion-index-go/main.go /go/app/main.go
ADD ion-index-go/go.mod /go/app/go.mod
ADD ion-index-go/go.sum /go/app/go.sum
COPY --from=core-builder /app/build/ion-marker/libion-marker* /usr/lib/
COPY --from=core-builder /app/ion-marker/src/wrapper.h /usr/local/include/wrapper.h
RUN cd /go/app && swag init && go build -o ion-index-go ./main.go


## build emulate api service ion-emulate-go
FROM golang:trixie AS emulate-api-builder

RUN apt-get update -y \
    && apt install -y dnsutils libpq-dev libsecp256k1-dev libsodium-dev libhiredis-dev \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN go install github.com/swaggo/swag/cmd/swag@latest

ADD ion-index-go/ /go/ion-index-go/
ADD ion-emulate-go/models/ /go/app/models/
ADD ion-emulate-go/main.go /go/app/main.go
ADD ion-emulate-go/go.mod /go/app/go.mod
ADD ion-emulate-go/go.sum /go/app/go.sum
COPY --from=core-builder /app/build/ion-marker/libion-marker* /usr/lib/
COPY --from=core-builder /app/ion-marker/src/wrapper.h /usr/local/include/wrapper.h
RUN cd /go/app && swag init && go build -o ion-emulate-go ./main.go

## build metadata cache service ion-metadata-cache
FROM golang:trixie AS metadata-cache-builder

RUN apt-get update -y \
    && apt install -y dnsutils libpq-dev libsecp256k1-dev libsodium-dev libhiredis-dev \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN go install github.com/swaggo/swag/cmd/swag@latest

ADD ion-index-go/ /go/ion-index-go/
ADD ion-metadata-cache/cache/ /go/app/cache/
ADD ion-metadata-cache/repl/ /go/app/repl/
ADD ion-metadata-cache/models/ /go/app/models/
ADD ion-metadata-cache/loader/ /go/app/loader/
ADD ion-metadata-cache/main.go /go/app/main.go
ADD ion-metadata-cache/db.go /go/app/db.go
ADD ion-metadata-cache/handler.go /go/app/handler.go
ADD ion-metadata-cache/go.mod /go/app/go.mod
ADD ion-metadata-cache/go.sum /go/app/go.sum
COPY --from=core-builder /app/build/ion-marker/libion-marker* /usr/lib/
COPY --from=core-builder /app/ion-marker/src/wrapper.h /usr/local/include/wrapper.h
RUN cd /go/app && go build -o ion-metadata-cache .


## build metadata fetcher service ion-metadata-fetcher
FROM golang:trixie AS metadata-fetcher-builder

ADD ion-metadata-fetcher/images.go /go/app/images.go
ADD ion-metadata-fetcher/ipfs.go /go/app/ipfs.go
ADD ion-metadata-fetcher/main.go /go/app/main.go
ADD ion-metadata-fetcher/overrides.go /go/app/overrides.go
ADD ion-metadata-fetcher/go.mod /go/app/go.mod
ADD ion-metadata-fetcher/go.sum /go/app/go.sum

WORKDIR /go/app
RUN go build -o ion-metadata-fetcher ./*.go


# IMAGE stages
## index worker service image
FROM ubuntu:24.04 AS index-worker
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get update -y && apt-get -y install tzdata && rm -rf /var/lib/{apt,dpkg,cache,log}/
RUN apt-get update -y \
    && apt install -y dnsutils libpq5 libsecp256k1-1 libsodium23 libhiredis1.1.0 \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY ion-index-worker/scripts/entrypoint.sh /app/entrypoint.sh
COPY --from=core-builder /app/build/ion-index-postgres/ion-index-postgres /usr/bin/ion-index-postgres
COPY --from=core-builder /app/build/ion-index-postgres/ion-index-postgres-migrate /usr/bin/ion-index-postgres-migrate
COPY --from=core-builder /app/build/ion-index-clickhouse/ion-index-clickhouse /usr/bin/ion-index-clickhouse
COPY --from=core-builder /app/build/ion-smc-scanner/ion-smc-scanner /usr/bin/ion-smc-scanner
COPY --from=core-builder /app/build/ion-integrity-checker/ion-integrity-checker /usr/bin/ion-integrity-checker
COPY --from=core-builder /app/build/ion-trace-emulator/ion-trace-emulator /usr/bin/ion-trace-emulator
COPY --from=core-builder /app/build/ion-trace-task-emulator/ion-trace-task-emulator /usr/bin/ion-trace-task-emulator
COPY --from=core-builder /app/build/ion-marker/libion-marker* /usr/lib/
COPY --from=core-builder /app/build/ion-marker/ion-marker-cli /usr/bin/ion-marker-cli

ENTRYPOINT [ "/app/entrypoint.sh" ]


## index api service image
FROM ubuntu:24.04 AS index-api
RUN apt-get update \
    && apt install --yes dnsutils libpq5 libsecp256k1-1 libsodium23 libhiredis1.1.0 \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY --from=core-builder /app/build/ion-marker/libion-marker* /usr/lib/
COPY --from=index-api-builder /go/app/ion-index-go /usr/local/bin/ion-index-go
COPY ion-index-go/entrypoint.sh /app/entrypoint.sh

ENTRYPOINT [ "/app/entrypoint.sh" ]


## emulate api service image
FROM ubuntu:24.04 AS emulate-api
RUN apt-get update \
    && apt install --yes curl dnsutils libpq5 libsecp256k1-1 libsodium23 libhiredis1.1.0 \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY --from=core-builder /app/build/ion-marker/libion-marker* /usr/lib/
COPY --from=emulate-api-builder /go/app/ion-emulate-go /usr/local/bin/ion-emulate-go
COPY ion-emulate-go/entrypoint.sh /app/entrypoint.sh

ENTRYPOINT [ "/app/entrypoint.sh" ]

## metadata cache service image
FROM ubuntu:24.04 AS metadata-cache
RUN apt-get update \
    && apt install --yes curl dnsutils libpq5 libsecp256k1-1 libsodium23 libhiredis1.1.0 \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY --from=core-builder /app/build/ion-marker/libion-marker* /usr/lib/
COPY --from=metadata-cache-builder /go/app/ion-metadata-cache /usr/local/bin/ion-metadata-cache
COPY ion-metadata-cache/entrypoint.sh /app/entrypoint.sh

ENTRYPOINT [ "/app/entrypoint.sh" ]


## metadata fetcher service image
FROM ubuntu:24.04 AS metadata-fetcher
RUN apt-get update && apt install --yes curl && rm -rf /var/lib/apt/lists/*

COPY --from=metadata-fetcher-builder /go/app/ion-metadata-fetcher /usr/local/bin/ion-metadata-fetcher
COPY ion-metadata-fetcher/entrypoint.sh /app/entrypoint.sh
COPY ion-metadata-fetcher/metadata_overrides.json /app/metadata_overrides.json

ENTRYPOINT [ "/app/entrypoint.sh" ]


## classifier service image
FROM python:3.12-trixie AS classifier
ADD indexer/requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --no-cache-dir -r /tmp/requirements.txt
COPY indexer/ /app/
COPY indexer/files/* /app

WORKDIR /app
ENV C_FORCE_ROOT=1
ENTRYPOINT [ "/app/entrypoint.sh" ]
