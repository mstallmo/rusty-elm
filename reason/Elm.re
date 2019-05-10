/*
      Initialize an Elm application and setup any ports needed
 */

type document;
[@bs.send] external getElementById: (document, string) => Dom.element = "";
[@bs.val] external doc: document = "document";

[@bs.val] [@bs.scope ("process", "env")] external apiUrl: string = "API_URL";

[@bs.deriving abstract]
type elmInit = {
  node: Dom.element,
  flags: string,
};

type app;
[@bs.module "../elm/Main.elm"] [@bs.scope ("Elm", "Main")]
external init: elmInit => app = "";

let newApp = init(elmInit(~node=getElementById(doc, "elm"), ~flags=apiUrl));

module Ports = {
  [@bs.send] [@bs.scope ("ports", "openPSDDocument")]
  external openPSDDocument: (app, string => unit) => unit = "subscribe";

  [@bs.send] [@bs.scope ("ports", "renderLayers")]
  external renderLayers: (app, array(Psd.layer) => unit) => unit =
    "subscribe";

  [@bs.send] [@bs.scope ("ports", "documentUpdated")]
  external documentUpdated: (app, Psd.document) => unit = "send";
};