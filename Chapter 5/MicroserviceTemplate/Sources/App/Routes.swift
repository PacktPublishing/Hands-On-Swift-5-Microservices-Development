import Vapor

func routes(_ app: Application) throws {
    let root = app.grouped(.anything, "users")
    let auth = root.grouped(JWTMiddleware())

    root.get("health") { request in
        return "All good!"
    }
    
    try root.register(collection: TodoController())
}
