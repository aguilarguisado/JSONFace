import Toybox.WatchUi;

    var lineTranslations = new [10];
    var valueTranslations = new [8];

class JSONFaceSettingsMenu extends WatchUi.Menu2 {

    var settingsTitle = Application.loadResource(Rez.Strings.settings);

    function initialize() {
        initializeTranslations();


        Menu2.initialize(null);
        Menu2.setTitle(settingsTitle); // todo translate
        
        for(var i = 1; i <= 10; i++) {
            Menu2.addItem(
                new MenuItem(
                    // entry label
                    lineTranslations[i-1],
                    // selected value
                    valueTranslations[Application.Properties.getValue("Line" + i)],
                    // property identifier
                    "Line" + i,
                    {}
                )
            );
        }
    }

    private function initializeTranslations() {
        lineTranslations[0] = Application.loadResource(Rez.Strings.line_1);
        lineTranslations[1] = Application.loadResource(Rez.Strings.line_2);
        lineTranslations[2] = Application.loadResource(Rez.Strings.line_3);
        lineTranslations[3] = Application.loadResource(Rez.Strings.line_4);
        lineTranslations[4] = Application.loadResource(Rez.Strings.line_5);
        lineTranslations[5] = Application.loadResource(Rez.Strings.line_6);
        lineTranslations[6] = Application.loadResource(Rez.Strings.line_7);
        lineTranslations[7] = Application.loadResource(Rez.Strings.line_8);
        lineTranslations[8] = Application.loadResource(Rez.Strings.line_9);
        lineTranslations[9] = Application.loadResource(Rez.Strings.line_10);

        valueTranslations[0] = Application.loadResource(Rez.Strings.empty);
        valueTranslations[1] = Application.loadResource(Rez.Strings.date);
        valueTranslations[2] = Application.loadResource(Rez.Strings.time);
        valueTranslations[3] = Application.loadResource(Rez.Strings.battery);
        valueTranslations[4] = Application.loadResource(Rez.Strings.bluetooth);
        valueTranslations[5] = Application.loadResource(Rez.Strings.steps);
        valueTranslations[6] = Application.loadResource(Rez.Strings.distance);
        valueTranslations[7] = Application.loadResource(Rez.Strings.hr);
    }
}

import Toybox.WatchUi;

class JSONFaceSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    var jsonFaceView2;
    var enabledFeatures = Application.loadResource(Rez.JsonData.features);

    function initialize(jsonFaceView) {
        Menu2InputDelegate.initialize();
        jsonFaceView2 = jsonFaceView;
    }

    function onSelect(item) {
        var id=item.getId();
        var currentValue = Application.Properties.getValue(id.toString());
        var newValue = (currentValue + 1) % valueTranslations.size();
        while (newValue != 0 && enabledFeatures.indexOf(newValue) == -1) {
            newValue = (newValue + 1) % valueTranslations.size();
        }
        Application.Properties.setValue(id.toString(), newValue);
        jsonFaceView2.updateSettingProperties();
        item.setSubLabel(valueTranslations[newValue]);
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
