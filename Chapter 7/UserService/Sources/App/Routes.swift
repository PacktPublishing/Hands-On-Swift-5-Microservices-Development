import Fluent
import Vapor
import SendGrid
import SimpleJWTMiddleware

func routes(_ app: Application, _ sendgridClient: SendGridClient) throws {
    let root = app.grouped(.anything, "users")
    let auth = root.grouped(SimpleJWTMiddleware())

    root.get("health") { request in
        return "All good!"
    }
    
    try root.register(collection: AddressController())
    try root.register(collection: AuthController(sendgridClient))
    try auth.register(collection: UserController())
}
