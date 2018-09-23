using Toybox.Background;
using Toybox.Communications;
using Toybox.System;
using Toybox.Application as App;

(:background)
class timelessWeatherDelegate extends System.ServiceDelegate {
    // When a scheduled background event triggers, make a request to
    // a service and handle the response with a callback function
    // within this delegate.
    
    const CURRENT_WEATHER_URI = "https://api.openweathermap.org/data/2.5/weather?q=$1$&appid=8c401201165447badd5d8cbf631492a3&units=$2$";
    const FORECAST_WEATHER_URI = "https://api.openweathermap.org/data/2.5/forecast?q=$1$&appid=8c401201165447badd5d8cbf631492a3&units=$2$&cnt=4";
    
    var currentWeather;
    var forecastWeather;
    
    var weatherCodes;
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
        currentWeather = null;
        forecastWeather = null;
    	makeCurrentWeatherRequest();
    	makeForecastWeatherRequest();
    }
    
    function getTemperatureUnits() {
        return System.getDeviceSettings().temperatureUnits == System.UNIT_METRIC ? "metric" : "imperial";
    }
    
    function makeCurrentWeatherRequest() {
        var url=Lang.format(CURRENT_WEATHER_URI, [Communications.encodeURL(App.getApp().getProperty("WeatherLocation")), getTemperatureUnits()]);  
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
        if (responseCode == 200) {
        	var temperature = data.get("main").get("temp");
	        var weatherCode = data.get("weather")[0].get("icon");
	        var timeFormat = "$1$:$2$";
	        var clockTime = System.getClockTime();
	        var hours = clockTime.hour;
	        var minutes = clockTime.min;
	        var timeString = Lang.format(timeFormat, [hours, minutes.format("%02d")]);
	        currentWeather = { "temperature" => temperature,
    		                  "weatherCode" => weatherCodes.get(weatherCode),
    		                  "timestamp" => timeString };
    		if (forecastWeather) {
    		   Background.exit({ "current" => currentWeather,
    		                     "forecast" => forecastWeather});
    		}
        } else {
            Background.exit(responseCode);
        }
        
    }
    
    function makeForecastWeatherRequest() {
        var url=Lang.format(FORECAST_WEATHER_URI, [Communications.encodeURL(App.getApp().getProperty("WeatherLocation")), getTemperatureUnits()]);  
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
        System.println("Forecast response "+ data); 
        if (responseCode == 200) {
           var temperature = new [4];
           var conditions = new [4];
           var time = new [4];
           for (var i = 0; i<4; i+=1) {
             temperature[i] = data.get("list")[i].get("main").get("temp");
             conditions[i] = weatherCodes.get(data.get("list")[i].get("weather")[0].get("icon"));
             time[i] = data.get("list")[i].get("dt");
           }
           forecastWeather = { "forecastTemp" => temperature,
        		               "forecastWeather" => conditions,
        		               "forecastTime" => time };

           if (currentWeather) {
    		   Background.exit({ "current" => currentWeather,
    		                     "forecast" => forecastWeather});
    	   }       
        } else {
            Background.exit(responseCode);
        }
        
    }
}