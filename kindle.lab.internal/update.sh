#!/bin/bash

HA_API_KEY="xxxxxx"
HA_API_URL="https://homeassistant.lab.internal/api"

batChargedPercentage=$(curl -sk -H "Authorization: Bearer $HA_API_KEY" $HA_API_URL/states/sensor.sn_30xxxxxxxx_battery_soc_total | jq -r ".state")

batDischarge=$(curl -sk -H "Authorization: Bearer $HA_API_KEY" $HA_API_URL/states/sensor.sn_30xxxxxxxx_battery_power_discharge_total | jq -r ".state")
batCharge=$(curl -sk -H "Authorization: Bearer $HA_API_KEY" $HA_API_URL/states/sensor.sn_30xxxxxxxx_battery_power_charge_total | jq -r ".state")
batChangeW=$(($batCharge-$batDischarge))
if [[ $batChangeW -gt 0 ]]; then
    batChangeW="+$batChangeW"
fi

genAC=$(curl -sk -H "Authorization: Bearer $HA_API_KEY" $HA_API_URL/states/sensor.sn_30xxxxxxxx_pv_power | jq -r ".state")
currentConsumption=$(curl -sk -H "Authorization: Bearer $HA_API_KEY" $HA_API_URL/states/sensor.home_energy_usage_watt | jq -r ".state")
# cut the .0
currentConsumption=${currentConsumption%.*} 

# Using data from HomeAssistent because we can not use the API twice. Rate Limited
temperaturOutside=$(curl -sk -H "Authorization: Bearer $HA_API_KEY" $HA_API_URL/states/sensor.e3_vitocal_aussentemperatur | jq -r ".state")
temperaturWarmwater=$(curl -sk -H "Authorization: Bearer $HA_API_KEY" $HA_API_URL/states/water_heater.e3_vitocal_warmwasser | jq -r ".attributes.current_temperature")
statusCompressor=$(curl -sk -H "Authorization: Bearer $HA_API_KEY" $HA_API_URL/states/binary_sensor.e3_vitocal_kompressor | jq -r ".state")
heatpumpEnergyConsumptionToday=$(curl -sk -H "Authorization: Bearer $HA_API_KEY" $HA_API_URL/states/sensor.e3_vitocal_energieverbrauch_heute | jq -r ".state")
heatpumpEnergyConsumptionToday_unit_of_measurement=$(curl -sk -H "Authorization: Bearer $HA_API_KEY" $HA_API_URL/states/sensor.e3_vitocal_energieverbrauch_heute | jq -r ".attributes.unit_of_measurement")
if [ "$statusCompressor" = "off" ]; then
	statusCompressor="AUS"
else
	statusCompressor="AN"
fi

cp index.html.template index.html.prep
sed -i "s/###currentConsumption###/$currentConsumption/g" index.html.prep
sed -i "s/###batChargedPercentage###/$batChargedPercentage/g" index.html.prep
sed -i "s/###batChangeW###/$batChangeW/g" index.html.prep
sed -i "s/###genAC###/$genAC/g" index.html.prep

sed -i "s/###temperaturOutside###/$temperaturOutside/g" index.html.prep
sed -i "s/###temperaturWarmwater###/$temperaturWarmwater/g" index.html.prep
sed -i "s/###statusCompressor###/$statusCompressor/g" index.html.prep
sed -i "s/###heatpumpEnergyConsumptionToday###/$heatpumpEnergyConsumptionToday/g" index.html.prep
sed -i "s/###heatpumpEnergyConsumptionToday_unit_of_measurement###/$heatpumpEnergyConsumptionToday_unit_of_measurement/g" index.html.prep


rm -rf index.html
mv index.html.prep index.html