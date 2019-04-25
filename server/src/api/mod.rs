use actix_web::HttpRequest;

pub fn hello(_req: &HttpRequest) -> &'static str {
    "Hello from the API!"
}
