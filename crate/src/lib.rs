use wasm_bindgen::prelude::*;

mod utils;

// When the `wee_alloc` feature is enabled, use `wee_alloc` as the global
// allocator.
#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[wasm_bindgen]
extern {
    #[wasm_bindgen(js_namespace=console)]
    fn log(msg: &str);
}

// Called by our JS entry point to run the example.
#[wasm_bindgen]
pub fn hello() {
    utils::set_panic_hook();

    log("Hellooo from Rust");
}

