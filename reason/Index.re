Elm.Ports.subscribe(
  Elm.newApp,
  () => {
    Psd.hello();
    Js.log("Calling this port from ReasonML");
  },
) /*]*/ /*|*/;