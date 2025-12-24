# Etapa 1: Build - Compilar la aplicación
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración de Maven
COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .
COPY mvnw.cmd .

# Descargar dependencias (esto se cachea si pom.xml no cambia)
RUN mvn dependency:go-offline -B

# Copiar el código fuente
COPY src ./src

# Compilar la aplicación y crear el JAR
RUN mvn clean package -DskipTests

# Etapa 2: Runtime - Ejecutar la aplicación
FROM eclipse-temurin:17-jre-alpine

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar el JAR compilado desde la etapa de build
COPY --from=build /app/target/*.jar app.jar

# Exponer el puerto (Render usa la variable PORT)
EXPOSE 8080

# Variables de entorno por defecto
ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_OPTS="-Xms256m -Xmx512m -Djava.security.egd=file:/dev/./urandom"

# Ejecutar la aplicación
# Render establece la variable PORT automáticamente
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dserver.port=${PORT:-8080} -jar app.jar"]
