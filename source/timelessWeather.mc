using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time as Time;

class Weather extends Ui.Drawable {
    const METRIC_TEMPERATURE_TMPL = "$1$°";
    const IMPERIAL_TEMPERATURE_TMPL = "$1$°";

    const icons = {
          "Snow" => Rez.Drawables.snow,
          "Sun"  => Rez.Drawables.sun,
          "Few Clouds" => Rez.Drawables.fewClouds,
          "Broken Clouds"  => Rez.Drawables.brokenClouds,
          "Overcast Clouds"  => Rez.Drawables.overcastClouds,
          "Rain" => Rez.Drawables.rain,
          "Shower Rain"  => Rez.Drawables.showerRain,
          "Thunderstorm" => Rez.Drawables.thunderstorm,
          "Fog" => Rez.Drawables.fog
        };

    const freesans = Ui.loadResource(Rez.Fonts.id_freesans);
    const freesans_outline = Ui.loadResource(Rez.Fonts.id_freesans_outline);

    function initialize() {
        var dictionary = {
            :identifier => "Weather"
        };

        Drawable.initialize(dictionary);
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
            return "";
        }

        return Lang.format(Sys.getDeviceSettings().temperatureUnits == Sys.UNIT_METRIC ? METRIC_TEMPERATURE_TMPL : IMPERIAL_TEMPERATURE_TMPL,
                           [formatDecimal(value)]);
    }

    function formatWindSpeed(value) {
        if (value == null) {
            return "";
        }

        switch (App.getApp().getProperty("WindSpeedUnits")) {
        case 1:
          return (value * 3.6).format("%0.f");
        case 2:
          return (value * 2.237).format("%0.f");
        default:
          return value.format("%.1f");
        }

        return "";
    }

    function drawForecastSegment(temperature, weather, hour, speed, direction, dc) {
      var rez = icons.get(weather);
      var image = Ui.loadResource(rez);
      var textPosX = dc.getWidth() / 2;
      var textPosY = dc.getHeight() / 2;
      var iconX = dc.getWidth() / 2;
      var iconY = dc.getHeight() / 2;
      var text = formatTemperature(temperature);
      var segment = hour % 12;
      var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();

      radius = (radius - (image.getWidth() > image.getWidth() ? image.getWidth() : image.getHeight())) / 2;

      iconX = iconX + (radius + 10) * Toybox.Math.sin(Toybox.Math.PI * (segment) / 6) - image.getWidth()/2;
      iconY = iconY - (radius + 5) * Toybox.Math.cos(Toybox.Math.PI * (segment) / 6) - image.getHeight()/2;

      textPosX = dc.getWidth() / 2 + radius * Toybox.Math.sin(Toybox.Math.PI * (segment - 0.7) / 6);
      textPosY = dc.getHeight() / 2 - radius * Toybox.Math.cos(Toybox.Math.PI * (segment - 0.7) / 6);

      dc.drawBitmap(iconX, iconY, image);
      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
      dc.drawText(textPosX, textPosY, freesans_outline, text, Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      dc.drawText(textPosX, textPosY, freesans, text, Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);

      if (direction != null && speed != null) {
        textPosX = dc.getWidth() / 2 + radius * Toybox.Math.sin(Toybox.Math.PI * (segment + 0.7) / 6);
        textPosY = dc.getHeight() / 2 - radius * Toybox.Math.cos(Toybox.Math.PI * (segment + 0.7) / 6);

        var pts = [[textPosX + 15 * Toybox.Math.sin(Toybox.Math.PI * direction / 180), textPosY - 15 * Toybox.Math.cos(Toybox.Math.PI * direction / 180)],
                   [textPosX - 15 * Toybox.Math.sin(Toybox.Math.PI * (direction - 30) / 180), textPosY + 15 * Toybox.Math.cos(Toybox.Math.PI * (direction - 30) / 180)],
                   [textPosX - 10 * Toybox.Math.sin(Toybox.Math.PI * (direction) / 180), textPosY + 10 * Toybox.Math.cos(Toybox.Math.PI * (direction) / 180)],
                   [textPosX - 15 * Toybox.Math.sin(Toybox.Math.PI * (direction + 30) / 180), textPosY + 15 * Toybox.Math.cos(Toybox.Math.PI * (direction + 30) / 180)]];
        dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_LT_GRAY);
        dc.fillPolygon(pts);

        textPosX = dc.getWidth() / 2 + radius * Toybox.Math.sin(Toybox.Math.PI * (segment + 1.2) / 6);
        textPosY = dc.getHeight() / 2 - radius * Toybox.Math.cos(Toybox.Math.PI * (segment + 1.2) / 6);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.drawText(textPosX, textPosY, freesans_outline, formatWindSpeed(speed), Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(textPosX, textPosY, freesans, formatWindSpeed(speed), Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
      }

      image = null;
    }

    function toImperial(temperature) {
       return temperature * 9 / 5 + 32;
    }


    function draw(dc) {
       if (Toybox.System has :ServiceDelegate) {
         var weatherStyle = App.getApp().getProperty("WeatherStyle");
         var forecastTime = App.getApp().getProperty("forecastTime");
         var forecastTemp = App.getApp().getProperty("forecastTemp");
         var forecastWeather = App.getApp().getProperty("forecastWeather");
         var forecastWindSpeed = App.getApp().getProperty("forecastWindSpeed");
         var forecastWindDirection = App.getApp().getProperty("forecastWindDirection");
         var currentWindSpeed = App.getApp().getProperty("currentWindSpeed");
         var direction = App.getApp().getProperty("currentWindDirection");

         if (forecastTime != null && forecastTemp != null && forecastWeather != null && weatherStyle > 0) {
           for (var segment = 0; segment < 4; segment +=1) {
              var time = new Time.Moment(forecastTime[segment]);
              var hour = Time.Gregorian.utcInfo(time, Time.FORMAT_MEDIUM).hour;
              var weather = forecastWeather[segment];
              var temperature = System.getDeviceSettings().temperatureUnits == System.UNIT_METRIC ? forecastTemp[segment] : toImperial(forecastTemp[segment]);
              var speed = forecastWindSpeed[segment];
              var direction = forecastWindDirection[segment];

              if (Time.now().subtract(new Time.Duration(Time.Gregorian.SECONDS_PER_HOUR * 3)).lessThan(time)) {
                    drawForecastSegment(weatherStyle > 1 ? temperature : null, weather, hour, weatherStyle == 4 ? speed : null, weatherStyle == 4 ? direction : null, dc);
              }
            }
         }

         if (currentWindSpeed != null && direction != null && weatherStyle == 4) {
            var textPosX = dc.getWidth() / 2 - 10;
            var textPosY = dc.getHeight() / 2 - 30;

            var pts = [[textPosX + 8 * Toybox.Math.sin(Toybox.Math.PI * direction / 180), textPosY - 8 * Toybox.Math.cos(Toybox.Math.PI * direction / 180)],
                 [textPosX - 8 * Toybox.Math.sin(Toybox.Math.PI * (direction - 30) / 180), textPosY + 8 * Toybox.Math.cos(Toybox.Math.PI * (direction - 30) / 180)],
                 [textPosX - 6 * Toybox.Math.sin(Toybox.Math.PI * (direction) / 180), textPosY + 6 * Toybox.Math.cos(Toybox.Math.PI * (direction) / 180)],
                 [textPosX - 8 * Toybox.Math.sin(Toybox.Math.PI * (direction + 30) / 180), textPosY + 8 * Toybox.Math.cos(Toybox.Math.PI * (direction + 30) / 180)]];
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_LT_GRAY);
            dc.fillPolygon(pts);

            textPosX = dc.getWidth() / 2 + 10;
            textPosY = dc.getHeight() / 2 - 30;
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
            dc.drawText(textPosX, textPosY, freesans_outline, formatWindSpeed(currentWindSpeed), Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(textPosX, textPosY, freesans, formatWindSpeed(currentWindSpeed), Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
         }
       }
    }
}