using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.ActivityMonitor as Metrics;

class timelessView extends Ui.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var clockTime = Sys.getClockTime();
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        var timeString = Lang.format(timeFormat, [hours, minutes.format("%02d")]);
        var stepsString = Metrics.getInfo().steps.format("%d");

        // Update the view
        var timeView = View.findDrawableById("TimeLabel");
        timeView.setColor(Gfx.COLOR_WHITE);
        timeView.setText(timeString);
        
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();     
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc); 
        
        hours = hours % 12;
        
        dc.setPenWidth(radius/32);
        
       // if (hours > 0) {            
            dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
        	dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, (14*radius)/32, Gfx.ARC_CLOCKWISE, 135 - 30 * hours, 90 - 30 * hours);
       // }
        
       // if (minutes > 0) {
            dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        	dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, (15*radius)/32, Gfx.ARC_CLOCKWISE, 180 - (6 * minutes), 90 - (6 * minutes));
       // }
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
