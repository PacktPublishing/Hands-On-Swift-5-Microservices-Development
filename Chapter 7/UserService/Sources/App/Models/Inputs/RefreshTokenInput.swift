import Vapor

struct RefreshTokenInput: Content {
    let refreshToken: String
}
