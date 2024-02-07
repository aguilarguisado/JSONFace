using Toybox.Graphics;
using Toybox.Lang;
using Toybox.System;
using Toybox.WatchUi;
using Toybox.Activity;
using Toybox.ActivityMonitor;
using Toybox.Time.Gregorian as Date;

class JSONFaceView extends WatchUi.WatchFace {

    private var COLOR_KEYS = 0xff0055;
    private var COLOR_GREEN_STRING = 0x00aa00;
    private var COLOR_ORANGE_NUMBER = 0xffaa00;
    private var FONT = Graphics.FONT_XTINY;

    private var KEY_HEADER_FILENAME_X = "HEADER_FILENAME_X";
    private var KEY_HEADER_FILENAME_Y = "HEADER_FILENAME_Y";
    private var KEY_HEADER_HEIGHT = "HEADER_HEIGHT";
    private var KEY_LINE_START_X = "LINE_START_X";
    private var KEY_LINE_START_Y = "LINE_START_Y";
    private var KEY_JSON_START_X = "JSON_START_X";
    private var KEY_JSON_START_Y = "JSON_START_Y";
    private var KEY_JSON_GAP_SIZE = "JSON_GAP_SIZE";
    private var KEY_JSON_INDENT_SIZE = "JSON_INDENT_SIZE";

    hidden var positions;
    hidden var titleString;
    hidden var dateString;
    hidden var timeString;
    hidden var batteryString;
    hidden var bluetoothString;
    hidden var stepsString;
    hidden var distanceString;
    hidden var heartRateString;
    hidden var connectedString;
    hidden var disconnectedString;

    function initialize() {
        WatchFace.initialize();
        initResources();
    }

    private function initResources(){
        positions = Application.loadResource(Rez.JsonData.screenReferences);
        titleString = Application.loadResource(Rez.Strings.title);
        dateString = Application.loadResource(Rez.Strings.date);
        timeString = Application.loadResource(Rez.Strings.time);
        batteryString = Application.loadResource(Rez.Strings.battery);
        bluetoothString = Application.loadResource(Rez.Strings.bluetooth);
        stepsString = Application.loadResource(Rez.Strings.steps);
        distanceString = Application.loadResource(Rez.Strings.distance);
        heartRateString = Application.loadResource(Rez.Strings.hr);
        connectedString = Application.loadResource(Rez.Strings.connected);
        disconnectedString = Application.loadResource(Rez.Strings.disconnected);
    }

    // Load your resources here
    function onLayout(dc as Graphics.Dc) as Void {
        // Load your resources here
        setLayout(Rez.Layouts.WatchFace(dc));
    }
    
    function onUpdate(dc as Graphics.Dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        drawBackground(dc);
        drawHeader(dc);
        drawLineNumbers(dc);
        drawJSON(dc);
    }

    private function drawBackground(dc as Graphics.Dc){
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }

    private function drawHeader(dc as Graphics.Dc){
        // Draw text
        var headerText = titleString+" x";
        var headerTextLength = dc.getTextDimensions(headerText, FONT)[0];
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(positions.get(KEY_HEADER_FILENAME_X), positions.get(KEY_HEADER_FILENAME_Y), FONT, headerText, Graphics.TEXT_JUSTIFY_LEFT);

        // Draw frame lines
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(0, positions.get(KEY_HEADER_HEIGHT), dc.getWidth(), positions.get(KEY_HEADER_HEIGHT));
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(positions.get(KEY_HEADER_FILENAME_X), positions.get(KEY_HEADER_HEIGHT), positions.get(KEY_HEADER_FILENAME_X) + headerTextLength, positions.get(KEY_HEADER_HEIGHT));
    }

    private function drawLineNumbers(dc as Graphics.Dc){
        var lineNumbers = 9;
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        var lineHeight = dc.getFontHeight(FONT);
        for (var i = 1; i <= lineNumbers; i++) {
            var x = positions.get(KEY_LINE_START_X); // X position for the line number
            var y = positions.get(KEY_LINE_START_Y) + ((i -1) * lineHeight); // Y position for the line number
            var lineNum = i < 10 ? "  " + i : i; // Add a leading zero to single digit numbers
            dc.drawText(x, y, FONT, lineNum.toString(), Graphics.TEXT_JUSTIFY_RIGHT);
        }    
    }
    private function drawJSON(dc as Graphics.Dc){
        drawDelimiter(dc, "{", 1, 0);
        drawProperty(dc, dateString, getDate(), 2, 1);
        drawProperty(dc, timeString, getHoursMinutes(), 3, 1);
        drawProperty(dc, batteryString, getBattery(),4, 1);
        drawProperty(dc, bluetoothString, isConnected(), 5, 1);
        drawProperty(dc, stepsString, getStepCount(), 6, 1);
        drawProperty(dc, distanceString, getDistance(), 7, 1);
        drawPropertyNoDelimiter(dc, heartRateString, getHeartRate(), 8, 1);
        drawDelimiter(dc, "}", 9, 0);
    }


