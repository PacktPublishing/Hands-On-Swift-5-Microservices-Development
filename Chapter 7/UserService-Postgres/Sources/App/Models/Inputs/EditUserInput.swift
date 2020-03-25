import Vapor

struct EditUserInput: Content {
    let firstname: String?
    let lastname: String?
}
