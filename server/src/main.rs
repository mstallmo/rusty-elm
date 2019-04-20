use actix_web::{fs, server, App};

fn main() {
    server::new(|| App::new().handler("/", fs::StaticFiles::new("./dist").unwrap().index_file("index.html")))
        .bind("127.0.0.1:8080")
        .unwrap()
        .run();
}
