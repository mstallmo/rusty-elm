open Js.Typed_array;

let fillArrayBufferFromString =
    (decodedString: string, arrayBuffer: Uint8Array.t) => {
  Uint8Array.mapi(
    (. _, index) => truncate(Js.String.charCodeAt(index, decodedString)),
    arrayBuffer,
  );
};

let fillClampedArrayFromArray =
    (inputArray: array(int), arrayBuffer: Uint8ClampedArray.t) => {
  Uint8ClampedArray.mapi((. _, index) => inputArray[index], arrayBuffer);
};

Elm.Ports.openPSDDocument(
  Elm.newApp,
  (imageUrl: string) => {
    let decodedString =
      Js.String.split(",", imageUrl)->Array.get(1) |> Webapi.Base64.atob;

    let document =
      Js.String.length(decodedString)
      |> Uint8Array.fromLength
      |> fillArrayBufferFromString(decodedString)
      |> Psd.parsePsd;

    Elm.Ports.documentUpdated(Elm.newApp, document);
  },
);

Elm.Ports.renderLayers(
  Elm.newApp,
  (layers: array(Psd.layer)) => {
    let _ =
      Array.map(
        layer =>
          if (layer##visible == true) {
            let clampedArrayBuffer =
              Array.length(layer##image)
              |> Uint8ClampedArray.fromLength
              |> fillClampedArrayFromArray(layer##image);
            Render.renderPsd(
              layer##name,
              Webapi.Dom.Image.makeWithData(
                ~array=clampedArrayBuffer,
                ~width=Js.Int.toFloat(500),
                ~height=Js.Int.toFloat(500),
              ),
            );
          } else {
            Render.clearCanvas(layer##name);
          },
        layers,
      );
    ();
  },
);