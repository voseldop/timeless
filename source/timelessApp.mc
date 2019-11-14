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
        App.getApp().setProperty("weather_api_key", Ui.loadResource(Rez.Strings.openweathermap_apikey));
        var periodProperty = period == 0 ? App.getApp().getProperty("WeatherUpdatePeriod") : period;
        if (periodProperty == null || periodProperty <= 0) {
          Sys.println("Weather update is disabled");
          return;
        }

        var timestamp = App.getApp().getProperty("forecastTimestamp");
        var forecastTime = null;
        if (timestamp != null) {
           forecastTime = new Time.Moment(timestamp);
        }

        if (forecastTime == null || forecastTime.compare(Time.now()) + periodProperty < 0) {
           periodProperty = 300;
        }

        var lastTime = Background.getLastTemporalEventTime();
        if (lastTime == null || lastTime.compare(Time.now()) > periodProperty) {
            Sys.println("Schedule request now");
            Background.registerForTemporalEvent(Time.now());
        }
      } else {
        Sys.println("****background not available on this device****");
      }
    }

    // Return the initial view of your application here
    function getInitialView() {
        var view = new timelessView();

        return [ view ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        Ui.requestUpdate();
    }

    function getServiceDelegate(){
        return [new timelessWeatherDelegate()];
    }

    function synchronizeData(name, data) {
        var value = data.get(name);
        Sys.println("Synchronize " + name + " = " + value );
        if (value != null) {
          App.getApp().setProperty(name, value);
        }
    }

    (:minSdk("2.3.0"))
    function onBackgroundData(data) {
      var timeFormat = "$1$:$2$";
        var clockTime = Sys.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        var timeString = Lang.format(timeFormat, [hours, minutes.format("%02d")]);

        if (data instanceof Dictionary) {
          synchronizeData("temperature", data.get("current"));
          synchronizeData("weatherCode", data.get("current"));
          synchronizeData("forecastTemp", data.get("forecast"));
          synchronizeData("forecastWeather", data.get("forecast"));
          synchronizeData("forecastTime", data.get("forecast"));
          synchronizeData("forecastTimestamp", data.get("forecast"));
          synchronizeData("currentTimestap", data.get("current"));
          synchronizeData("currentLocation", data.get("current"));
          synchronizeData("lattitude", data.get("position"));
          synchronizeData("longitude", data.get("position"));

          Ui.requestUpdate();
        }
    }

}