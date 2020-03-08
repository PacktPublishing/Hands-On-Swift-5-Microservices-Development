import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get([.anything, "name", "health"]) { req in
        return "Healthy!"
    }
    
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    let todoController = TodoController()
    app.get("todos", use: todoController.index)
    app.post("todos", use: todoController.create)
    app.delete("todos", ":todoID", use: todoController.delete)
}
