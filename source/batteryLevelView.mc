using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

class Battery extends Ui.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Battery"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc) {
        // Set the background color then call to clear the screen
        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        dc.clear();        
        
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        radius = radius/4 - 15;
        dc.setPenWidth(1);
        dc.drawCircle(dc.getWidth()/2, dc.getHeight()/2, radius);
        
        var batteryLevel = System.getSystemStats().battery;
        dc.setPenWidth(3);
        dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius , Gfx.ARC_COUNTER_CLOCKWISE, 90, 90 + (batteryLevel * 360) / 100);
        
    }

}