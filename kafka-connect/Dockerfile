FROM confluentinc/cp-kafka-connect:7.2.1

COPY build.sh .

RUN sh ~/build.sh && rm -f ~/build.sh
