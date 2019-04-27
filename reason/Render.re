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

let renderPsd: (Webapi.Dom.Image.t, string) => unit = [%raw
  {|(imageData, id) => {
        const canvas = document.getElementById(id);
        const ctx = canvas.getContext('2d');
        ctx.putImageData(imageData, 0, 0);
    }|}
];