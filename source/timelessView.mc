using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.ActivityMonitor as Metrics;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Time;
using Toybox.Background;

var partialUpdatesAllowed = false;

class timelessView extends Ui.WatchFace {

    const METRIC_TEMPERATURE_TMPL = "$1$°C";
    const IMPERIAL_TEMPERATURE_TMPL = "$1$°F";
    const large = Ui.loadResource(Rez.Fonts.id_large);
    var large_thin;
    const symbol = Ui.loadResource(Rez.Fonts.id_symbol);
    const xtiny = Ui.loadResource(Rez.Fonts.id_xtiny);

    var tempView;
    static var lowPower = true;

    static function isLowPower() {
      return lowPower;
    }

    function initialize() {
        WatchFace.initialize();
        partialUpdatesAllowed = ( Toybox.WatchUi.WatchFace has :onPartialUpdate );
        if (Rez.Fonts has :id_large_thin) {
          large_thin = Ui.loadResource(Rez.Fonts.id_large_thin);
        }
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        var dateView = View.findDrawableById("DateLabel");
        var timeView = View.findDrawableById("TimeLabel");
        var weatherView = View.findDrawableById("WeatherLabel");
        tempView = View.findDrawableById("TemperatureLabel");
        var notificationsView = View.findDrawableById("NotificationLabel");
        var alarmsView = View.findDrawableById("AlarmsLabel");
        var updateView = View.findDrawableById("UpdateTimeLabel");
        var timeString = "22:22";
        var locationView = View.findDrawableById("LocationLabel");
        var connectivityView = View.findDrawableById("ConnectivityLabel");
        var secondsView = View.findDrawableById("SecondsLabel");
        var dayNightView = View.findDrawableById("DayNightLabel");

        dateView.setLocation(timeView.locX - 25, timeView.locY - Gfx.getFontHeight(Gfx.FONT_XTINY) / 2);
        if (weatherView != null) {
          weatherView.setLocation(timeView.locX + 25, timeView.locY - Gfx.getFontHeight(Gfx.FONT_XTINY) /2);
        }
        if (locationView != null) {
          locationView.setLocation(locationView.locX, timeView.locY + Gfx.getFontHeight(large));
        }
        if (updateView != null) {
          updateView.setLocation(timeView.locX - dc.getTextDimensions(timeString, large)[0] / 2, timeView.locY + Gfx.getFontHeight(large) + Gfx.getFontHeight(Gfx.FONT_XTINY));
        }
        if (connectivityView != null) {
          connectivityView.setLocation(timeView.locX - dc.getTextDimensions(timeString, large)[0] / 2, timeView.locY);
        }
        if (notificationsView != null) {
          notificationsView.setLocation(timeView.locX - dc.getTextDimensions(timeString, large)[0] / 2, timeView.locY + Gfx.getFontHeight(symbol));
        }
        if (alarmsView != null) {
          alarmsView.setLocation(notificationsView.locX, timeView.locY + Gfx.getFontHeight(symbol) + Gfx.getFontHeight(xtiny) * 2);
        }
        if (secondsView != null) {
          secondsView.setLocation(timeView.locX + dc.getTextDimensions(timeString, large)[0] / 2,
                                  timeView.locY + dc.getTextDimensions(timeString, large)[1] /2 );
        }
        if (dayNightView != null) {
          dayNightView.setLocation(timeView.locX + dc.getTextDimensions(timeString, large)[0] / 2,
                                   timeView.locY - 5);
        }
        timeView.setFont(large);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    function onWeatherData(temperature, weather) {
      tempView.setText(temperature);
    }

    function drawArrow(dc, radius, rpos, lpos, width) {
        for (var penWidth = 1; penWidth < width * radius/32; penWidth = penWidth + 1) {
            dc.setPenWidth(penWidth);
            dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, (rpos*radius)/32, Gfx.ARC_CLOCKWISE,  90 + 5 * width * (radius/16 - penWidth) - 6 * lpos, 90 - 6 * lpos);
        }
    }

