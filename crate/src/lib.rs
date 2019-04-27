use psd::Psd;
use wasm_bindgen::prelude::*;
use wasm_bindgen::Clamped;
use web_sys;

mod utils;

// When the `wee_alloc` feature is enabled, use `wee_alloc` as the global
// allocator.
#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = console)]
    fn log(msg: &str);
}

#[wasm_bindgen]
pub fn render_psd(array_buffer: &mut [u8]) -> web_sys::ImageData {
    let psd = Psd::from_bytes(array_buffer).unwrap();

    let mut psd_pixels = psd.flatten_layers_rgba(&|(_idx, _layer)| true).unwrap();

    let psd_pixels = Clamped(&mut psd_pixels[..]);

    log("About to send back image data");

    web_sys::ImageData::new_with_u8_clamped_array_and_sh(psd_pixels, psd.width(), psd.height())
        .unwrap()
}