    // Auxiliary functions to draw Lines
    private function drawDelimiter(dc, value, lineNumber, indexNumber){
        var x = getLineX(dc, indexNumber);
        var y = getLineY(dc, lineNumber);
        drawPlainText(dc, x, y, value);
    }

    private function drawProperty(dc, key, value, lineNumber, indexNumber){
        drawPropertyWithDelimiter(dc, key, value, lineNumber, indexNumber, ",");
    }

    private function drawPropertyNoDelimiter(dc, key, value, lineNumber, indexNumber){
        drawPropertyWithDelimiter(dc, key, value, lineNumber, indexNumber, "");
    }

    private function drawPropertyWithDelimiter(dc, key, value, lineNumber, indexNumber, endDelimiter){
        var x = getLineX(dc, indexNumber);
        var y = getLineY(dc, lineNumber);

        var keyWithQuotes = "\""+key+"\"";
        var valueWithQuotes = "\""+value+"\"";
        var valueText = value.toString();

        drawKeyText(dc, x, y, keyWithQuotes);
        
        var textLength = dc.getTextDimensions(keyWithQuotes, FONT)[0];
        var twoPointsX = x + textLength + positions.get(KEY_JSON_GAP_SIZE);
        drawPlainText(dc, twoPointsX , y, ":");

        var valueX = twoPointsX + dc.getTextDimensions(":", FONT)[0] + positions.get(KEY_JSON_GAP_SIZE);
        if(value instanceof Toybox.Lang.String){
            valueText = valueWithQuotes;
            drawStringText(dc, valueX, y, valueText);
        }else if(value instanceof Toybox.Lang.Number){
            drawNumberText(dc, valueX, y, value);
        }else if(value instanceof Toybox.Lang.Float){
            valueText = value.format("%.2f");
            drawNumberText(dc, valueX, y, valueText);
        }
        
        var delimiterX = valueX + dc.getTextDimensions(valueText, FONT)[0];
        drawPlainText(dc, delimiterX, y, endDelimiter);
    }


    // Auxiliary functions to calculate the position of the text
    private function getLineX(dc, levelNumber){
        return positions.get(KEY_JSON_START_X) + (levelNumber * positions.get(KEY_JSON_INDENT_SIZE));
    }

    private function getLineY(dc, lineNumber){
        var lineHeight = dc.getFontHeight(FONT);
        return positions.get(KEY_JSON_START_Y) + ((lineNumber -1) * lineHeight);
    }

    // Auxiliary functions to draw text with different colors
    private function drawPlainText(dc, x, y, content){
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, FONT, content, Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function drawKeyText(dc, x, y, content){
        dc.setColor(COLOR_KEYS, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, FONT, content , Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function drawStringText(dc, x, y, content){
        dc.setColor(COLOR_GREEN_STRING, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, FONT, content , Graphics.TEXT_JUSTIFY_LEFT);
    }

    private function drawNumberText(dc, x, y, content){
        dc.setColor(COLOR_ORANGE_NUMBER, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, FONT, content.toString() , Graphics.TEXT_JUSTIFY_LEFT);
    }

    // Auxiliary functions to get the data
    private function getHoursMinutes() {
        var clockTime = System.getClockTime();
        var hours = clockTime.hour.format("%02d"); // 2-digit hours (24h)
        var minutes = clockTime.min.format("%02d"); // 2-digit minutes
        return hours+":"+minutes;
    }

    private function getDate() {
        // Get the current time
        var now = Time.now();
        // Extract the date info, the strings will be localized
        var date = Date.info(now, Time.FORMAT_MEDIUM); // Extract the date info
        // Format the date into "ddd, MMM, D", for instance: "Thu, Jan 6"
        return Lang.format("$1$, $2$ $3$", [date.day_of_week, date.month, date.day]);
    }

    private function getStepCount() {
        var stepCount = ActivityMonitor.getInfo().steps;
        return stepCount == null ? "--" : stepCount;
    }

    private function getDistance() {
        var distance = ActivityMonitor.getInfo().distance;
        
        // Distance is in cm, convert to km
        return distance == null ? "--" : distance/100000.0;
    }


    private function getHeartRate() {
        // initialize it to null
        var heartRate = "--";

        // Get the activity info if possible
        var info = Activity.getActivityInfo();
        if (info != null) {
            heartRate = info.currentHeartRate;
        } else {
            // Fallback to `getHeartRateHistory`
            var latestHeartRateSample = ActivityMonitor.getHeartRateHistory(1, true).next();
            if (latestHeartRateSample != null) {
                heartRate = latestHeartRateSample.heartRate;
            }
        }

        // Could still be null if the device doesn't support it
        return heartRate == null ? "--" : heartRate.toNumber();
    }

    private function getBattery() {
        var battery = System.getSystemStats().battery;
        return battery.toNumber();
    }

    private function isConnected() {
        var isConnected = System.getDeviceSettings().phoneConnected;
        return isConnected ? connectedString : disconnectedString;
    }
}
