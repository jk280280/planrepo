# Base image for building the application
FROM maven:3.8.6-openjdk-17 AS build

# Set working directory
WORKDIR /app

# Copy pom.xml and download dependencies (caching)
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the entire project and build
COPY . .
RUN mvn clean package -DskipTests

# -------------------------------
# Runtime Image
# -------------------------------
FROM openjdk:17-jdk-slim AS production

# Set working directory
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the application port
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]

# -------------------------------
# Development Image
# -------------------------------
FROM openjdk:17-jdk-slim AS dev

# Set working directory
WORKDIR /app

# Install Maven for development builds
RUN apt-get update && apt-get install -y maven

# Copy the application source code for hot reload
COPY . .

# Expose the application port
EXPOSE 8080

# Run the application with Maven (useful for development mode)
CMD ["mvn", "spring-boot:run"]
