using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class Weather extends Ui.Drawable {
    const METRIC_TEMPERATURE_TMPL = "$1$°";
    const IMPERIAL_TEMPERATURE_TMPL = "$1$°";
    
    var icons = {
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
    
    function drawForecastSegment(temperature, weather, segment, dc) {    
        var rez = icons.get(weather);    
        var image = Ui.loadResource(rez);
        var textPosX = dc.getWidth() / 2;
        var textPosY = dc.getHeight() / 2;
        var textJustification = Gfx.TEXT_JUSTIFY_LEFT;
        var iconX = dc.getWidth() / 2;
        var iconY = dc.getHeight() / 2;
        var text = formatTemperature(temperature);
        var textDimensions = dc.getTextDimensions(text, Gfx.FONT_XTINY);
        	    
	    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	    if (segment == 0) {	       
	       iconX = iconX + 0.77 * iconX - image.getWidth();
	       iconY = iconY - 0.77 * iconY;	       
	       
           textPosX = textPosX + 0.5 * textPosX - textDimensions[0]/2;
           textPosY = textPosY - 0.88 * textPosY;

	    } else if (segment == 1) {
	       iconX = iconX + 0.77 * iconX - image.getWidth();
	       iconY = iconY + 0.77 * iconY - image.getHeight();
	        
           textPosX = textPosX + 0.88 * textPosX - textDimensions[0]/2;
           textPosY = textPosY + 0.5 * textPosY - textDimensions[1];
           
	    } else if (segment == 2) {
		   iconX = iconX - 0.77 * iconX;
	       iconY = iconY + 0.77 * iconY - image.getHeight();

           textPosX = textPosX - 0.5 * textPosX + textDimensions[0]/2;
           textPosY = textPosY + 0.88 * textPosY - textDimensions[1];
	    } else if (segment == 3) {
	       iconX = iconX - 0.77 * iconX;
	       iconY = iconY - 0.77 * iconY;
	       
           textPosX = textPosX - 0.88 * textPosX + textDimensions[0]/2;
           textPosY = textPosY - 0.5 * textPosY;
	    }
	    
	    dc.drawBitmap(iconX, iconY, image);	    
	    dc.drawText(textPosX, textPosY, Gfx.FONT_XTINY, text, Gfx.TEXT_JUSTIFY_CENTER);	    
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
		            var hour = (Time.Gregorian.info(time, Time.FORMAT_MEDIUM).hour % 12) / 3;
		            var weather = forecastWeather[segment];
		            var temperature = forecastTemp[segment];
		            
		            Sys.println("Draw weather " + weather + " temperature " + temperature + " at " + Time.Gregorian.info(time, Time.FORMAT_MEDIUM).hour);
				    drawForecastSegment(temperature, weather, hour, dc);
		       }
	       }
       }
    }
}