import Vapor

struct NewUserInput: Content {
    let firstname: String?
    let lastname: String?
    let email: String
    let password: String
}
