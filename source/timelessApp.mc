using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class timelessApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }
    

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new timelessView() ];
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        App.getApp().setProperty("BackgroundColor", 0x555555);
        Ui.requestUpdate();
    }

}