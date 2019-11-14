using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.ActivityMonitor as Monitor;
using Toybox.Lang as Lang;

class Steps extends timelessWidget {
    function initialize() {
        className = "Steps";
        sector = 0;
        timelessWidget.initialize();
        font = Ui.loadResource(Rez.Fonts.id_symbol);
    }

    function draw(dc) {
        text = Lang.format("👣$1$", [Monitor.getInfo().steps.format("%d")]);
        level = Monitor.getInfo().steps * 100 / Monitor.getInfo().stepGoal;
        timelessWidget.draw(dc);
    }
}