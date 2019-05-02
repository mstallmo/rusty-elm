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

Elm.Ports.renderImage(
  Elm.newApp,
  (imageUrl: string) => {
    let decodedString =
      Js.String.split(",", imageUrl)->Array.get(1) |> Webapi.Base64.atob;

    let layerList: array(Psd.layer) =
      Js.String.length(decodedString)
      |> Uint8Array.fromLength
      |> fillArrayBufferFromString(decodedString)
      |> Psd.parsePsd;

    let firstLayer: Psd.layer = layerList[0];
    let firstClampedArrayBuffer =
      Array.length(firstLayer##image)
      |> Uint8ClampedArray.fromLength
      |> fillClampedArrayFromArray(firstLayer##image);

    Render.renderPsd(
      "canvas",
      Webapi.Dom.Image.makeWithData(
        ~array=firstClampedArrayBuffer,
        ~width=Js.Int.toFloat(firstLayer##width),
        ~height=Js.Int.toFloat(firstLayer##height),
      ),
    );
    let secondLayer = layerList[1];
    Js.log(secondLayer);
    let secondClampedArrayBuffer =
      Uint8ClampedArray.fromLength(4 * 500 * 500)
      |> fillClampedArrayFromArray(secondLayer##image);

    Render.renderPsd(
      "canvas",
      Webapi.Dom.Image.makeWithData(
        ~array=secondClampedArrayBuffer,
        ~width=Js.Int.toFloat(500),
        ~height=Js.Int.toFloat(500),
      ),
    );
    /*Render.getActiveFile("canvas") |> Elm.Ports.activeFile(Elm.newApp);*/
  },
);