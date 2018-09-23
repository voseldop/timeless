using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.ActivityMonitor as Metrics;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Time;
using Toybox.Background;

var logoX;
var logoY;

class timelessView extends Ui.WatchFace {
    
    const METRIC_TEMPERATURE_TMPL = "$1$°C";
    const IMPERIAL_TEMPERATURE_TMPL = "$1$°F";
    
    var logo;

    function initialize() {
        WatchFace.initialize();
        logo = new Rez.Drawables.Logo();  
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc)); 
        logoX = 10 + dc.getWidth() / 4;
        logoY = 20 * dc.getHeight() / 32;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }
    
    function onWeatherData(temperature, weather) {
		var tempView = View.findDrawableById("TemperatureLabel");
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
        var stepsString = Metrics.getInfo().steps.format("%d");
        var dateInfo = Calendar.info(Time.now(), Calendar.FORMAT_MEDIUM);
        var dateString = Lang.format("$1$ $2$", [dateInfo.day, dateInfo.day_of_week]);
        var temperature = formatTemperature(App.getApp().getProperty("temperature"));
        
        // Update time
        var timeView = View.findDrawableById("TimeLabel");
        timeView.setText(timeString);        
        
        // Update date
        var dateView = View.findDrawableById("DateLabel");
        if (Toybox.System has :ServiceDelegate) {  
        	dateView.setText(dateString + " " + temperature);
        } else {
        	dateView.setText(dateString);
        }
        dateView.setLocation(timeView.locX, dc.getHeight()/2 - 11*radius/32 + Gfx.getFontHeight(Gfx.FONT_TINY) + Gfx.getFontHeight(Gfx.FONT_XTINY) / 4 ); // 20 * radius/32 - 20);
       
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);         
        hours = hours % 12;        
        dc.setPenWidth(radius/16);        
               
        if (Toybox.System has :ServiceDelegate) {   
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);            
            drawArrow(dc, radius, 15, hours *5, 1);      
	           
	        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
	        drawArrow(dc, radius, 16, minutes, 1);
        } else {
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT); 
            drawArrow(dc, radius, 13, hours *5, 2);
	           
	        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
	        drawArrow(dc, radius, 15, minutes, 2);
        }
        
        if (Sys.getDeviceSettings().phoneConnected) {
            logo.draw(dc);
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
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
