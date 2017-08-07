using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.ActivityMonitor as Monitor;

class Steps extends timelessWidget {
    function initialize() {       
        className = "Steps";
        sector = 0;
        timelessWidget.initialize();
    }
    
    function draw(dc) {         
        text = Monitor.getInfo().steps.format("%d");
        level = Monitor.getInfo().steps * 100 / Monitor.getInfo().stepGoal;
        timelessWidget.draw(dc);
    }
}