[@bs.module "../crate/pkg/rusty_elm"] external hello: unit => unit = "hello";

type document;
[@bs.send] external getElementById: (document, string) => Dom.element = "";
[@bs.val] external doc: document = "document";

[@bs.deriving abstract]
type elmInit = {node: Dom.element};

type app;
[@bs.send] [@bs.scope ("ports", "hello")]
external subscribe: (app, unit => unit) => unit = "";

[@bs.module "../elm/Main.elm"] [@bs.scope ("Elm", "Main")]
external init: elmInit => app = "";

let newApp = init(elmInit(~node=getElementById(doc, "elm")));
subscribe(
  newApp,
  () => {
    hello();
    Js.log("Calling this port from ReasonML");
  },
) /*]*/ /*|*/;