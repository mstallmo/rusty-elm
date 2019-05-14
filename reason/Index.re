open Js.Typed_array;

type file = {
  fileType: string,
  fileContents: string,
};

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

let splitFileBodyAndHeader = (fileUrl: string) => {
  let splitFile = Js.String.split(",", fileUrl);
  let fileType = splitFile->Array.get(0) |> Js.String.split(";");

  {fileType: fileType->Array.get(0), fileContents: splitFile->Array.get(1)};
};

Elm.Ports.openFile(
  Elm.newApp,
  (imageUrl: string) => {
    let parsedFile = splitFileBodyAndHeader(imageUrl);

    if (parsedFile.fileType == "data:image/vnd.adobe.photoshop") {
      let decodedString = parsedFile.fileContents |> Webapi.Base64.atob;

      let document =
        Js.String.length(decodedString)
        |> Uint8Array.fromLength
        |> fillArrayBufferFromString(decodedString)
        |> Psd.parsePsd;
      Elm.Ports.documentUpdated(Elm.newApp, document);
    } else {
      Render.decodeImage(imageUrl, (layer: Psd.layer) =>
        Elm.Ports.addNewLayer(Elm.newApp, layer)
      );
    };
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
                ~width=Js.Int.toFloat(layer##width),
                ~height=Js.Int.toFloat(layer##height),
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