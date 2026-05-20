// `#[derive(Serialize)]` is a procedural macro: serde sees the struct
// at compile time and generates a `Serialize` impl that walks the fields.
// Same idea as C X-macros, but the codegen is hidden behind one attribute.
//
// Inspect the generated code with:
//   cargo expand            (requires `cargo install cargo-expand`)

use serde::Serialize;

#[derive(Serialize)]
struct User {
    id: u32,
    name: String,
    email: String,
    active: bool,
}

fn main() {
    let u = User {
        id: 42,
        name: "alice".into(),
        email: "a@x.com".into(),
        active: true,
    };
    println!("{}", serde_json::to_string(&u).unwrap());
}
