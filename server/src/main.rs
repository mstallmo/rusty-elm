#[macro_use]
extern crate diesel;

use actix_files as fs;
use actix_web::{web, App, HttpServer, http::header, FromRequest, middleware::Logger, middleware::cors::Cors};
use diesel::pg::PgConnection;
use diesel::prelude::*;
use diesel::r2d2::{self, ConnectionManager};
use dotenv::dotenv;
use env_logger;

mod api;
mod models;
mod schema;

pub type Pool = r2d2::Pool<ConnectionManager<PgConnection>>;

fn main() -> std::io::Result<()> {
    std::env::set_var("RUST_LOG", "actix_web=info");
    env_logger::init();
    dotenv().ok();

    let database_url = std::env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    let manager = ConnectionManager::<PgConnection>::new(database_url.as_ref());
    let pool = r2d2::Pool::builder()
        .build(manager)
        .expect("Failed to create pool");

    HttpServer::new(move || {
        App::new()
            .data(pool.clone())
            .wrap(Logger::default())
            .wrap(
                Cors::new()
                    .allowed_origin("http://localhost:8080")
                    .allowed_methods(vec!["GET", "POST"])
                    .allowed_headers(vec![header::AUTHORIZATION, header::ACCEPT])
                    .allowed_header(header::CONTENT_TYPE)
                    .max_age(3600),
            )
            .service(
                web::scope("/api").service(
                    web::scope("/v1")
                        .service(web::resource("/hello").route(web::get().to(api::hello)))
                        .service(
                            web::resource("/saveImage")
                                .route(web::post().data(web::Json::<api::DocumentRequest>::configure(|cfg| {
                                    cfg.limit(2_097_152)
                                })).to_async(api::save_image)),
                        ),
                ),
            )
            .service(fs::Files::new("/", "./dist/").index_file("index.html"))
    })
    .bind(std::env::var("PORT").unwrap())
    .unwrap()
    .run()
}
