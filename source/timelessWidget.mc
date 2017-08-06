using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

class timelessWidget extends Ui.Drawable {
    
    var className = null;
    var text = "";
    var sector = 0;
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
    
    function drawSector0(dc) {
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        var fontHeight = dc.getFontHeight(Gfx.FONT_TINY);
        
        dc.setPenWidth(5);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius/4 + 16, Gfx.ARC_COUNTER_CLOCKWISE, 48 + sector * 90, 132 + sector * 90);
        
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius/4 + 16, Gfx.ARC_COUNTER_CLOCKWISE, 50 + sector * 90, 130 + sector * 90);
        
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2 - radius/4 - fontHeight / 2, Gfx.FONT_TINY, text, Gfx.TEXT_JUSTIFY_CENTER);     
    }
    
    function drawSector1(dc) {
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        var fontHeight = dc.getFontHeight(Gfx.FONT_TINY);
        
        dc.setPenWidth(5);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius/4 + 16, Gfx.ARC_COUNTER_CLOCKWISE, 48 + sector * 90, 132 + sector * 90);
        
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius/4 + 16, Gfx.ARC_COUNTER_CLOCKWISE, 50 + sector * 90, 130 + sector * 90);
        
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2 - radius/4, dc.getHeight()/2 - fontHeight / 2, Gfx.FONT_TINY, text, Gfx.TEXT_JUSTIFY_CENTER);     
    }
    
    function drawSector2(dc) {
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        var fontHeight = dc.getFontHeight(Gfx.FONT_TINY);
        
        dc.setPenWidth(5);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius/4 + 16, Gfx.ARC_COUNTER_CLOCKWISE, 48 + sector * 90, 132 + sector * 90);
        
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius/4 + 16, Gfx.ARC_COUNTER_CLOCKWISE, 50 + sector * 90, 130 + sector * 90);
        
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2 + radius/4 - fontHeight / 2, Gfx.FONT_TINY, text, Gfx.TEXT_JUSTIFY_CENTER);     
    }
    
    function drawSector3(dc) {
        var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        var fontHeight = dc.getFontHeight(Gfx.FONT_TINY);
        
        dc.setPenWidth(5);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius/4 + 16, Gfx.ARC_COUNTER_CLOCKWISE, 48 + sector * 90, 132 + sector * 90);
        
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius/4 + 16, Gfx.ARC_COUNTER_CLOCKWISE, 50 + sector * 90, 130 + sector * 90);
        
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2 + radius/4, dc.getHeight()/2 - fontHeight / 2, Gfx.FONT_TINY, text, Gfx.TEXT_JUSTIFY_CENTER);     
    }
    
    function draw(dc) {      
        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        dc.clear();  
        
        /*var radius = dc.getWidth() > dc.getHeight() ? dc.getHeight() : dc.getWidth();
        
        dc.setPenWidth(5);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        
        for (var i = 0; i < 4; i+=1) {
        	dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius/4 + 16, Gfx.ARC_COUNTER_CLOCKWISE, 48 + i * 90, 132 + i*90);        
        }
        
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.setPenWidth(1);
        
        for (var i = 0; i < 4; i+=1) {
        	dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, radius/4 + 16, Gfx.ARC_COUNTER_CLOCKWISE, 50 + i * 90, 130 + i*90);        
        } 
        
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);*/
        method(drawText[sector]).invoke(dc);
    }

}