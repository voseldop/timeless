using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;
using Toybox.Time;

class HeartRate extends Ui.Drawable {

    var fgColor = Gfx.COLOR_WHITE;

    function initialize() {
        var dictionary = {
            :identifier => "HeartRate"
        };

        Drawable.initialize(dictionary);
        fgColor = App.getApp().getProperty("ForegroundColor");
        if (fgColor == null) {
           fgColor = Gfx.COLOR_WHITE;
        }
    }

    function getIterator() {
      // Check device for SensorHistory compatibility
      if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory)) {
          return Toybox.SensorHistory.getHeartRateHistory({:period => 1});
      }
      return null;
  }

    function draw(dc) {
        // Set the background color then call to clear the screen
        var sensorIter = getIterator();

        // Print out the next entry in the iterator
        if (sensorIter != null) {
            var min = sensorIter.getMin();
            var max = sensorIter.getMax();

            if (min != null && max != null) {
              System.println(Lang.format("$1$ $2$", [min, max]));

              var symbols = Ui.loadResource(Rez.Fonts.id_symbol);

              dc.setColor(fgColor, Gfx.COLOR_TRANSPARENT);
              dc.drawText(dc.getWidth()/2, dc.getHeight()/2 + Gfx.getFontHeight(Gfx.FONT_SYSTEM_NUMBER_HOT) / 2 + Gfx.getFontHeight(Gfx.FONT_TINY), symbols, Lang.format("♥$2$-$3$", [0, min, max]), Gfx.TEXT_JUSTIFY_CENTER);
              symbols = null;
            }
        }
    }

}