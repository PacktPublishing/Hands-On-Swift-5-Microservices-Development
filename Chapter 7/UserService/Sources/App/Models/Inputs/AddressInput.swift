import Vapor

struct AddressInput: Content {
    let street: String
    let city: String
    let zip: String
}
