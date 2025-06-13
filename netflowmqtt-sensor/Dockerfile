FROM openjdk:8-jdk-alpine

COPY require /root

RUN sh /root/build.sh && rm -f /root/build.sh

EXPOSE 2101
ENTRYPOINT [ "./root/startup.sh" ]