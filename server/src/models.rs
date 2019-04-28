use super::schema::documents;

#[derive(Queryable)]
pub struct Document {
    pub id: i32,
    pub title: String,
    pub image: String,
}

#[derive(Insertable)]
#[table_name = "documents"]
pub struct NewDocument {
    pub title: String,
    pub image: String,
}
