using Toybox.Background;
using Toybox.Communications;
using Toybox.System;
using Toybox.Application as App;
using Toybox.Activity;

(:background)
class timelessWeatherDelegate extends System.ServiceDelegate {
    // When a scheduled background event triggers, make a request to
    // a service and handle the response with a callback function
    // within this delegate.
    const CURRENT_CITY_WEATHER_URI = "https://api.openweathermap.org/data/2.5/weather?q=$2$&appid=$1$&units=$3$";
    const CURRENT_COORD_WEATHER_URI = "https://api.openweathermap.org/data/2.5/weather?lat=$2$&lon=$3$&appid=$1$&units=$4$";
    const FORECAST_CITY_WEATHER_URI = "https://api.openweathermap.org/data/2.5/forecast?q=$2$&appid=$1$&units=$3$&cnt=4";
    const FORECAST_COORD_WEATHER_URI = "https://api.openweathermap.org/data/2.5/forecast?lat=$2$&lon=$3$&appid=$1$&units=$4$&cnt=4";

    const TIME_FORMAT = "$1$:$2$";

    var currentWeather;
    var forecastWeather;

    var weatherCodes;

    var lattitude;
    var longitude;
    var cityCode;

    function initialize(){
        ServiceDelegate.initialize();

        weatherCodes = {
        "01d" => "Sun",
        "01n" => "Sun",
        "02d" => "Few Clouds",
        "02n" => "Few Clouds",
        "03d" => "Broken Clouds",
        "03n" => "Broken Clouds",
        "04d" => "Overcast Clouds",
        "04n" => "Overcast Clouds",
        "09d" => "Shower Rain",
        "09n" => "Shower Rain",
        "10d" => "Rain",
        "10n" => "Rain",
        "11d" => "Thunderstorm",
        "11n" => "Thunderstorm",
        "13d" => "Snow",
        "13n" => "Snow",
        "50d" => "Fog",
        "50n" => "Fog"
        };
    }

    function onTemporalEvent() {
      if (lattitude == null)  {
        lattitude = App.getApp().getProperty("lattitude");
      }

      if (longitude == null) {
         longitude = App.getApp().getProperty("longitude");
      }

      currentWeather = null;
      forecastWeather = null;

      var usePosition = App.getApp().getProperty("UsePosition");
      System.println("Use position is " + usePosition);

      if (usePosition == null || usePosition == true) {
        var positionInfo = Position.getInfo().position;
        var quality = Position.getInfo().accuracy;
        if (positionInfo == null) {
          var activityInfo = Activity.getActivityInfo();
          if (activityInfo != null) {
            positionInfo = activityInfo.currentLocation;
            quality = activityInfo.currentLocationAccuracy;
          }
        }
        if (positionInfo != null && quality > Position.QUALITY_NOT_AVAILABLE) {
          lattitude = positionInfo.toDegrees()[0];
          longitude = positionInfo.toDegrees()[1];
          System.println("Refresh location " + lattitude + ", " + longitude + " quality : " + quality);
        }
      } else {
        lattitude = null;
        longitude = null;
      }

      cityCode = App.getApp().getProperty("WeatherLocation");

      System.println("Current weather request " + getCurrentWeatherURI());

      Communications.cancelAllRequests();

      makeCurrentWeatherRequest();
      makeForecastWeatherRequest();
    }

    function getTemperatureUnits() {
        return System.getDeviceSettings().temperatureUnits == System.UNIT_METRIC ? "metric" : "imperial";
    }

    function getCurrentWeatherURI() {
        var appid = App.getApp().getProperty("weather_api_key");
        if (lattitude != null && longitude != null) {
         return Lang.format(CURRENT_COORD_WEATHER_URI, [appid, lattitude, longitude, getTemperatureUnits()]);
      } else {
         return Lang.format(CURRENT_CITY_WEATHER_URI, [appid, Communications.encodeURL(cityCode), getTemperatureUnits()]);
      }
    }

    function getForecastWeatherURI() {
      var appid = App.getApp().getProperty("weather_api_key");
      if (lattitude != null && longitude != null) {
         return Lang.format(FORECAST_COORD_WEATHER_URI, [appid, lattitude, longitude, getTemperatureUnits()]);
      } else {
         return Lang.format(FORECAST_CITY_WEATHER_URI, [appid, Communications.encodeURL(cityCode), getTemperatureUnits()]);
      }
    }

    function makeCurrentWeatherRequest() {
        var url = getCurrentWeatherURI();
        var headers = {"Accept" => "application/json"};
        var params = {};

      var options = {
              :headers => headers,
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
                :params => params
            };

        System.println("Current weather request " + url);

        Communications.makeWebRequest(
            url,
            params, options,
            method(:currentWeatherCallback)
        );
    }

    function currentWeatherCallback(responseCode, data) {
        // Do stuff with the response data here and send the data
        // payload back to the app that originated the background
        // process.
        System.println("Forecast response code " + responseCode + " data "+ data);

        if (responseCode == 200) {
          var temperature = data.get("main").get("temp");
          var weatherCode = data.get("weather")[0].get("icon");
          var timeFormat = "$1$:$2$";
          var clockTime = System.getClockTime();
          var hours = clockTime.hour;
          var minutes = clockTime.min;
          var timeStamp = Time.now().value();
          var location = data.get("name");

          currentWeather = { "temperature" => temperature,
                          "weatherCode" => weatherCodes.get(weatherCode),
                          "timestamp" => timeStamp,
                          "currentLocation" => location };

        if (forecastWeather) {
           Background.exit({ "current" => currentWeather,
                             "forecast" => forecastWeather,
                             "position" => {
                               "lattitude" => lattitude,
                               "longitude" => longitude}
                         });
        }
        } else {
            Background.exit({"error" => true,
                             "message" => data.get("message")});
        }

    }

    function makeForecastWeatherRequest() {
        var url = getForecastWeatherURI();
        var headers = {"Accept" => "application/json"};
        var params = {};

      var options = {
              :headers => headers,
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
                :params => params
            };

        System.println("Forecast request "+ url);

        Communications.makeWebRequest(
            url,
            params, options,
            method(:forecastWeatherCallback)
        );
    }

    function forecastWeatherCallback(responseCode, data) {
        // Do stuff with the response data here and send the data
        // payload back to the app that originated the background
        // process.
        System.println("Forecast response code " + responseCode + " data "+ data);
        if (responseCode == 200) {
          var temperature = new [4];
          var conditions = new [4];
          var time = new [4];
          var clockTime = System.getClockTime();
          var hours = clockTime.hour;
          var minutes = clockTime.min;
          var timeStamp = Time.now().value();
          var location = data.get("city").get("name");

          for (var i = 0; i<4; i+=1) {
             temperature[i] = data.get("list")[i].get("main").get("temp");
             conditions[i] = weatherCodes.get(data.get("list")[i].get("weather")[0].get("icon"));
             time[i] = data.get("list")[i].get("dt");
          }
          forecastWeather = { "forecastTemp" => temperature,
                           "forecastWeather" => conditions,
                           "forecastTime" => time,
                           "forecastTimestamp" => timeStamp,
                           "forecastLocation" => location
                           };

          if (currentWeather) {
            Background.exit({  "current" => currentWeather,
                               "forecast" => forecastWeather,
                               "position" => {
                               "lattitude" => lattitude,
                               "longitude" => longitude}
                         });
         }
        } else {
            Background.exit({"error" => true,
                             "message" => data.get("message")});
        }

    }

    function onActivityCompleted(activity) {
        onTemporalEvent();
    }
}