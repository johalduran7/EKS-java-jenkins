FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/app-book*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
