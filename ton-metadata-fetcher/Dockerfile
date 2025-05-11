FROM golang:bookworm as builder

WORKDIR /go/applications

ADD . /go/applications/

RUN go build -o ton-metadata-fetcher

FROM ubuntu:jammy
RUN apt-get update && apt install --yes bash curl && rm -rf /var/lib/apt/lists/*

COPY --from=builder /go/applications/ton-metadata-fetcher /usr/local/bin/ton-metadata-fetcher

CMD ["ton-metadata-fetcher"]
