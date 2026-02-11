# ---- build stage ----
FROM maven:3.9.3-eclipse-temurin-17 AS build
WORKDIR /app

# copy maven wrapper + pom first for efficient caching
COPY mvnw pom.xml ./
COPY .mvn .mvn

# copy source
COPY src src

# build jar (skip tests to speed up)
RUN chmod +x ./mvnw && ./mvnw -DskipTests package -Pprod

# ---- runtime stage ----
FROM eclipse-temurin:17-jre
WORKDIR /app

# copy artifact
COPY --from=build /app/target/*.jar app.jar

ENV JAVA_OPTS=""

# Render sets PORT env variable; expose for clarity
EXPOSE 8080

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar /app/app.jar"]
