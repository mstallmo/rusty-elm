use actix_web::middleware::Logger;
use actix_web::{fs, server, App, HttpRequest};
use env_logger;

mod api;

fn main() {
    std::env::set_var("RUST_LOG", "actix_web=info");
    env_logger::init();

    server::new(|| {
        vec![
            App::new()
                .prefix("/api")
                .prefix("/v1")
                .middleware(Logger::default())
                .resource("/hello", |r| r.f(api::hello)),
            App::new()
                .middleware(Logger::default())
                .handler(
                    "/",
                    fs::StaticFiles::new("./dist")
                        .unwrap()
                        .index_file("index.html"),
                )
        ]
    })
    .bind("127.0.0.1:8080")
    .unwrap()
    .run();
}
