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
        var steps = Monitor.getInfo().steps.format("%d");
        var floorsClimbed = "";
        var template = "👣$1$";
        if (Toybox.ActivityMonitor.Info has :floorsClimbed) {
          floorsClimbed = Monitor.getInfo().floorsClimbed.format("%d");
          template = "👣$1$⏫$2$";
        }
        text = Lang.format(template, [steps, floorsClimbed]);
        level = Monitor.getInfo().steps * 100 / Monitor.getInfo().stepGoal;
        timelessWidget.draw(dc);
    }
}