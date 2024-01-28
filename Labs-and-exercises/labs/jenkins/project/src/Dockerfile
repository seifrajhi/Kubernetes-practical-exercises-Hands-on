FROM golang:1.17.1-alpine3.14 AS builder
ENV CGO_ENABLED=0

RUN apk --no-cache --no-progress add git ca-certificates tzdata make \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/*

WORKDIR /go/whoami
COPY go.mod .
RUN go mod download

COPY app.go .
RUN go build -o /out/whoami

# app
FROM scratch

ENTRYPOINT ["/app/whoami"]
EXPOSE 80

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

COPY --from=builder /out/whoami /app/
