import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }
    
    app.get("hello") { req in
        return "Hello, world!"
    }

    let todoController = TodoController()
    let newController = NewController()
    app.get("todos", use: todoController.index)
    app.post("todos", use: todoController.create)
    app.get("example", use: newController.index)
    app.on(.DELETE, "todos", ":todoID", use: todoController.delete)
}
