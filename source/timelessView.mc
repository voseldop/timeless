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
        Sys.println("Data recieved");
   
    		var tempView = View.findDrawableById("TemperatureLabel");
    		tempView.setText(temperature);
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
        var temperature = App.getApp().getProperty("temperature");
        
        if (temperature == null) {
            temperature = "?°C";
        }
        
        // Update the view
        var timeView = View.findDrawableById("TimeLabel");
        timeView.setText(timeString);        
        
        // Update the view
        var dateView = View.findDrawableById("DateLabel");
        dateView.setText(dateString + "  " + temperature);
        dateView.setLocation(timeView.locX, dc.getHeight()/2 - 11*radius/32 + Gfx.getFontHeight(Gfx.FONT_TINY) + Gfx.getFontHeight(Gfx.FONT_XTINY) / 4 ); // 20 * radius/32 - 20);
       
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);         
        hours = hours % 12;        
        dc.setPenWidth(radius/16);        
                   
        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
        for (var penWidth = 1; penWidth < radius/16; penWidth = penWidth + 1) {
            dc.setPenWidth(penWidth);
            dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, (12*radius)/32, Gfx.ARC_CLOCKWISE,  90 + 5 * (radius/16 - penWidth) - 30 * hours, 90 - 30 * hours);
        }
           
        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        for (var penWidth = 1; penWidth < radius/16; penWidth = penWidth + 1) {
            dc.setPenWidth(penWidth);
            dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, (14*radius)/32, Gfx.ARC_CLOCKWISE, 90 + 10 * (radius/16 - penWidth) - (6 * minutes), 90 - (6 * minutes));
        }
            
        
        if (Sys.getDeviceSettings().phoneConnected) {
            logo.draw(dc);
        }
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
