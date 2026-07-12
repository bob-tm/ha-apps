#!/bin/bash

if [ -d "/config/auto-discovery-templates" ]; then
    echo "Custom templates"
    config_templates="/config/auto-discovery-templates"
else
    echo "Built in templates"
    config_templates="/app/auto-discovery-templates"
fi

if [ -e "/config/mqtt_config.json" ]; then
    echo "Using /config/mqtt_config.json"
	echo "Addon config params are ignored!"
	config_mqtt="/config/mqtt_config.json"
else
    echo "Using GUI MQTT config"
	config_mqtt="/data/options.json"
fi


if [ -e "/config/devi_config.json" ]; then
    echo "Config Exists!"
    exec java -cp ha-devi-mqtt.jar io.homeassistant.devi.mqtt.service.ConsoleRunner --auto-discovery-templates "$config_templates" --mqtt-config "$config_mqtt" --devi-config "/config/devi_config.json"
else
    echo "devi_config.json not found"
	echo "Running in waiting mode"
	echo "Use Advanced SSH & Web Terminal to generate devi_config.json"
	echo "See Addon documentation for details"
	exec python3 -m http.server 8000
fi


