import Vapor

/// Our payload.
struct JWTPayload: Content {
    let firstname: String?
    let lastname: String?
    let email: String
    let id: Int
    let exp: TimeInterval
    let iat: TimeInterval
}
