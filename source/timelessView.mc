using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.ActivityMonitor as Metrics;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Time;
using Toybox.Background;

class timelessView extends Ui.WatchFace {

    const METRIC_TEMPERATURE_TMPL = "$1$°C";
    const IMPERIAL_TEMPERATURE_TMPL = "$1$°F";
    const connectivity = Ui.loadResource(Rez.Fonts.id_bluetooth);
    const large = Ui.loadResource(Rez.Fonts.id_large);
    const xtiny = Gfx.FONT_XTINY;

    var logo;

    var tempView;

    function initialize() {
        WatchFace.initialize();
        logo = new Rez.Drawables.Logo();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        var dateView = View.findDrawableById("DateLabel");
        var timeView = View.findDrawableById("TimeLabel");
        var weatherView = View.findDrawableById("WeatherLabel");
        tempView = View.findDrawableById("TemperatureLabel");
        var notificationsView = View.findDrawableById("NotificationLabel");
        var updateView = View.findDrawableById("UpdateTimeLabel");
        var timeString = "20:00";
        var locationView = View.findDrawableById("LocationLabel");
        var connectivityView = View.findDrawableById("ConnectivityLabel");

        dateView.setLocation(timeView.locX - 25, timeView.locY - Gfx.getFontHeight(xtiny));
        weatherView.setLocation(timeView.locX + 25, timeView.locY - Gfx.getFontHeight(xtiny));
        updateView.setLocation(timeView.locX - dc.getTextDimensions(timeString, large)[0] / 2, timeView.locY + Gfx.getFontHeight(connectivity));
        locationView.setLocation(locationView.locX, timeView.locY + Gfx.getFontHeight(large));
        connectivityView.setLocation(timeView.locX - dc.getTextDimensions(timeString, large)[0] / 2, timeView.locY);
        notificationsView.setLocation(timeView.locX, timeView.locY - Gfx.getFontHeight(xtiny) / 2 );
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
      var hours = clockTime.hour;
      var minutes = clockTime.min;
      var timeString = Lang.format(timeFormat, [hours, minutes.format("%02d")]);
      var dateInfo = Calendar.info(Time.now(), Calendar.FORMAT_MEDIUM);
      var dateString = Lang.format("$1$ $2$", [dateInfo.day, dateInfo.day_of_week]);
      var location = App.getApp().getProperty("currentLocation");
      var forecastTimestamp = App.getApp().getProperty("forecastTimestamp");
      var locationView = View.findDrawableById("LocationLabel");
      var connectivityView = View.findDrawableById("ConnectivityLabel");
      var updateView = View.findDrawableById("UpdateTimeLabel");

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

      locationView.setText(location);

      if (Toybox.System has :ServiceDelegate) {
           var weatherView = View.findDrawableById("WeatherLabel");
           var weatherCode = App.getApp().getProperty("weatherCode");
           var temperature = formatTemperature(App.getApp().getProperty("temperature"));
           weatherView.setText(temperature);
      }

      if (Sys.getDeviceSettings().phoneConnected) {
        connectivityView.setText(" ");
      } else {
        connectivityView.setText("");
      }

      timeString = "";

      if (forecastTimestamp != null) {
        var timeStamp = Time.Gregorian.info(new Time.Moment(forecastTimestamp.toNumber()), Time.FORMAT_MEDIUM);
        timeString = Lang.format("$1$:$2$", [timeStamp.hour, timeStamp.min.format("%02d")]);
      }
      updateView.setText(timeString);

      var notificationsView = View.findDrawableById("NotificationLabel");
      var notificationText = Lang.format("✉$1$", [Sys.getDeviceSettings().notificationCount.format("%i")]);
      notificationsView.setText(notificationText);

          // Call the parent onUpdate function to redraw the layout
      View.onUpdate(dc);

      onExitSleep();

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

        return Lang.format(Sys.getDeviceSettings().temperatureUnits == Sys.UNIT_METRIC ? METRIC_TEMPERATURE_TMPL : IMPERIAL_TEMPERATURE_TMPL,
                           [formatDecimal(value)]);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
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

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
