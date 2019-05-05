// Generated by BUCKLESCRIPT VERSION 5.0.3, PLEASE EDIT WITH CARE


var renderImageWithDataUrl = ((dataUrl, id) => {

    const canvas = document.getElementById(id);
    const ctx = canvas.getContext('2d');

    const img = new Image();
    img.src = dataUrl;
    img.onload = () => {
        ctx.drawImage(img, 0, 0);
    }
  });

var renderPsd = ((id, imageData) => {
        const canvas = document.getElementById(id);
        const ctx = canvas.getContext('2d');
        ctx.putImageData(imageData, 0, 0);
    });

var getActiveFile = ((id) => {
        const canvas = document.getElementById(id);
        return canvas.toDataURL();
    });

export {
  renderImageWithDataUrl ,
  renderPsd ,
  getActiveFile ,
  
}
/* renderImageWithDataUrl Not a pure module */
