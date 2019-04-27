/*let fillArrayBufferFromString =
      (decodedString: string, arrayBuffer: Uint8Array.t) => {
    Uint8Array.mapi(
      (element, index) =>
        truncate(Js.String.charCodeAt(index, decodedString)),
      arrayBuffer,
    );
  };*/

Elm.Ports.renderImage(
  Elm.newApp,
  (imageUrl: string) => {
    let decodedString =
      Js.String.split(",", imageUrl)->Js_array.unsafe_get(1)
      |> Webapi.Base64.atob;

    let stringArray =
      Js.String.castToArrayLike(decodedString) |> Js.Array.from;

    let arrayBuffer =
      Js.String.length(decodedString) |> Js_typed_array.Uint8Array.fromLength;
    /*|> fillArrayBufferFromString(decodedString, decodedArray);*/

    let _ =
      Js.Array.mapi(
        (element, index) => {
          Js.Typed_array.Uint8Array.unsafe_set(
            arrayBuffer,
            index,
            truncate(Js.String.charCodeAt(index, decodedString)),
          );
          element;
        },
        stringArray,
      );

    Js.log(arrayBuffer);
    let parsedDocument = Psd.renderPsd(arrayBuffer);

    /*Render.renderImageWithDataUrl(imageUrl, "canvas");*/
    Render.renderPsd(parsedDocument, "canvas");
  },
);