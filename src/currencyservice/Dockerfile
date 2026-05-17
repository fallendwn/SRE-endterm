FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./

RUN apk add --no-cache --virtual .build-deps \
    python3 \
    make \
    g++ \
    && npm install \
    && apk del .build-deps

COPY . .

FROM node:20-alpine

WORKDIR /app

RUN apk add --no-cache netcat-openbsd wget \
    && wget -qO /bin/grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v0.4.28/grpc_health_probe-linux-amd64 \
    && chmod +x /bin/grpc_health_probe

COPY --from=builder /app /app

ENV PORT=7000
EXPOSE 7000

CMD ["node", "server.js"]
