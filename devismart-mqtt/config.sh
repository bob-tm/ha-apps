#!/bin/bash

cp /app/ha-devi-mqtt.jar /config
cd /config
java -cp ha-devi-mqtt.jar io.homeassistant.devi.mqtt.service.DiscoveryService
rm /config/ha-devi-mqtt.jar
