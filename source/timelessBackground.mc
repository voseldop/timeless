using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

class Background extends Ui.Drawable {

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);
    }

    function draw(dc) {
        // Set the background color then call to clear the screen
        var BgColor = App.getApp().getProperty("BackgroundColor");
        if (BgColor == null) {
           BgColor = Gfx.COLOR_BLACK;
        }
        dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK);
        dc.clear();
    }

}
