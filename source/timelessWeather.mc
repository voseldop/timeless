using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

class Weather extends Ui.Drawable {
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
    
    function draw(dc) {      
       var weather = App.getApp().getProperty("weatherCode");
       if (weather != null) {
       	   var rez = icons.get(weather);
	       if (rez != null) {
		       var cloud = Ui.loadResource( rez );
		   	   dc.drawBitmap(0, 0, cloud);
		   	   cloud = null;
		   }  
	   }
    }
}