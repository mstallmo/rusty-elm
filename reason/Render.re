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

let decodeImage: (string, Psd.layer => unit) => unit = [%raw
  {|(dataUrl, cb) => {
        const image = new Image();
        image.src = dataUrl;

        const canvas = document.createElement('canvas');
        canvas.width = '1280';
        canvas.height = '720';
        const ctx = canvas.getContext('2d');

        image.onload = () => {
             ctx.drawImage(image, 0, 0);
             const imageData = ctx.getImageData(0, 0, 1280, 720);
             cb({ name: "newImage", image: Array.from(imageData.data), width: 1280, height: 720, layerIdx: 2, visible: true});
        }
    }|}
];