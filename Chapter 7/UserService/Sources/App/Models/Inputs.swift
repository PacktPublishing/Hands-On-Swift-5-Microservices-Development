import Vapor

struct AddressBody: Content {
    let street: String
    let city: String
    let zip: String
}

struct EditUserBody: Content {
    let firstname: String?
    let lastname: String?
}
