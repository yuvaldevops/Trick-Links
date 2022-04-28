import requests as requests
from flask import Flask, request, render_template
from datetime import datetime
import math

app = Flask(__name__)

appid = "7ba78a14d756da97dd070203e67a4242"
base_url = "http://api.openweathermap.org/data/2.5/"


@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        q = request.form['q']
        api_url1 = f"{base_url}forecast?q={q}&appid={appid}"
        response1 = requests.get(api_url1).json()
        if response1['cod'] != '200':
            return render_template('city_not_found.html')

        lat = str(response1['city']['coord']['lat'])
        lon = str(response1['city']['coord']['lon'])
        city = str(response1['city']['name'])
        country = str(response1['city']['country'])
        api_url2 = f"{base_url}onecall?lat={lat}&lon={lon}&units=metric&appid={appid}"
        response2 = requests.get(api_url2).json()
        print(response2["current"]["weather"][0]["icon"])
        current_day = response2["current"]
        current_date = datetime.today().strftime('%A')
        full_date = datetime.now().strftime("%Y-%m-%d")
        current_hour = datetime.now().strftime("%H:%M")
        current_weather = current_day['weather'][0]['description'].capitalize()
        icon = current_day["weather"][0]["icon"]
        d_list = []
        hour_list = []
        for day in response2['daily']:
            d_list.append({
                "day_of_week": datetime.fromtimestamp(day['dt']).strftime('%a'),
                "temp_of_week": math.ceil((day['temp']['day'])),
                "temp_night": math.ceil(day['temp']['night']),
                "humidity": day['humidity']
            })

        for hour in response2['hourly']:
            hour_list.append({
                "hour": datetime.fromtimestamp(hour["dt"]).strftime('%H:%M'),
                "temperature": math.ceil(hour["temp"]),
            })

        return render_template("index.html",
                               city=city, country=country,
                               current_temp=math.ceil(current_day['temp']),
                               date=current_date, full_date=full_date,
                               current_hour=current_hour, current_weather=current_weather,
                               d_list=d_list[1:], hour_temps=hour_list[:6], icon=f"http://openweathermap.org/img/wn/{icon}@2x.png"
                               )

    return render_template("welcome.html")


if __name__ == '__main__':
    app.run()
