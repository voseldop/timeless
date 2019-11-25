using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Background;
using Toybox.Time;
using Toybox.Time.Gregorian;

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

    function requestWeatherUpdate() {
      if (!Sys.getDeviceSettings().phoneConnected) {
        Sys.println("Phone disconnected");
        return;
      }

      if(Toybox.System has :ServiceDelegate) {
        App.getApp().setProperty("weather_api_key", Ui.loadResource(Rez.Strings.openweathermap_apikey));
        var periodProperty = App.getApp().getProperty("WeatherUpdatePeriod");
        if (periodProperty == null || periodProperty < 0) {
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

        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format(
              "$1$:$2$:$3$ $4$ $5$ $6$ $7$",
              [
              today.hour,
              today.min,
              today.sec,
              today.day_of_week,
              today.day,
              today.month,
              today.year
              ]
            );

        var lastTime = Background.getLastTemporalEventTime();

        if (lastTime != null) {
          var last = Gregorian.info(lastTime, Time.FORMAT_MEDIUM);
          var lastDateString = Lang.format(
                "$1$:$2$:$3$ $4$ $5$ $6$ $7$",
                [
                last.hour,
                last.min,
                last.sec,
                last.day_of_week,
                last.day,
                last.month,
                last.year
                ]
              );

          var duration = Time.now().compare(lastTime);

          if (duration > periodProperty) {
              System.println(dateString + " requestWeatherUpdate scheduled "+ duration);
              Background.registerForTemporalEvent(Time.now());
          } else {
              System.println(dateString + " requestWeatherUpdate is skipped " + lastDateString + " " + periodProperty);
          }
        } else {
          System.println(dateString + " requestWeatherUpdate scheduled now");
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

        System.println(data);

        if (data instanceof Dictionary && (data.get("error") == null || data.get("error") == false)) {
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
        } else {
          App.getApp().setProperty("currentLocation", data.get("message"));
        }
        Ui.requestUpdate();
    }

}