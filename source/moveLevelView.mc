using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.ActivityMonitor as Monitor;

class Move extends timelessWidget {

    function initialize() {
        fgColor = Gfx.COLOR_RED;
        bgColor = Gfx.COLOR_TRANSPARENT;
        sector = 0;
        segmentCount = 5;
        className = "Move";
        penWidth = 3;

        timelessWidget.initialize();
    }

    function draw(dc) {
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        var y = dc.getHeight()/2 - 11*radius/32 + Gfx.getFontHeight(Gfx.FONT_TINY) + Gfx.getFontHeight(Gfx.FONT_XTINY) / 4;
        var height = 5;
        
        if (Monitor.getInfo().moveBarLevel != null) {
            level = 100 * (Monitor.getInfo().moveBarLevel - Monitor.MOVE_BAR_LEVEL_MIN) / Monitor.MOVE_BAR_LEVEL_MAX;
            timelessWidget.drawSectorRadius(dc, 11*radius/32 + 5, level, segmentCount, penWidth);
        }
    }

}