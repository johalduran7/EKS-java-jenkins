#FROM eclipse-temurin:17-jre-alpine   # Problematic image to build, it gets stuck
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY build/libs/app-book-1.0.0.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
#if not specified here run: docker run -t -d -p 8080:8080 --entrypoint "java" --name app-booknoentry app-booknoentry -jar app.jar


