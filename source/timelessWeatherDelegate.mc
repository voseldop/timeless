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
    const CURRENT_CITY_WEATHER_URI = "https://api.openweathermap.org/data/2.5/weather?q=$2$&appid=$1$&units=metric";
    const CURRENT_COORD_WEATHER_URI = "https://api.openweathermap.org/data/2.5/weather?lat=$2$&lon=$3$&appid=$1$&units=metric";
    const FORECAST_CITY_WEATHER_URI = "https://api.openweathermap.org/data/2.5/forecast?q=$2$&appid=$1$&units=metric&cnt=3";
    const FORECAST_COORD_WEATHER_URI = "https://api.openweathermap.org/data/2.5/forecast?lat=$2$&lon=$3$&appid=$1$&units=metric&cnt=3";

    const TIME_FORMAT = "$1$:$2$";

    var currentWeather;
    var forecastWeather;
    var lattitude;
    var longitude;
    var timestamp;
    var phoneLattitude;
    var phoneLongitude;
    var phoneTimestamp;
    var cityCode;

    enum {
      IDLE,
      CURRENT_WEATHER,
      FORECAST_WEATHER,
      DONE
    }

    var state = IDLE;

    function initialize(){
        ServiceDelegate.initialize();
    }

    function fetchGarminWeather() {
       if (Toybox has :Weather) {
         var current = Toybox.Weather.getCurrentConditions();
         var forecast = Toybox.Weather.getHourlyForecast();

         if (current == null || forecast == null) {
            return false;
         }
         currentWeather = { "temperature" => current.temperature,
                             "currentWeatherCode" => current.condition,
                             "currentWindSpeed" => current.windSpeed,
                             "currentWindDirection" => current.windBearing,
                             "currentTimestamp" => current.observationTime.value(),
                             "currentLocation" => current.observationLocationName };

         var temperature = [];
         var windSpeed = [];
         var windDirection = [];
         var time = [];
         var conditions = [];

         for (var i = 0; i < forecast.size(); i++) {
           temperature.add(forecast[i].temperature);
           windSpeed.add(forecast[i].windSpeed);
           windDirection.add(forecast[i].windBearing);
           time.add(forecast[i].forecastTime.value()+System.getClockTime().timeZoneOffset);
           conditions.add(forecast[i].condition);
         }

         forecastWeather = {"forecastTemp" => temperature,
                           "forecastWeather" => conditions,
                           "forecastWindSpeed" => windSpeed,
                           "forecastWindDirection" => windDirection,
                           "forecastTime" => time,
                           "forecastTimestamp" => current.observationTime.value(),
                           "forecastLocation" => current.observationLocationName
                           };
         lattitude = current.observationLocationPosition.toDegrees()[0];
         longitude = current.observationLocationPosition.toDegrees()[1];
         timestamp = Time.now().value();
         return true;
       } else {
       return false;
       }
    }

    function loop() {
    if (Toybox has :Weather) {
       System.println("Checking garmin weather");
       if (fetchGarminWeather()) {
         var result = {"current" => currentWeather,
                       "forecast" => forecastWeather,
                      "lattitude" => lattitude,
                      "longitude" => longitude,
                      "timestamp" => timestamp
                     };
         Background.exit(result);
         return;
       }
    }
      if (state == IDLE) {
        state = CURRENT_WEATHER;
        Communications.registerForPhoneAppMessages(method(:phoneMessage));
        loop();
      } else if (state == CURRENT_WEATHER) {
        makeCurrentWeatherRequest();
      } else if (state == FORECAST_WEATHER) {
        makeForecastWeatherRequest();
      } else if (state == DONE) {
        Communications.registerForPhoneAppMessages(null);
        var result = {"current" => currentWeather,
                      "forecast" => forecastWeather,
                      "lattitude" => lattitude,
                      "longitude" => longitude,
                      "timestamp" => timestamp,
                      "phone.lattitude" => phoneLattitude,
                      "phone.longitude" => phoneLongitude,
                      "phone.timestamp" => phoneTimestamp
                     };
        Background.exit(result);
      }
    }

    function phoneMessage(message) {
      var data = message.data;
      if (data != null) {
        phoneLattitude = data.get("latitude");
        phoneLongitude = data.get("longitude");
        phoneTimestamp = Time.now().value();
        longitude = phoneLongitude;
        lattitude = phoneLattitude;
        var currentData = data.get("current");
        if (currentData != null) {
           synchronizeWeather( currentData);
           var forecastData = data.get("forecast");
           if (forecastData != null) {
             System.println("Forecast from Phone message");
             forecastWeatherCallback(200, forecastData);
             state = DONE;
             System.println("Phone message completed ");
           }
        }
        System.println("Phone message: " + data);
      } else {
        System.println("Phone message empty");
      }
    }

    function getPositionInfo() {
       var result = new Toybox.Position.Info();
       var usePosition = App.getApp().getProperty("UsePosition");
       if (usePosition == null || usePosition == true) {
         var positionInfo = Position.getInfo().position;
         var quality = Position.getInfo().accuracy;
         timestamp = Position.getInfo().when.value();
         if (positionInfo == null) {
           var activityInfo = Activity.getActivityInfo();
           if (activityInfo != null) {
             positionInfo = activityInfo.currentLocation;
             quality = activityInfo.currentLocationAccuracy;
             timestamp = activityInfo.startTime.value();
           }
         }
         if (positionInfo != null && quality > Position.QUALITY_NOT_AVAILABLE) {
           if (phoneTimestamp == null || timestamp > phoneTimestamp) {
             result.position = positionInfo;
             System.println("Refresh location from device " + result.position.toGeoString(Toybox.Position.GEO_DEG));
           } else {
             result.position = new Toybox.Position.Location(
                    {
                        :latitude => phoneLattitude,
                        :longitude => phoneLongitude,
                        :format => :degrees
                    });
             System.println("Refresh location from phone " + result.position.toGeoString(Toybox.Position.GEO_DEG));
           }
         }
       } else {
         System.println("Refresh location was disabled");
       }
       return result;
    }

    function onTemporalEvent() {
      currentWeather = null;
      forecastWeather = null;
      state = IDLE;
      System.println("onTemporalEvent");
      lattitude = App.getApp().getProperty("lattitude");
      longitude = App.getApp().getProperty("longitude");
      timestamp = App.getApp().getProperty("timestamp");
      phoneLattitude = App.getApp().getProperty("phone.lattitude");
      phoneLongitude = App.getApp().getProperty("phone.longitude");
      phoneTimestamp = App.getApp().getProperty("phone.timestamp");

      var positionInfo = getPositionInfo();
      if (positionInfo.position != null) {
        lattitude = positionInfo.position.toDegrees()[0];
        longitude = positionInfo.position.toDegrees()[1];
      }

      cityCode = App.getApp().getProperty("WeatherLocation");

      Communications.cancelAllRequests();
      loop();
    }

    function getCurrentWeatherURI() {
      var appid = App.getApp().getProperty("weather_api_key");
      if (lattitude != null && longitude != null) {
        return Lang.format(CURRENT_COORD_WEATHER_URI, [appid, lattitude, longitude]);
      } else {
        return Lang.format(CURRENT_CITY_WEATHER_URI, [appid, Communications.encodeURL(cityCode)]);
      }
    }

    function getForecastWeatherURI() {
      var appid = App.getApp().getProperty("weather_api_key");
      if (lattitude != null && longitude != null) {
         return Lang.format(FORECAST_COORD_WEATHER_URI, [appid, lattitude, longitude]);
      } else {
         return Lang.format(FORECAST_CITY_WEATHER_URI, [appid, Communications.encodeURL(cityCode)]);
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
            method(:currentWeatherCallback));
    }

    function synchronizeWeather(data) {
        var temperature = data.get("main").get("temp");
        var weatherCode = data.get("weather")[0].get("icon");
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        var timeStamp = Time.now().value();
        var location = data.get("name");
        var windSpeed = data.get("wind").get("speed");
        var windDirection = data.get("wind").get("deg");

        currentWeather = { "temperature" => temperature,
                           "currentWeatherCode" => weatherCode,
                           "currentWindSpeed" => windSpeed,
                           "currentWindDirection" => windDirection,
                           "currentTimestamp" => timeStamp,
                           "currentLocation" => location };
    }

    function currentWeatherCallback(responseCode, data) {
      // Do stuff with the response data here and send the data
      // payload back to the app that originated the background
      // process.

      if (responseCode == 200) {
        System.println("Current weather response code " + responseCode + " data " + data);

        synchronizeWeather(data);
        state = FORECAST_WEATHER;

        loop();
      } else {
        error(responseCode, data);
      }
    }

    function error(responseCode, data) {
      var message = responseCode.toString();
      if (data != null) {
        message = data.get("message");
      }
      System.println("Error response code " + responseCode + " data " + data);
      state = DONE;
      Background.exit({"error" => true,
                       "message" => message,
                       "responseCode" => responseCode});
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
            method(:forecastWeatherCallback));
    }
    function forecastWeatherCallback(responseCode, data) {
      // Do stuff with the response data here and send the data
      // payload back to the app that originated the background
      // process.
      if (responseCode == 200) {
        System.println("Forecast response code " + responseCode);

        var temperature = new [4];
        var conditions = new [4];
        var windDirection = new [4];
        var windSpeed = new [4];
        var time = new [4];
        var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        var timeStamp = Time.now().value();
        var location = data.get("city").get("name");

        for (var i = 0; i<data.get("list").size(); i+=1) {
           temperature[i] = data.get("list")[i].get("main").get("temp");
           conditions[i] = data.get("list")[i].get("weather")[0].get("icon");
           time[i] = data.get("list")[i].get("dt");
           windDirection[i] = data.get("list")[i].get("wind").get("deg");
           windSpeed[i] = data.get("list")[i].get("wind").get("speed");
        }
        forecastWeather = { "forecastTemp" => temperature,
                         "forecastWeather" => conditions,
                         "forecastWindSpeed" => windSpeed,
                         "forecastWindDirection" => windDirection,
                         "forecastTime" => time,
                         "forecastTimestamp" => timeStamp,
                         "forecastLocation" => location
                         };
        state = DONE;
        loop();
      } else {
         error(responseCode, data);
      }
    }

    function onActivityCompleted(activity) {
        onTemporalEvent();
    }
}