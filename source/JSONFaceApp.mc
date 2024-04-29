import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class JSONFaceApp extends Application.AppBase {


    var jsonFaceView;
 
    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        jsonFaceView = new JSONFaceView();
        return [ jsonFaceView ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() as Void {
        jsonFaceView.updateSettingProperties();
        WatchUi.requestUpdate();
    }

}

function getApp() as JSONFaceApp {
    return Application.getApp() as JSONFaceApp;
}