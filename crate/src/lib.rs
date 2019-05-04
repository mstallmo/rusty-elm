#[macro_use]
extern crate serde_derive;

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
pub fn parse_psd(array_buffer: &mut [u8]) -> JsValue {
    let psd = Psd::from_bytes(array_buffer).unwrap();

    log("Splitting layers");
    log("test");

    let document = Document {
        width: psd.width(),
        height: psd.height(),
        layers: split_to_layers(&psd),
    };

    JsValue::from_serde(&document).unwrap()
}

#[wasm_bindgen]
#[derive(Serialize)]
pub struct Document {
    width: u32,
    height: u32,
    layers: Vec<Layer>,
}

#[wasm_bindgen]
#[derive(Serialize)]
pub struct Layer {
    name: String,
    image: Vec<u8>,
    width: u16,
    height: u16,
}

fn split_to_layers(document: &psd::Psd) -> Vec<Layer> {
    document
        .layers()
        .iter()
        .map(|layer| Layer {
            name: layer.name().to_owned(),
            image: layer.rgba().unwrap(),
            width: layer.width(),
            height: layer.height(),
        })
        .collect()
}
