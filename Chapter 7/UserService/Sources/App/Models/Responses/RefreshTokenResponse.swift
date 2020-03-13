import Vapor

struct RefreshTokenResponse: Content {
    let status = "success"
    let accessToken: String
}
