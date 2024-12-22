# Build step, generating JAR file
FROM eclipse-temurin:21.0.2_13-jdk-jammy AS build

WORKDIR /app/build

COPY . .

RUN ./mvnw package

# Production step, building final image
FROM eclipse-temurin:21.0.2_13-jdk-jammy AS target

WORKDIR /app

ARG CUSTOM_GROUP=photoatom_group
ARG CUSTOM_GROUP_ID=1001
ARG CUSTOM_USER=photoatom
ARG CUSTOMER_USER_ID=1001

RUN groupadd -g ${CUSTOM_GROUP_ID} ${CUSTOM_GROUP} && \
  useradd -m -u ${CUSTOMER_USER_ID} -g ${CUSTOM_GROUP} ${CUSTOM_USER}

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

COPY --from=build /app/build/target/backend-*.jar backend.jar

USER ${CUSTOM_USER}
EXPOSE 8080

ENTRYPOINT [ "java", "-jar", "backend.jar" ]
