import Vapor

struct UserSuccessResponse: Content {
    let status: String = "success"
    let user: UserResponse
}
