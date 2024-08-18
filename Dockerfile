FROM openjdk:21

WORKDIR /cicd_test

COPY cicd_test-0.0.1-SNAPSHOT.jar app.jar

ENTRYPOINT ["java","-jar","app.jar"]