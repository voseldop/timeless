using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Background;
using Toybox.Time;

class timelessApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }
    

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }
    
    function requestWeatherUpdate(period) {
    		if(Toybox.System has :ServiceDelegate) {
    		    var periodProperty = period == 0 ? App.getApp().getProperty("WeatherUpdatePeriod") : period;
    		    if (periodProperty== null || periodProperty <= 0) {
	    		   Sys.println("Weather update is disabled");
	    		   return;
	    		}
          
			var lastTime = Background.getLastTemporalEventTime();
			if (lastTime == null) {			   
			    Sys.println("Schedule request now");	   
			    Background.registerForTemporalEvent(Time.now()); 			    
			} else {
			    var duration = new Time.Duration(periodProperty);
			    lastTime = lastTime.add(duration);
			    var today = Time.Gregorian.info(lastTime, Time.FORMAT_MEDIUM);
			    var dateString = Lang.format(
										    "$1$:$2$:$3$",
										    [
										        today.hour,
										        today.min,
										        today.sec
										    ]
										);
			    Sys.println("Schedule request in "+ dateString);
			    Background.registerForTemporalEvent(lastTime);
			}
	    	} else {
	    		Sys.println("****background not available on this device****");
	    	} 
    }

    // Return the initial view of your application here
    function getInitialView() {
    
        requestWeatherUpdate(0);
	    	
        return [ new timelessView() ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        requestWeatherUpdate(0);
        Ui.requestUpdate();
    }
    
    function getServiceDelegate(){
        return [new timelessWeatherDelegate()];
    }
    
    (:minSdk("2.3.0"))
    function onBackgroundData(data) {
        
        if (data instanceof Dictionary) {
	        Sys.println("onBackgroundData "+ data);
	        var temperature = data.get("temperature");
	        var timeFormat = "$1$:$2$";
	        var clockTime = Sys.getClockTime();
	        var hours = clockTime.hour;
	        var minutes = clockTime.min;
	        var timeString = Lang.format(timeFormat, [hours, minutes.format("%02d")]);
	        var str = Lang.format("$1$°C", [temperature]) + "\n\n\n" + timeString;
	        
	        App.getApp().setProperty("temperature", temperature);
	        App.getApp().setProperty("weatherCode", data.get("weatherCode"));
	        
	        Ui.requestUpdate();
	        requestWeatherUpdate(0);
        } else {
            requestWeatherUpdate(300);
        }
    }

}