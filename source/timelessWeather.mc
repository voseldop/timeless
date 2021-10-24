using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Weather as Weather;

class Weather extends Ui.Drawable {
    const METRIC_TEMPERATURE_TMPL = "$1$°";
    const IMPERIAL_TEMPERATURE_TMPL = "$1$°";

    const icons = {
          "13d" => Rez.Drawables.snow,
          "13n" => Rez.Drawables.snow,
          "01d"  => Rez.Drawables.sun,
          "01n"  => Rez.Drawables.sun,
          "02n" => Rez.Drawables.fewClouds,
          "02d" => Rez.Drawables.fewClouds,
          "03d"  => Rez.Drawables.brokenClouds,
          "03n"  => Rez.Drawables.brokenClouds,
          "04n"  => Rez.Drawables.overcastClouds,
          "04d"  => Rez.Drawables.overcastClouds,
          "10n" => Rez.Drawables.rain,
          "10d" => Rez.Drawables.rain,
          "09d"  => Rez.Drawables.showerRain,
          "09d"  => Rez.Drawables.showerRain,
          "11d" => Rez.Drawables.thunderstorm,
          "11n" => Rez.Drawables.thunderstorm,
          "50d" => Rez.Drawables.fog,
          "50n" => Rez.Drawables.fog,
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


    const large = Ui.loadResource(Rez.Fonts.id_large);
    const freesans = Ui.loadResource(Rez.Fonts.id_freesans);
    const freesans_outline = Ui.loadResource(Rez.Fonts.id_freesans_outline);

    var oldWeather = null;
    var oldTemperature = null;
    var oldWindSpeed = null;
    var oldWindDirection = null;

    function initialize() {
        var dictionary = {
            :identifier => "Weather"
        };

        Drawable.initialize(dictionary);
        // available only since 3.2.0
        if (Toybox has :Weather) {
          icons.put(Weather.CONDITION_FAIR, Rez.Drawables.sun);
          icons.put(Weather.CONDITION_PARTLY_CLOUDY, Rez.Drawables.fewClouds);
          icons.put(Weather.CONDITION_MOSTLY_CLEAR, Rez.Drawables.fewClouds);
          icons.put(Weather.CONDITION_THIN_CLOUDS, Rez.Drawables.fewClouds);
          icons.put(Weather.CONDITION_MOSTLY_CLOUDY, Rez.Drawables.brokenClouds);
          icons.put(Weather.CONDITION_PARTLY_CLEAR, Rez.Drawables.fewClouds);
          icons.put(Weather.CONDITION_CLOUDY, Rez.Drawables.overcastClouds);
          icons.put(Weather.CONDITION_RAIN, Rez.Drawables.rain);
          icons.put(Weather.CONDITION_LIGHT_RAIN, Rez.Drawables.rain);
          icons.put(Weather.CONDITION_FREEZING_RAIN, Rez.Drawables.rain);
          icons.put(Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN, Rez.Drawables.rain);
          icons.put(Weather.CONDITION_DRIZZLE, Rez.Drawables.rain);
          icons.put(Weather.CONDITION_SCATTERED_SHOWERS, Rez.Drawables.showerRain);
          icons.put(Weather.CONDITION_HEAVY_RAIN, Rez.Drawables.showerRain);
          icons.put(Weather.CONDITION_LIGHT_SHOWERS, Rez.Drawables.showerRain);
          icons.put(Weather.CONDITION_SHOWERS, Rez.Drawables.showerRain);
          icons.put(Weather.CONDITION_HEAVY_SHOWERS, Rez.Drawables.showerRain);
          icons.put(Weather.CONDITION_CHANCE_OF_SHOWERS, Rez.Drawables.showerRain);
          icons.put(Weather.CONDITION_CLEAR, Rez.Drawables.sun);
          icons.put(Weather.CONDITION_THUNDERSTORMS, Rez.Drawables.thunderstorm);
          icons.put(Weather.CONDITION_SCATTERED_THUNDERSTORMS, Rez.Drawables.thunderstorm);
          icons.put(Weather.CONDITION_CHANCE_OF_THUNDERSTORMS, Rez.Drawables.thunderstorm);
          icons.put(Weather.CONDITION_TROPICAL_STORM, Rez.Drawables.thunderstorm);
          icons.put(Weather.CONDITION_SNOW, Rez.Drawables.snow);
          icons.put(Weather.CONDITION_LIGHT_SNOW, Rez.Drawables.snow);
          icons.put(Weather.CONDITION_HEAVY_SNOW, Rez.Drawables.snow);
          icons.put(Weather.CONDITION_LIGHT_RAIN_SNOW, Rez.Drawables.snow);
          icons.put(Weather.CONDITION_HEAVY_RAIN_SNOW, Rez.Drawables.snow);
          icons.put(Weather.CONDITION_RAIN_SNOW, Rez.Drawables.snow);
          icons.put(Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW, Rez.Drawables.snow);
          icons.put(Weather.CONDITION_CHANCE_OF_RAIN_SNOW, Rez.Drawables.snow);
          icons.put(Weather.CONDITION_CLOUDY_CHANCE_OF_SNOW, Rez.Drawables.snow);
          icons.put(Weather.CONDITION_CLOUDY_CHANCE_OF_RAIN_SNOW, Rez.Drawables.snow);
          icons.put(Weather.CONDITION_ICE_SNOW, Rez.Drawables.snow);
          icons.put(Weather.CONDITION_FLURRIES, Rez.Drawables.snow);
          icons.put(Weather.CONDITION_FOG, Rez.Drawables.fog);
          icons.put(Weather.CONDITION_MIST, Rez.Drawables.fog);
          icons.put(Weather.CONDITION_HAZY, Rez.Drawables.fog);
          icons.put(Weather.CONDITION_WINDY, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_WINTRY_MIX, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_HAIL, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_UNKNOWN_PRECIPITATION, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_DUST, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_TORNADO, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_SMOKE, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_ICE , Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_SAND, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_SQUALL, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_SANDSTORM, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_VOLCANIC_ASH, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_HAZE, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_HURRICANE, Rez.Drawables.unknown);
          icons.put(Weather.CONDITION_SLEET, Rez.Drawables.unknown);
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
          return value.format("%0.1f");
        }

        return "";
    }

    function drawForecastSegment(temperature, weather, hour, speed, direction, dc) {
      var segment = hour % 12;
      var radius = (dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth()) / 2;


      if (weather != null) {
        var rez = icons.get(weather);
        var image = null;
        if (rez != null) {
          image = Ui.loadResource(rez);
        }

        if (image == null) {
           System.println("Unknown weather code " + weather);
           image = Ui.loadResource(Rez.Drawables.unknown);
        }

        if (image != null) {
          var iconX = dc.getWidth() / 2 + (radius - image.getWidth()/4) * Toybox.Math.sin(Toybox.Math.PI * (segment) / 6) - image.getWidth()/2;
          var iconY = dc.getHeight() / 2 - (radius - image.getHeight()/2) * Toybox.Math.cos(Toybox.Math.PI * (segment) / 6) - image.getHeight()/2;

          if (oldWeather != weather || hour % 3 == 0) {
            dc.drawBitmap(iconX, iconY, image);
          }
          oldWeather = weather;
        }
        image = null;
      }

      if (temperature != null) {
          var text = formatTemperature(temperature);
          var dimensions = dc.getTextDimensions(text, freesans);

          if (!text.equals(oldTemperature) || hour % 3 == 0) {
            var textPosX = dc.getWidth() / 2 + (radius - dimensions[0]) * Toybox.Math.sin(Toybox.Math.PI * (segment) / 6);
            var textPosY = dc.getHeight() / 2 - (radius - dimensions[1]) * Toybox.Math.cos(Toybox.Math.PI * (segment) / 6);
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
            dc.drawText(textPosX, textPosY, freesans_outline, text, Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(textPosX, textPosY, freesans, text, Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
            oldTemperature = text;
          }
      }

      if (direction != null && speed != null) {
        var text = formatWindSpeed(speed);
        var dimensions = dc.getTextDimensions(text, Gfx.FONT_XTINY);
        var textPosX = dc.getWidth() / 2 + (radius - dimensions[0]) * Toybox.Math.sin(Toybox.Math.PI * (segment + 0.5) / 6);
        var textPosY = dc.getHeight() / 2 - (radius - dimensions[1]) * Toybox.Math.cos(Toybox.Math.PI * (segment + 0.5) / 6);

        if (direction != oldWindDirection) {
          var pts = [[textPosX - 8 * Toybox.Math.sin(Toybox.Math.PI * direction / 180), textPosY + 8 * Toybox.Math.cos(Toybox.Math.PI * direction / 180)],
                   [textPosX + 8 * Toybox.Math.sin(Toybox.Math.PI * (direction - 30) / 180), textPosY - 8 * Toybox.Math.cos(Toybox.Math.PI * (direction - 30) / 180)],
                   [textPosX + 6 * Toybox.Math.sin(Toybox.Math.PI * (direction) / 180), textPosY - 6 * Toybox.Math.cos(Toybox.Math.PI * (direction) / 180)],
                   [textPosX + 8 * Toybox.Math.sin(Toybox.Math.PI * (direction + 30) / 180), textPosY - 8 * Toybox.Math.cos(Toybox.Math.PI * (direction + 30) / 180)]];
          dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_LT_GRAY);
          dc.fillPolygon(pts);
          oldWindDirection = direction;
        }
      }

      if (speed != null) {
        var text = formatWindSpeed(speed);
        var dimensions = dc.getTextDimensions(text, Gfx.FONT_XTINY);
        var textPosX = dc.getWidth() / 2 + (radius - dimensions[0]/2)* Toybox.Math.sin(Toybox.Math.PI * (segment + 0.5) / 6);
        var textPosY = dc.getHeight() / 2 - (radius - dimensions[1]/2)* Toybox.Math.cos(Toybox.Math.PI * (segment + 0.5) / 6);

        if (!text.equals(oldWindSpeed)) {
          dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
          dc.drawText(textPosX, textPosY, freesans_outline, text, Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
          dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
          dc.drawText(textPosX, textPosY, freesans, text, Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
          oldWindSpeed = text;
        }

      }
    }

    function toImperial(temperature) {
       return temperature * 9 / 5 + 32;
    }


    function draw(dc) {
       if (Toybox.System has :ServiceDelegate) {
         var weatherStyle = App.getApp().getProperty("WeatherStyle");
         var windStyle = App.getApp().getProperty("WindStyle");
         var forecastTime = App.getApp().getProperty("forecastTime");
         var forecastTemp = App.getApp().getProperty("forecastTemp");
         var forecastWeather = App.getApp().getProperty("forecastWeather");
         var forecastWindSpeed = App.getApp().getProperty("forecastWindSpeed");
         var forecastWindDirection = App.getApp().getProperty("forecastWindDirection");
         var currentWindSpeed = App.getApp().getProperty("currentWindSpeed");
         var currentDirection = App.getApp().getProperty("currentWindDirection");

         if (Sys.getDeviceSettings() has :requiresBurnInProtection && Sys.getDeviceSettings().requiresBurnInProtection && timelessView.isLowPower()) {
           return;
         }

         oldWeather = null;
         oldTemperature = null;
         oldWindSpeed = null;
         oldWindDirection = null;

         if (forecastTime != null && forecastTemp != null && forecastWeather != null && forecastWindSpeed !=null && forecastWindDirection != null) {
           for (var segment = 0; segment < forecastTime.size(); segment +=1) {
              if (forecastTime[segment]!=null) {
                var time = new Time.Moment(forecastTime[segment]);
                var hour = Time.Gregorian.utcInfo(time, Time.FORMAT_MEDIUM).hour;
                var weather = forecastWeather[segment];
                var temperature = System.getDeviceSettings().temperatureUnits == System.UNIT_METRIC ? forecastTemp[segment] : toImperial(forecastTemp[segment]);
                var speed = forecastWindSpeed[segment];
                var direction = forecastWindDirection[segment];

                temperature = weatherStyle == 0 ? null : temperature;
                temperature = weatherStyle == 1 && timelessView.isLowPower() ? null : temperature;

                weather = weatherStyle == 0 ? null : weather;
                weather = weatherStyle == 1 && timelessView.isLowPower() ? null : weather;

                speed = windStyle == 0 ? null : speed;
                speed = windStyle == 1 && timelessView.isLowPower() ? null : speed;
                direction = windStyle == 0 ? null : direction;
                direction = windStyle == 1 && timelessView.isLowPower() ? null : direction;

                if (Time.now().subtract(new Time.Duration(Time.Gregorian.SECONDS_PER_HOUR * 3)).lessThan(time)) {
                      drawForecastSegment(temperature, weather, hour, speed, direction, dc);
                }
              }
            }
         }

         if (currentWindSpeed != null && currentDirection != null && ((windStyle > 1) || (windStyle == 1 && !timelessView.isLowPower()))) {
            var textPosX = dc.getWidth() / 2 - 10;
            var textPosY = dc.getHeight() / 2 - Gfx.getFontHeight(large)/2 - Gfx.getFontHeight(Gfx.FONT_XTINY)/2;

            var pts = [[textPosX - 8 * Toybox.Math.sin(Toybox.Math.PI * currentDirection / 180), textPosY + 8 * Toybox.Math.cos(Toybox.Math.PI * currentDirection / 180)],
                 [textPosX + 8 * Toybox.Math.sin(Toybox.Math.PI * (currentDirection - 30) / 180), textPosY - 8 * Toybox.Math.cos(Toybox.Math.PI * (currentDirection - 30) / 180)],
                 [textPosX + 6 * Toybox.Math.sin(Toybox.Math.PI * (currentDirection) / 180), textPosY - 6 * Toybox.Math.cos(Toybox.Math.PI * (currentDirection) / 180)],
                 [textPosX + 8 * Toybox.Math.sin(Toybox.Math.PI * (currentDirection + 30) / 180), textPosY - 8 * Toybox.Math.cos(Toybox.Math.PI * (currentDirection + 30) / 180)]];
            dc.setColor(Gfx.COLOR_LT_GRAY, Gfx.COLOR_LT_GRAY);
            dc.fillPolygon(pts);

            textPosX = dc.getWidth() / 2 + 10;
            textPosY = dc.getHeight() / 2 - Gfx.getFontHeight(large)/2 - Gfx.getFontHeight(Gfx.FONT_XTINY)/2;
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
            dc.drawText(textPosX, textPosY, freesans_outline, formatWindSpeed(currentWindSpeed), Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
            dc.drawText(textPosX, textPosY, freesans, formatWindSpeed(currentWindSpeed), Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER);
         }
       }
    }
}