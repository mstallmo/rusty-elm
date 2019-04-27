Elm.Ports.hello(
  Elm.newApp,
  () => {
    Psd.hello();
    Js.log("Calling this port from ReasonML");
  },
);

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

    let arrayBuffer =
      Js.String.length(decodedString) |> Js_typed_array.Uint8Array.fromLength;
    /*|> fillArrayBufferFromString(decodedString, decodedArray);*/

    Js.log(arrayBuffer);

    Render.renderPsd(imageUrl, "canvas");
  },
);