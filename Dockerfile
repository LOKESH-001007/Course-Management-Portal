# ── Stage 1: Build the WAR with Maven ──────────────────────────────
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app
COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# ── Stage 2: Run on Tomcat ──────────────────────────────────────────
FROM tomcat:10.1-jdk17

# Remove default ROOT app and deploy ours as ROOT so it's served at "/"
RUN rm -rf /usr/local/tomcat/webapps/ROOT

COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
