let renderImageWithDataUrl: (string, string) => unit = [%raw
  {|(dataUrl, id) => {

    const canvas = document.getElementById(id);
    const ctx = canvas.getContext('2d');

    const img = new Image();
    img.src = dataUrl;
    img.onload = () => {
        ctx.drawImage(img, 0, 0);
    }
  }|}
];

let renderPsd: (string, Webapi.Dom.Image.t) => unit = [%raw
  {|(id, imageData) => {
        const canvas = document.getElementById(id);
        const ctx = canvas.getContext('2d');
        ctx.putImageData(imageData, 0, 0);
    }|}
];

let clearCanvas: string => unit = [%raw
  {|(id) => {
        const canvas = document.getElementById(id);
        const ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, canvas.width, canvas.height);
    }|}
];

let getActiveFile: string => string = [%raw
  {|(id) => {
        const canvas = document.getElementById(id);
        return canvas.toDataURL();
    }|}
];

let decodeImage: (string, Js.Typed_array.Uint8ClampedArray.t => unit) => unit = [%raw
  {|(dataUrl, cb) => {
        const image = new Image();
        image.src = dataUrl;

        const canvas = new OffscreenCanvas(image.width, image.height);
        const ctx = canvas.getContext('2d');

        image.decode()
            .then(() => {
                 ctx.drawImage(image, 0, 0);
                 const imageData = ctx.getImageData(0, 0, image.width, image.height);
                 cb(imageData);
            });
    }|}
];