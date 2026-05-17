FROM golang:1.25-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
COPY ./products.json /products.json
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o productcatalogservice .

RUN wget -qO /grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v0.4.28/grpc_health_probe-linux-amd64 && chmod +x /grpc_health_probe

FROM alpine:3.19

WORKDIR /app
RUN apk add --no-cache ca-certificates

COPY --from=builder /app/productcatalogservice .
COPY --from=builder /app/products.json .
COPY --from=builder /grpc_health_probe /bin/grpc_health_probe

EXPOSE 3550
CMD ["./productcatalogservice"]
