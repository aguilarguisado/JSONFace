import Toybox.WatchUi;

    var MAX_LINES_COUNT = 10;

    var lineTranslation;
    var valueTranslations = new [FEATURES_COUNT];

class JSONFaceSettingsMenu extends WatchUi.Menu2 {

    var settingsTitle = Application.loadResource(Rez.Strings.settings);

    function initialize() {
        initializeTranslations();


        Menu2.initialize(null);
        Menu2.setTitle(settingsTitle);
        
        for(var i = 1; i <= MAX_LINES_COUNT; i++) {
            Menu2.addItem(
                new MenuItem(
                    // entry label
                    lineTranslation + " " + i,
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
        lineTranslation = Application.loadResource(Rez.Strings.line);

        valueTranslations[FeatureEnum.EMPTY] = Application.loadResource(Rez.Strings.empty);
        valueTranslations[FeatureEnum.DATE] = Application.loadResource(Rez.Strings.date);
        valueTranslations[FeatureEnum.TIME] = Application.loadResource(Rez.Strings.time);
        valueTranslations[FeatureEnum.BATTERY] = Application.loadResource(Rez.Strings.battery);
        valueTranslations[FeatureEnum.BLUETOOTH] = Application.loadResource(Rez.Strings.bluetooth);
        valueTranslations[FeatureEnum.STEPS] = Application.loadResource(Rez.Strings.steps);
        valueTranslations[FeatureEnum.DISTANCE] = Application.loadResource(Rez.Strings.distance);
        valueTranslations[FeatureEnum.HR] = Application.loadResource(Rez.Strings.hr);
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
