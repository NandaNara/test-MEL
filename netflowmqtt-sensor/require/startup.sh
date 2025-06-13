#!/bin/sh

cd /root/CICFlowMeter-4.0/bin

echo
rm -rf logs
./CICFlowMeter $NETINT $MQTT_HOST $MQTT_PORT $MQTT_TOPIC
