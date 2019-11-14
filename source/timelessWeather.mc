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
            return "?";
        }

        return Lang.format(Sys.getDeviceSettings().temperatureUnits == Sys.UNIT_METRIC ? METRIC_TEMPERATURE_TMPL : IMPERIAL_TEMPERATURE_TMPL,
                           [formatDecimal(value)]);
    }

    function drawForecastSegment(temperature, weather, hour, dc) {
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

      iconX = iconX + radius * Toybox.Math.cos(Toybox.Math.PI * (segment - 3) / 6) - image.getWidth()/2;
      iconY = iconY + radius * Toybox.Math.sin(Toybox.Math.PI * (segment - 3) / 6) - image.getHeight()/2;

      textPosX = textPosX + radius * Toybox.Math.cos(Toybox.Math.PI * (2 * segment - 5) / 12);
      textPosY = textPosY + radius * Toybox.Math.sin(Toybox.Math.PI * (2 * segment - 5) / 12);

      dc.drawBitmap(iconX, iconY, image);
      dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
      dc.drawText(textPosX, textPosY, freesans_outline, text, Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
      dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
      dc.drawText(textPosX, textPosY, freesans, text, Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);

      image = null;
    }


    function draw(dc) {
       if (Toybox.System has :ServiceDelegate) {
       var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
       var forecastTime = App.getApp().getProperty("forecastTime");
       var forecastTemp = App.getApp().getProperty("forecastTemp");
       var forecastWeather = App.getApp().getProperty("forecastWeather");

       if (forecastTime != null && forecastTemp != null && forecastWeather != null) {
         for (var segment = 0; segment < 4; segment +=1) {
            var time = new Time.Moment(forecastTime[segment]);
            var hour = Time.Gregorian.info(time, Time.FORMAT_MEDIUM).hour;
            var weather = forecastWeather[segment];
            var temperature = forecastTemp[segment];
            var current = Sys.getClockTime().hour;

            drawForecastSegment(temperature, weather, hour, dc);
           }
         }
       }
    }
}