[@bs.module "../crate/pkg/rusty_elm"] external hello: unit => unit = "hello";

[@bs.module "../crate/pkg/rusty_elm"]
external renderPsd: Js.Typed_array.Uint8Array.t => Webapi.Dom.Image.t =
  "render_psd";