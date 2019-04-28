use super::models::{Document, NewDocument};
use actix_web::{web, Error, HttpResponse, Result};
use diesel::pg::PgConnection;
use diesel::prelude::*;
use futures::future::Future;
use serde_derive::Deserialize;

#[derive(Debug, Deserialize)]
pub struct Info {
    data: String,
}

#[derive(Debug, Deserialize)]
pub struct DocumentRequest {
    title: String,
    image: String,
}

pub fn hello() -> &'static str {
    "Hello from the API!"
}

fn insert_document(
    title_string: String,
    image_string: String,
    pool: web::Data<super::Pool>,
) -> Result<super::models::Document, diesel::result::Error> {
    use super::schema::documents;
    use super::schema::documents::dsl::*;

    let conn: &PgConnection = &pool.get().unwrap();

    let new_document = NewDocument {
        title: title_string,
        image: image_string,
    };

    let inserted_document: Document = diesel::insert_into(documents::table)
        .values(&new_document)
        .get_result(conn)
        .expect("Error inserting document");

    Ok(inserted_document)
}

pub fn save_image(
    document_request: web::Json<DocumentRequest>,
    pool: web::Data<super::Pool>,
) -> impl Future<Item = HttpResponse, Error = Error> {
    web::block(move || {
        insert_document(
            document_request.title.to_owned(),
            document_request.image.to_owned(),
            pool,
        )
    })
    .then(|res| match res {
        Ok(_) => Ok(HttpResponse::Ok()
            .content_type("text/plain")
            .body("Saved Document!")),
        Err(_) => Ok(HttpResponse::InternalServerError().into()),
    })
}
