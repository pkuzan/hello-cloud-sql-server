#!/bin/bash
#Rotate log by prepending the date on existing log
sudo mkdir -p /var/log/hello-cloud
if [ -f /var/log/hello-cloud/hello-cloud.log ]; then sudo mv /var/log/hello-cloud/hello-cloud.log "/var/log/hello-cloud/hello-cloud.log.$(date)" ; fi
sudo touch /var/log/hello-cloud/hello-cloud.log

cd ~/hellocloud
#Redirect STOUT and STERR and background
sudo java -jar pricer-core.jar > /dev/null 2>&1 &


