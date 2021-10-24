using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;

class Arrows extends Ui.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Arrows"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc) {
      if (Sys.getDeviceSettings() has :requiresBurnInProtection && Sys.getDeviceSettings().requiresBurnInProtection && timelessView.isLowPower()) {
        return;
      }

      var arrowStyle = App.getApp().getProperty("ArrowStyle");

      if (arrowStyle == 0) {
        return;
      }

      var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
      var clockTime = Sys.getClockTime();
      var hours = clockTime.hour;
      var minutes = clockTime.min;

      hours = hours % 12;
      dc.setPenWidth(radius/16);

      if (Toybox.System has :ServiceDelegate) {
        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
        drawArrow(dc, radius, 15, hours * 5 + minutes / 12, 1);

        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        drawArrow(dc, radius, 16, minutes, 1);
      } else {
        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
        drawArrow(dc, radius, 13, hours *5 + minutes / 12, 2);

        dc.setColor(Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT);
        drawArrow(dc, radius, 15, minutes, 2);
      }
    }

    function drawArrow(dc, radius, rpos, lpos, width) {
        for (var penWidth = 1; penWidth < width * radius/32; penWidth = penWidth + 1) {
            dc.setPenWidth(penWidth);
            dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, (rpos*radius)/32, Gfx.ARC_CLOCKWISE,  90 + 5 * width * (radius/16 - penWidth) - 6 * lpos, 90 - 6 * lpos);
        }
        dc.setPenWidth(3);
        dc.drawLine(dc.getWidth()/2 + (11*radius)/32 * Toybox.Math.cos(Toybox.Math.PI * (lpos - 15) / 30),
                    dc.getHeight()/2 + (11*radius)/32 * Toybox.Math.sin(Toybox.Math.PI * (lpos - 15) / 30),
                    dc.getWidth()/2 + (rpos*radius)/32 * Toybox.Math.cos(Toybox.Math.PI * (lpos - 15) / 30),
                    dc.getHeight()/2 + (rpos*radius)/32 * Toybox.Math.sin(Toybox.Math.PI * (lpos - 15) / 30));
    }

}
