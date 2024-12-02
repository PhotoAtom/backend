FROM eclipse-temurin:21.0.2_13-jdk-jammy AS build

WORKDIR /app/build

COPY . .

RUN ./mvnw package

FROM eclipse-temurin:21.0.2_13-jdk-jammy AS target

WORKDIR /app

# Valkey Environment Variables
ENV VALKEY_CA_CERT_PATH=''
ENV VALKEY_CA_CERT_PASSWORD=''
ENV VALKEY_USER_CERT_PATH=''
ENV VALKEY_USER_CERT_PASSWORD=''
ENV VALKEY_PASSWORD=''
ENV VALKEY_HOST=''
ENV VALKEY_PORT=''

# PostgreSQL Environment Variables
ENV POSTGRES_HOST=''
ENV POSTGRES_USERNAME=''
ENV POSTGRES_PASSWORD=''
ENV PSQL_CA_CERT_PATH=''
ENV PSQL_USER_CERT_PATH=''
ENV PSQL_USER_CERT_KEY_PATH=''

# Keycloak Environment Variables
ENV KEYCLOAK_URL=''
ENV KEYCLOAK_CA_CERT_PATH=''
ENV KEYCLOAK_CA_CERT_PASSWORD=''
ENV KEYCLOAK_USER_CERT_PATH=''
ENV KEYCLOAK_USER_CERT_PASSWORD=''

COPY --from=build /app/build/target/backend-*.jar backend.jar

EXPOSE 8080

ENTRYPOINT [ "java", "-jar", "backend.jar" ]