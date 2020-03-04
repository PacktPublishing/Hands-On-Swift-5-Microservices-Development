import Fluent
import Vapor
import SendGrid

func routes(_ app: Application) throws {
    let root = app.grouped(.anything, "users")
    let authorized = root.grouped(JWTMiddleware())

    root.get("health") { request in
        return "All good!"
    }
    
    let productsController = ProductsController()
    let categoriesController = CategoriesController()
    
    root.get("categories", use: categoriesController.get)
    authorized.post("categories", use: categoriesController.new)
    authorized.patch("categories/:id", use: categoriesController.edit)
    authorized.delete("categories/:id", use: categoriesController.delete)
    
    root.get("", use: productsController.get)
    authorized.post("", use: productsController.new)
    authorized.patch(":id", use: productsController.edit)
    authorized.delete(":id", use: productsController.delete)
}
