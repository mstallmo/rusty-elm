/*
      Initialize an Elm application and setup any ports needed
 */

type document;
[@bs.send] external getElementById: (document, string) => Dom.element = "";
[@bs.val] external doc: document = "document";

[@bs.deriving abstract]
type elmInit = {node: Dom.element};

type app;
[@bs.module "../elm/Main.elm"] [@bs.scope ("Elm", "Main")]
external init: elmInit => app = "";

let newApp = init(elmInit(~node=getElementById(doc, "elm")));

module Ports = {
  [@bs.send] [@bs.scope ("ports", "openPSDDocument")]
  external openPSDDocument: (app, string => unit) => unit = "subscribe";

  [@bs.send] [@bs.scope ("ports", "activeFile")]
  external activeFile: (app, string) => unit = "send";
};