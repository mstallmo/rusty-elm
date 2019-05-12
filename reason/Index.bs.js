// Generated by BUCKLESCRIPT VERSION 5.0.3, PLEASE EDIT WITH CARE

import * as $$Array from "../node_modules/bs-platform/lib/es6/array.js";
import * as Curry from "../node_modules/bs-platform/lib/es6/curry.js";
import * as Caml_array from "../node_modules/bs-platform/lib/es6/caml_array.js";
import * as Elm$ReasonableRustyElm from "./Elm.bs.js";
import * as Psd$ReasonableRustyElm from "./Psd.bs.js";
import * as Render$ReasonableRustyElm from "./Render.bs.js";

function fillArrayBufferFromString(decodedString, arrayBuffer) {
  return arrayBuffer.map((function (param, index) {
                return decodedString.charCodeAt(index) | 0;
              }));
}

function fillClampedArrayFromArray(inputArray, arrayBuffer) {
  return arrayBuffer.map((function (param, index) {
                return Caml_array.caml_array_get(inputArray, index);
              }));
}

function splitFileBodyAndHeader(fileUrl) {
  var splitFile = fileUrl.split(",");
  var fileType = Caml_array.caml_array_get(splitFile, 0).split(";");
  return /* record */[
          /* fileType */Caml_array.caml_array_get(fileType, 0),
          /* fileContents */Caml_array.caml_array_get(splitFile, 1)
        ];
}

Elm$ReasonableRustyElm.newApp.ports.openFile.subscribe((function (imageUrl) {
        var parsedFile = splitFileBodyAndHeader(imageUrl);
        if (parsedFile[/* fileType */0] === "data:image/vnd.adobe.photoshop") {
          var decodedString = atob(parsedFile[/* fileContents */1]);
          var $$document = Psd$ReasonableRustyElm.parsePsd(fillArrayBufferFromString(decodedString, new Uint8Array(decodedString.length)));
          Elm$ReasonableRustyElm.newApp.ports.documentUpdated.send($$document);
          return /* () */0;
        } else {
          return Curry._2(Render$ReasonableRustyElm.decodeImage, imageUrl, (function (imageData) {
                        console.log(imageData);
                        return /* () */0;
                      }));
        }
      }));

Elm$ReasonableRustyElm.newApp.ports.renderLayers.subscribe((function (layers) {
        $$Array.map((function (layer) {
                if (layer.visible === true) {
                  var clampedArrayBuffer = fillClampedArrayFromArray(layer.image, new Uint8ClampedArray(layer.image.length));
                  return Curry._2(Render$ReasonableRustyElm.renderPsd, layer.name, new ImageData(clampedArrayBuffer, 500, 500));
                } else {
                  return Curry._1(Render$ReasonableRustyElm.clearCanvas, layer.name);
                }
              }), layers);
        return /* () */0;
      }));

export {
  fillArrayBufferFromString ,
  fillClampedArrayFromArray ,
  splitFileBodyAndHeader ,
  
}
/*  Not a pure module */
