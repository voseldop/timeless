using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.ActivityMonitor as Monitor;

class Move extends timelessWidget {

    function initialize() {
        var dictionary = {
            :identifier => "Move"
        };
        
        bgColor = Gfx.COLOR_BLACK;
        fgColor = Gfx.COLOR_RED;
        sector = 1;
        segmentCount = 5;

        Drawable.initialize(dictionary);
    }

    function draw(dc) {
        if (Monitor.getInfo().moveBarLevel != null) {
	        level = 100 * (Monitor.getInfo().moveBarLevel - Monitor.MOVE_BAR_LEVEL_MIN) / Monitor.MOVE_BAR_LEVEL_MAX;
	        timelessWidget.draw(dc);
        }
    }

}