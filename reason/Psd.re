type layer = {
  .
  "name": string,
  "image": array(int),
  "width": int,
  "height": int,
  "layerIdx": int,
  "visible": bool,
};

type document = {
  .
  "width": int,
  "height": int,
  "layers": array(layer),
};

[@bs.module "../crate/pkg/rusty_elm"]
external parsePsd: Js.Typed_array.Uint8Array.t => document = "parse_psd";