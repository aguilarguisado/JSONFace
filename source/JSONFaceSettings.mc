import Toybox.WatchUi;

// TODO: Currently all the features are enabled by default. This should be changed depending on the availability.
var enabledFeatures = [
    FeatureEnum.EMPTY,
    FeatureEnum.DATE,
    FeatureEnum.TIME,
    FeatureEnum.BATTERY,
    FeatureEnum.BLUETOOTH,
    FeatureEnum.STEPS,
    FeatureEnum.DISTANCE,
    FeatureEnum.HR
];
var MAX_NUMBER_OF_ATTRIBUTES_KEY = "maxNumberOfAttributes";
var valueTranslations = new [FEATURES_COUNT];
class JSONFaceSettingsMenu extends WatchUi.Menu2 {
    var maxNumberOfAttributes = Application.Properties.getValue(MAX_NUMBER_OF_ATTRIBUTES_KEY);
    var settingsTitle = Application.loadResource(Rez.Strings.settings);
    var lineTranslations;

    function initialize() {
        lineTranslations = new [maxNumberOfAttributes];
        initializeTranslations();

        Menu2.initialize(null);
        Menu2.setTitle(settingsTitle);
        
        // Add items dynamically based on the maximum number of features
        for (var i = 0; i < maxNumberOfAttributes; i++) {
            var key = "Line" + (i+1);
            var propertyValue = Application.Properties.getValue(key);
            Menu2.addItem(new MenuItem(
                lineTranslations[i],
                valueTranslations[propertyValue],
                key,
                {}
            ));
        }
    }

    private function initializeTranslations() {
        valueTranslations[FeatureEnum.EMPTY] = Application.loadResource(Rez.Strings.empty);
        valueTranslations[FeatureEnum.DATE] = Application.loadResource(Rez.Strings.date);
        valueTranslations[FeatureEnum.TIME] = Application.loadResource(Rez.Strings.time);
        valueTranslations[FeatureEnum.BATTERY] = Application.loadResource(Rez.Strings.battery);
        valueTranslations[FeatureEnum.BLUETOOTH] = Application.loadResource(Rez.Strings.bluetooth);
        valueTranslations[FeatureEnum.STEPS] = Application.loadResource(Rez.Strings.steps);
        valueTranslations[FeatureEnum.DISTANCE] = Application.loadResource(Rez.Strings.distance);
        valueTranslations[FeatureEnum.HR] = Application.loadResource(Rez.Strings.hr);

        var lineTemplate = Application.loadResource(Rez.Strings.line_n);
        for (var i=0; i<lineTranslations.size(); i++) {
            lineTranslations[i] = Lang.format(lineTemplate, [i+1]);
        }
    }
}

import Toybox.WatchUi;

class JSONFaceSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    var jsonFaceView2;

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
        jsonFaceView2.refreshActiveLines();
        item.setSubLabel(valueTranslations[newValue]);
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
