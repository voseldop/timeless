using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

class Steps extends timelessWidget {
    function initialize() {       
        className = "Steps";
        timelessWidget.initialize();
    }
    
    function draw(dc) { 
        sector = 0;
        text = "0";
        timelessWidget.draw(dc);
    }
}