    // Update the view
    function onUpdate(dc) {
      // Get the current time and format it correctly
      var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
      var timeFormat = "$1$:$2$";
      var clockTime = Sys.getClockTime();
      var hours = Sys.getDeviceSettings().is24Hour ? clockTime.hour : clockTime.hour % 12;
      var minutes = clockTime.min;
      var timeString = Lang.format(timeFormat, [hours, minutes.format("%02d")]);
      var dateInfo = Calendar.info(Time.now(), Calendar.FORMAT_MEDIUM);
      var dateString = Lang.format("$1$ $2$", [dateInfo.day, dateInfo.day_of_week]);
      var location = App.getApp().getProperty("currentLocation");
      var forecastTimestamp = App.getApp().getProperty("forecastTimestamp");
      var locationView = View.findDrawableById("LocationLabel");
      var connectivityView = View.findDrawableById("ConnectivityLabel");
      var updateView = View.findDrawableById("UpdateTimeLabel");
      var secondsView = View.findDrawableById("SecondsLabel");
      var dayNigthView = View.findDrawableById("DayNightLabel");
      var weatherView = View.findDrawableById("WeatherLabel");
      var secondsAllowed = App.getApp().getProperty("DisplaySeconds");

      // Update time
      var timeView = View.findDrawableById("TimeLabel");
      timeView.setText(timeString);

      // Update date
      var dateView = View.findDrawableById("DateLabel");
      dateView.setText(dateString);

      if (location != null) {
       if (location.length() > 14) {
         location = Lang.format("$1$...", [location.substring(0, 13)]);
       }
      } else {
        location = "";
      }

      if (locationView != null) {
        locationView.setText(location);
      }

      if (Toybox.System has :ServiceDelegate) {
           var weatherCode = App.getApp().getProperty("weatherCode");
           var temperature = formatTemperature(App.getApp().getProperty("temperature"));
           weatherView.setText(temperature);
      }

      if (Sys.getDeviceSettings().phoneConnected) {
        connectivityView.setText("⌚");
      } else {
        connectivityView.setText("");
      }

      timeString = "";

      if (forecastTimestamp != null) {
        var timeStamp = Time.Gregorian.info(new Time.Moment(forecastTimestamp.toNumber()), Time.FORMAT_MEDIUM);
        if (Sys.getDeviceSettings().is24Hour) {
          timeString = Lang.format("$1$:$2$", [timeStamp.hour, timeStamp.min.format("%02d")]);
        } else {
          timeString = Lang.format("$1$:$2$", [timeStamp.hour % 12, timeStamp.min.format("%02d")]);
        }
      }
      if (updateView != null) {
        updateView.setText(timeString);
      }

      if (Sys.getDeviceSettings().is24Hour) {
        dayNigthView.setText("");
      } else {
        dayNigthView.setLocation(timeView.locX + timeView.width / 2,
                                timeView.locY - 5);
        dayNigthView.setText(clockTime.hour > 12 ? "pm" : "am");
      }

      var notificationsView = View.findDrawableById("NotificationLabel");
      var notificationText = Lang.format("✉$1$", [Sys.getDeviceSettings().notificationCount.format("%i")]);
      notificationsView.setText(notificationText);

      var alarmsView = View.findDrawableById("AlarmsLabel");
      var alarmsText = Lang.format("🔔$1$", [Sys.getDeviceSettings().alarmCount.format("%i")]);
      alarmsView.setText(alarmsText);

      if (partialUpdatesAllowed && secondsAllowed == true) {
        onPartialUpdate(dc);
      } else if (!lowPower && secondsAllowed == true) {
        secondsView.setLocation(timeView.locX+timeView.width/2, secondsView.locY);
        secondsView.setText(clockTime.sec.format("%02d"));
      } else {
        secondsView.setText("");
      }
      if (Sys.getDeviceSettings() has :requiresBurnInProtection && Sys.getDeviceSettings().requiresBurnInProtection && isLowPower()) {
        locationView.setText("");
        connectivityView.setText("");
        alarmsView.setText("");
        notificationsView.setText("");
        updateView.setText("");
        dateView.setText("");
        weatherView.setText("");
        timeView.setLocation(dc.getWidth()/2, dc.getHeight()/2 - ((clockTime.min % 2)) * Gfx.getFontHeight(large));
        timeView.setFont(large_thin);
      } else {
        timeView.setLocation(dc.getWidth()/2, dc.getHeight()/2 - Gfx.getFontHeight(large) / 2);
        timeView.setFont(large);
      }
      // Call the parent onUpdate function to redraw the layout
      View.onUpdate(dc);
      refreshWeather();
    }

    function onPartialUpdate(dc) {
      if (App.getApp().getProperty("DisplaySeconds") == true) {
        var clockTime = Sys.getClockTime();
        var secondsView = View.findDrawableById("SecondsLabel");
        var timeView = View.findDrawableById("TimeLabel");
        dc.setClip(secondsView.locX, secondsView.locY, secondsView.width, secondsView.height);
        dc.setColor(dc.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.fillRectangle(secondsView.locX, secondsView.locY, secondsView.width, secondsView.height);
        dc.setColor(dc.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        secondsView.setLocation(timeView.locX+timeView.width/2, secondsView.locY);
        secondsView.setText(clockTime.sec.format("%02d"));
        secondsView.draw(dc);
        dc.clearClip();
      }
    }

    function formatDecimal(value) {
        if (value instanceof Float || value instanceof Double) {
            return value.format("%.0f");
        } else {
            return value.toString();
        }
    }

    function formatTemperature(value) {
        if (value == null) {
            return "?";
        }

        if (Sys.getDeviceSettings().temperatureUnits == Sys.UNIT_STATUTE) {
           return Lang.format(IMPERIAL_TEMPERATURE_TMPL, [formatDecimal(value * 9 / 5 + 32)]);
        }

        return Lang.format(METRIC_TEMPERATURE_TMPL, [formatDecimal(value)]);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    function refreshWeather() {
      var duration = null;
       var forecastTimestamp = App.getApp().getProperty("forecastTimestamp");
       var period = App.getApp().getProperty("WeatherUpdatePeriod");
       if (period == null) {
          period = 3600;
       }

       if (forecastTimestamp != null) {
            duration = Time.now().subtract(new Time.Moment(forecastTimestamp.toNumber()));
       }

       if (duration == null || duration.value() > period) {
        App.getApp().requestWeatherUpdate();
       }
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
       refreshWeather();
       lowPower = false;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
       Sys.println("Enter sleep");
       lowPower = true;
       Ui.requestUpdate();
    }

}

class AnalogDelegate extends Ui.WatchFaceDelegate {
    function initialize() {
        WatchFaceDelegate.initialize();
    }
    // The onPowerBudgetExceeded callback is called by the system if the
    // onPartialUpdate method exceeds the allowed power budget. If this occurs,
    // the system will stop invoking onPartialUpdate each second, so we set the
    // partialUpdatesAllowed flag here to let the rendering methods know they
    // should not be rendering a second hand.
    function onPowerBudgetExceeded(powerInfo) {
        System.println( "Average execution time: " + powerInfo.executionTimeAverage );
        System.println( "Allowed execution time: " + powerInfo.executionTimeLimit );
        partialUpdatesAllowed = false;
    }
}
