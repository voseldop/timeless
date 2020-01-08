using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

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
      var duration = App.getApp().getProperty("HRPeriod");
      var style = App.getApp().getProperty("HRStyle");
      try {
        // Check device for SensorHistory compatibility
        if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory) && (style == null || style > 0)) {
            if (style == 1) {
              return Toybox.SensorHistory.getHeartRateHistory({:period => 1});
            } else if (style == 2 && duration instanceof Toybox.Lang.Number) {
                return Toybox.SensorHistory.getHeartRateHistory({:period => new Time.Duration(duration)});
            }
        }
      }
      catch( ex ) {
        System.println(ex.getErrorMessage());
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
              var symbols = Ui.loadResource(Rez.Fonts.id_symbol);

              dc.setColor(fgColor, Gfx.COLOR_TRANSPARENT);

              var text = "";
              if (min != max) {
                text = Lang.format("♥$2$-$3$", [0, min, max]);
              } else {
                text = Lang.format("♥$2$", [0, min, max]);
              }
              dc.drawText(dc.getWidth()/2, dc.getHeight()/2 + Gfx.getFontHeight(Gfx.FONT_SYSTEM_NUMBER_HOT) / 2 + Gfx.getFontHeight(Gfx.FONT_TINY), symbols, text, Gfx.TEXT_JUSTIFY_CENTER);
              symbols = null;
            }
        }
    }

}