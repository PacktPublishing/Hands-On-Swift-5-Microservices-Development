import Vapor

struct LoginResponse: Content {
    let status = "success"
    let accessToken: String
    let refreshToken: String
    let user: UserResponse
}
