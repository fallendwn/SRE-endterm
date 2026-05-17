FROM eclipse-temurin:24.0.2_12-jdk-noble AS builder

WORKDIR /app

COPY ["build.gradle", "gradlew", "./"]
COPY gradle gradle
RUN chmod +x gradlew
RUN ./gradlew downloadRepos

COPY . .
RUN chmod +x gradlew
RUN ./gradlew installDist

RUN apt-get update && apt-get install -y --no-install-recommends wget && rm -rf /var/lib/apt/lists/* \
    && wget -qO /grpc_health_probe https://github.com/grpc-ecosystem/grpc-health-probe/releases/download/v0.4.28/grpc_health_probe-linux-amd64 \
    && chmod +x /grpc_health_probe

FROM eclipse-temurin:25.0.2_10-jre-alpine

WORKDIR /app
COPY --from=builder /app .
COPY --from=builder /grpc_health_probe /bin/grpc_health_probe

EXPOSE 9555
ENTRYPOINT ["/app/build/install/hipstershop/bin/AdService"]
