use actix_web::{fs, server, App};
use actix_web::middleware::Logger;
use env_logger;

fn main() {
    std::env::set_var("RUST_LOG", "actix_web=info");
    env_logger::init();

    server::new(|| App::new().middleware(Logger::default()).handler("/", fs::StaticFiles::new("./dist").unwrap().index_file("index.html")))
        .bind("127.0.0.1:8080")
        .unwrap()
        .run();
}
