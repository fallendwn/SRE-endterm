
FROM golang:1.26.2-alpine AS builder

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /app/frontend

FROM alpine:3.20

RUN apk add --no-cache curl

WORKDIR /app

COPY --from=builder /app/frontend /app/frontend
COPY ./templates ./templates
COPY ./static ./static

EXPOSE 8080

ENTRYPOINT ["/app/frontend"]