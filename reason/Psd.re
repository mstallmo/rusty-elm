type layer = {
  .
  "name": string,
  "image": array(int),
  "width": int,
  "height": int,
};

[@bs.module "../crate/pkg/rusty_elm"]
external parsePsd: Js.Typed_array.Uint8Array.t => array(layer) = "parse_psd";