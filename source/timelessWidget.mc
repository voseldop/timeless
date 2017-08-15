using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

class timelessWidget extends Ui.Drawable {
    
    var className = null;
    var text = "";
    var sector = 0;
    var level = 50;
    var segmentCount = 10;
    var bgColor = Gfx.COLOR_DK_GRAY;
    var fgColor = Gfx.COLOR_WHITE;
    var drawText = {
        0 => :drawSector0,
        1 => :drawSector1,
        2 => :drawSector2,
        3 => :drawSector3
    };
    
    function initialize() {
        var dictionary = {
            :identifier => className
        };

        Drawable.initialize(dictionary);
    }
    
    function drawSector(dc) {
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        
        dc.setPenWidth(radius/32);
        for (var i=0; i<segmentCount; i++) {
            if (level > 100 * (segmentCount - i - 1)/segmentCount) {
                dc.setColor(fgColor, Gfx.COLOR_TRANSPARENT);
            } else {
                dc.setColor(bgColor, Gfx.COLOR_TRANSPARENT);
            }
            if (sector < 2) {        
            dc.drawArc(dc.getWidth()/2, 
                       dc.getHeight()/2, 
                       10*radius/32, 
                       Gfx.ARC_COUNTER_CLOCKWISE, 
                       49 + (132 - 48)*i/segmentCount + sector * 90, 
                       47 + (132 - 48)*(i+1)/segmentCount + sector * 90 );
            } else {
            dc.drawArc(dc.getWidth()/2, 
                       dc.getHeight()/2, 
                       10*radius/32, 
                       Gfx.ARC_COUNTER_CLOCKWISE,  
                       49 + (132 - 48)*(segmentCount - i - 1)/segmentCount + sector * 90,
                       47 + (132 - 48)*(segmentCount - i)/segmentCount + sector * 90 );
            }
            
        }
    }
    
    function drawSector0(dc) {
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        var fontHeight = dc.getFontHeight(Gfx.FONT_TINY);
        
        drawSector(dc);
        
        dc.setColor(fgColor, Gfx.COLOR_TRANSPARENT);        
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - 11*radius/32 + fontHeight / 2, Gfx.FONT_TINY, text, Gfx.TEXT_JUSTIFY_CENTER);     
    }
    
    function drawSector1(dc) {
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        var fontHeight = dc.getFontHeight(Gfx.FONT_TINY);
        
        drawSector(dc);
        
        dc.setColor(fgColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2 - 9 *radius/32, dc.getHeight()/2 - fontHeight / 2, Gfx.FONT_TINY, text, Gfx.TEXT_JUSTIFY_CENTER);     
    }
    
    function drawSector2(dc) {
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        var fontHeight = dc.getFontHeight(Gfx.FONT_TINY);
        
        drawSector(dc);
        
        dc.setColor(fgColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2 + 11*radius/32 - 3 * fontHeight / 2, Gfx.FONT_TINY, text, Gfx.TEXT_JUSTIFY_CENTER);     
    }
    
    function drawSector3(dc) {
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        var fontHeight = dc.getFontHeight(Gfx.FONT_TINY);
        
        drawSector(dc);
        
        dc.setColor(fgColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2 + 9 * radius/32, dc.getHeight()/2 - fontHeight / 2, Gfx.FONT_TINY, text, Gfx.TEXT_JUSTIFY_CENTER);     
    }
    
    function draw(dc) {      
        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        dc.clear();  
 
        method(drawText[sector]).invoke(dc);
    }

}