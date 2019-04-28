open Js.Typed_array;

let fillArrayBufferFromString =
    (decodedString: string, arrayBuffer: Uint8Array.t) => {
  Uint8Array.mapi(
    (. _, index) => truncate(Js.String.charCodeAt(index, decodedString)),
    arrayBuffer,
  );
};

Elm.Ports.renderImage(
  Elm.newApp,
  (imageUrl: string) => {
    let decodedString =
      Js.String.split(",", imageUrl)->Array.unsafe_get(1)
      |> Webapi.Base64.atob;

    Js.String.length(decodedString)
    |> Uint8Array.fromLength
    |> fillArrayBufferFromString(decodedString)
    |> Psd.renderPsd
    |> Render.renderPsd("canvas");
    /*Render.renderImageWithDataUrl(imageUrl, "canvas");*/
    /*Render.renderPsd(parsedDocument, "canvas");*/
  },
);