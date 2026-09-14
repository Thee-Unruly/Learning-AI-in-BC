(function () {
    if (window.initAIChatBot) {
        window.initAIChatBot();
    }
    if (typeof Microsoft !== 'undefined' && Microsoft.Dynamics && Microsoft.Dynamics.NAV) {
        Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('ControlReady', []);
    }
})();
