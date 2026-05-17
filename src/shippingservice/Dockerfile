FROM golang:1.26.2-alpine AS builder

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download
COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o /go/bin/shippingservice .

RUN wget -qO /grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v0.4.28/grpc_health_probe-linux-amd64 && chmod +x /grpc_health_probe

FROM alpine:3.19

RUN apk add --no-cache ca-certificates

WORKDIR /src
COPY --from=builder /go/bin/shippingservice /src/shippingservice
COPY --from=builder /grpc_health_probe /bin/grpc_health_probe

ENV APP_PORT=50051
ENV GOTRACEBACK=single

EXPOSE 50051
ENTRYPOINT ["/src/shippingservice"]
