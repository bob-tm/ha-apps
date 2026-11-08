# Devireg Devismart MQTT Add-on for Danfoss equipment
Based on <https://github.com/igor-podpalchenko/ha-devi-mqtt> and my fork <https://github.com/bob-tm/ha-devi-mqtt>

Please read the original [README](https://github.com/igor-podpalchenko/ha-devi-mqtt/blob/main/README.md) for overview of how it works.

## Requirements
1. Home Assistant (HAOS install with Apps / Add-on support)
2. MQTT Integration
3. Home Assistant user account for MQTT access (you can create one below)

## How to Use 

1. Configure MQTT settings in add-on Add-on 'Configuration' tab.
For HA mosquitto add-on set host to `core-mosquitto` or local HA address (`192.168.x.x`) and add user and password (GUI user or `mqtt_config.json`). Version 0.3+ uses Home Assistant GUI users instead of `mqtt_config.json`.
If you have `mqtt_config.json` from early versions you can still use that, or you can delete it and create a Home Assistant GUI user instead.
(In Home Assistant GUI: Settings -> System -> People, create a username and password, only Local Network Access required.)
2. Start Devismart MQTT add-on. Check logs for message (`devi_config.json` not found. Running in waiting mode)
3. Create and install the `devi_config.json` file that the add-on needs to connect to Devi cloud, using one of the two methods described in the section below.
4. Restart Devismart MQTT add-on.
5. Check add-on logs for message (Config Exists!) or list of autodiscovered items.
6. Go to MQTT Integration and check for Devi devices!

## How to generate devi_config.json in version 0.3+
**IMPORTANT:** _When copying the One Time Password (OTP) from the Devi phone app to the add-on YOU MUST REMOVE THE HYPHENS and just enter the numbers. E.g. if the password is "123-456-7" in the Devi app, enter just "1234567"._

### Method 1: Inside App (preferred)
1. Install and Run Advanced SSH & Web Terminal (https://github.com/hassio-addons/addon-ssh)
2. Disable Protection mode Advanced SSH & Web Terminal (remember to reboot)
3. Click Open Web UI for Advanced SSH & Web Terminal
4. Enter in terminal `docker container ls -a | awk 'NR>1 {print $1, $2}' | grep 'devismart-mqtt'`
5. Look for CONTAINER ID for devismart-mqtt. Looks like `4b9fa34ad83e`
6. Replace `4b9fa34ad83e` with your id and Run  `docker exec -it 4b9fa34ad83e /config.sh`
7. Follow instructions on screen. `devi_config.json` should be saved to add-on config folder. In this step there was instructions inside SSH. The user name asked for is just for Devi and not related to HA or MQTT. The code from mobile app is input without hypens ("-"), so only numbers. I chose to give permission to delete thermostats when asked before creating the code. Took couple of tries but then it worked. And wait, at least for me this step took quite long. Finally there is a message that the config is added or something similar.

### Method 2: Needs Java to be installed on your computer
1. Open http://homeassistant:8000 and download `ha-devi-mqtt.jar` to your pc
2. Install Java
3. Run `java -cp ha-devi-mqtt.jar io.homeassistant.devi.mqtt.service.DiscoveryService` and follow the instructions. The user name asked for is just for Devi and not related to HA or MQTT. The code from mobile app is input without hypens ("-"), so only numbers. I chose to give permission to delete thermostats when asked before creating the code.
4. Upload `devi_config.json` to add-on config folder `addon_configs/xxxxxxxx_devismart-mqtt/devi_config.json` e.g. using Advanced SSH & Web Terminal with Production mode disabled (as described in Method 1), or `\\192.168.x.x\addon_configs\xxxxxxxx_devismart-mqtt\devi_config.json` if you have Samba share installed.

