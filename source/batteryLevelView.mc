using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

class Battery extends timelessWidget {

    function initialize() {
        
        bgColor = Gfx.COLOR_RED;
        fgColor = Gfx.COLOR_GREEN;
        sector = 3;
        
        className = "Battery";
        timelessWidget.initialize();
    }

    function draw(dc) {
        level = System.getSystemStats().battery;
        if (sector % 2 == 0) {
        	text = level.format("%d")+"%";
        } else {
            text = "";
        }
        timelessWidget.draw(dc);
    }

}