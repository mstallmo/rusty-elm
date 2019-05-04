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
        ctx.globalAlpha = 0.2;
        ctx.putImageData(imageData, 0, 0);
    }|}
];

let getActiveFile: string => string = [%raw
  {|(id) => {
        const canvas = document.getElementById(id);
        return canvas.toDataURL();
    }|}
];