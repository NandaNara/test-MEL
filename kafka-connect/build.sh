confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:latest
confluent-hub install --no-prompt confluentinc/kafka-connect-hdfs3:1.1.18

mkdir ~/connector 
mkdir /usr/share/java/kafka-connect-mqtt

wget https://github.com/lensesio/stream-reactor/releases/download/3.0.1/kafka-connect-mqtt-3.0.1-2.5.0-all.tar.gz -O ~/connector.tar.gz \
	&& tar -xzf ~/connector.tar.gz -C ~/connector \
	&& rm -rf ~/connectot.tar.gz

mv ~/connector/* /usr/share/java/kafka-connect-mqtt/
