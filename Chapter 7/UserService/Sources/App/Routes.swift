import Fluent
import Vapor
import SendGrid
import SimpleJWTMiddleware

func routes(_ app: Application) throws {
    let root = app.grouped(.anything, "users")
    let auth = root.grouped(SimpleJWTMiddleware())

    root.get("health") { request in
        return "All good!"
    }
    
    try auth.grouped("addresses").register(collection: AddressController())
    try root.register(collection: AuthController())
    try auth.register(collection: UserController())
}
