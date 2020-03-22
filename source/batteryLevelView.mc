using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class Battery extends timelessWidget {

    var symbols;

    function initialize() {

        bgColor = Gfx.COLOR_RED;
        fgColor = Gfx.COLOR_GREEN;
        sector = 3;
        font = Gfx.FONT_XTINY;

        className = "Battery";
        symbols = Ui.loadResource(Rez.Fonts.id_symbol);
        timelessWidget.initialize();
    }

    function draw(dc) {
        if (Sys.getDeviceSettings().requiresBurnInProtection && timelessView.isLowPower()) {
           return;
         }

        level = System.getSystemStats().battery;
        var style = App.getApp().getProperty("BatteryLevelStyle");
        if (style == 2 || (style == 1 && level < 20)) {
          text = level.format("%d")+"%";
        } else {
          text = "";
        }
        if (level < 20) {
          txtColor = Gfx.COLOR_RED;
        } else {
          txtColor = Gfx.COLOR_WHITE;
        }
        timelessWidget.draw(dc);
        dc.setColor(txtColor, Gfx.COLOR_TRANSPARENT);
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        dc.drawText(dc.getWidth()/2 + 8 * radius/32, dc.getHeight()/2, symbols, "🔋", Gfx.TEXT_JUSTIFY_CENTER | Gfx.TEXT_JUSTIFY_VCENTER);
    }

}