import requests
import json
import time

def get_location():
    for i in range(5):
        try:
            # Ping location API with Timeout
            response = requests.get("http://ip-api.com/json/",timeout=5)
            
            # Check HTTP status
            if response.status_code != 200:
                raise Exception(f"HTTP {response.status_code}")
            
            data = response.json()

            # Make sure keys exist before returning
            if "lat" in data and "lon" in data:
                return data["lat"], data["lon"]

        except Exception as e:
            print("Location request failed:", e)
    return


def get_timezone():
    for i in range(5):
        try:
            #Ping Timezone API with Timeout
            response = requests.get("http://ip-api.com/json/",timeout=5)
            
            # Check HTTP status
            if response.status_code != 200:
                raise Exception(f"HTTP {response.status_code}")
            
            data = response.json()

            if "timezone" in data:
                return data["timezone"]

        except Exception as e:
            print("Timezone request failed:", e)
    return

def api_url_gen(latitude, longitude, timezone):
    return (
        f"https://api.open-meteo.com/v1/forecast?"
        f"latitude={latitude}&longitude={longitude}"
        f"&hourly=temperature_2m"
        f"&daily=sunrise,sunset"
        f"&forecast_days=2"
        f"&timezone={timezone}"
    )

def get_weather_data(api_url):
    """
    Fetches weather data from the API (single attempt).
    Returns data on success, None on failure.
    """    
    response = None
    try:
        print(f"Calling Weather API")
        
        
        # Ping weather data API with timeout
        response = requests.get(api_url,timeout=5)
        
        # Check HTTP status
        if response.status_code != 200:
            raise Exception(f"HTTP {response.status_code}")
        
        data = response.json()
        return data
        
    except Exception as e:
        print(f"Weather API error: {e}")
        return None  
        
    finally:
        if response:
            response.close()

def get_sunrise_time(data):
    sunrise = data['daily']['sunrise'][1].split("T")
    sunrise_time = sunrise[1]
    sunrise_min_hour = sunrise_time[:5]
    return sunrise_min_hour

def weather_message(MESSAGE):
    try:
        response = requests.post(
            "https://ntfy.sh/charitylane_greenhouse",
            data=MESSAGE.encode("utf-8"),
            headers={"Content-Type": "text/plain"},
        )
        response.close()
    except Exception as e:
        print("Error sending notification:", e)

def main():
    latitude, longitude = get_location()
    timezone = get_timezone()
    api_url = api_url_gen(latitude,longitude,timezone)
    weather_data = get_weather_data(api_url)
    sunrise = get_sunrise_time(weather_data)
    print(f"Sunrise time is: {sunrise}")

if __name__ == "__main__":
    main()
