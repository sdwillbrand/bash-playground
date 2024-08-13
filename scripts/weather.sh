#!/bin/bash

# Function to handle API errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Get the public IP address
ip=$(curl -s 'https://api.ipify.org?format=json') || handle_error "Failed to retrieve IP address"
ip_address=$(echo "$ip" | jq -r .ip) || handle_error "Failed to parse IP address"

# Validate IP address
if [[ -z "$ip_address" ]]; then
    handle_error "IP address is empty."
fi

# Get the latitude and longitude for the IP address
res=$(curl -s "http://ip-api.com/json/$ip_address") || handle_error "Failed to retrieve location data"
lat=$(echo "$res" | jq -r .lat)
lon=$(echo "$res" | jq -r .lon)

# Validate latitude and longitude
if [[ -z "$lat" || -z "$lon" ]]; then
    handle_error "Latitude or longitude is empty."
fi

# Fetch weather data using latitude and longitude
res=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m,relative_humidity_2m,precipitation&forecast_days=1&timezone=Europe%2FBerlin") || handle_error "Failed to retrieve weather data"

# Get the current temperature
temperature=$(echo "$res" | jq -r .current_weather.temperature)

# Display current weather
echo -e "Temperature:\t${temperature}°C"

# Extract hourly data
readarray -t temperatures < <(echo "$res" | jq -r .hourly.temperature_2m[])
readarray -t times < <(echo "$res" | jq -r .hourly.time[])
readarray -t humidities < <(echo "$res" | jq -r .hourly.relative_humidity_2m[])

# Loop through the arrays and print the formatted output
for ((i = 0; i < ${#times[@]}; i++)); do
    formatted_time=$(date -j -f "%Y-%m-%dT%H:%M" "${times[i]}" +"%H:%M")
    echo "${formatted_time} Uhr: ${temperatures[i]}°C, Humidity: ${humidities[i]}%"
done
