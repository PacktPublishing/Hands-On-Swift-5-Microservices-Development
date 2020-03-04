import Vapor

struct LoginInput: Content {
    let email: String
    let password: String
}
