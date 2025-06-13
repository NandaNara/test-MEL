#!/bin/sh

# Install required package
apk update
apk add libpcap libpcap-dev

# Gain Access
chmod -R 775 /root/CICFlowMeter-4.0
chmod -R 775 /root/startup.sh
