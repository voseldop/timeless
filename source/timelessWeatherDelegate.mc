using Toybox.Background;
using Toybox.Communications;
using Toybox.System;
using Toybox.Application as App;

(:background)
class timelessWeatherDelegate extends System.ServiceDelegate {
    // When a scheduled background event triggers, make a request to
    // a service and handle the response with a callback function
    // within this delegate.
    
    const URI = "https://api.openweathermap.org/data/2.5/weather?q=$1$&appid=8c401201165447badd5d8cbf631492a3&units=$2$";
    
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
        var url=Lang.format(URI, [Communications.encodeURL(App.getApp().getProperty("WeatherLocation")), "metric"]);  
        var headers = {"Accept" => "application/json"};
        var params = {};
	            
	    var options = {
            		:headers => headers,
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
                :params => params
            };
           
        System.println("Request "+ url);       
        
        Communications.makeWebRequest(
            url,
            params, options,
            method(:responseCallback)
        );
    }

    function responseCallback(responseCode, data) {
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
        		Background.exit({ "temperature" => temperature,
        		                  "weatherCode" => weatherCodes.get(weatherCode),
        		                  "timestamp" => timeString });
        } else {
            Background.exit(responseCode);
        }
        
    }
}