import Vapor

struct UserSuccessResponse: Content {
    let status: String = "success"
    let user: UserResponse
}

struct UserResponse: Content {
    let id: Int?
    let firstname, lastname: String?
    let email: String
    let addresses: [Address]?
    
    init(user: User, addresses: [Address]?) {
        self.id = user.id
        self.firstname = user.firstname
        self.lastname = user.lastname
        self.email = user.email
        self.addresses = addresses
    }
}
struct LoginResponse: Content {
    let status = "success"
    let accessToken: String
    let refreshToken: String
    let user: UserResponse
}
