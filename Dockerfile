FROM openjdk:8-alpine3.9
MAINTAINER naresh240.qis@gmail.com
COPY ./target/gs-spring-boot-0.1.0.jar app.jar
ENTRYPOINT java -jar app.jar