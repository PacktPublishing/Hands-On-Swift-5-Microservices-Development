import Fluent
import Vapor
import SimpleJWTMiddleware

func routes(_ app: Application) throws {
    let root = app.grouped(.anything, "products")
    let authorized = root.grouped(SimpleJWTMiddleware())

    root.get("health") { request in
        return "All good!"
    }
    
    let productsController = ProductsController()
    let categoriesController = CategoriesController()
    
    root.get("categories", use: categoriesController.get)
    authorized.post("categories", use: categoriesController.new)
    authorized.patch("categories", ":id", use: categoriesController.edit)
    authorized.delete("categories", ":id", use: categoriesController.delete)
    
    root.get("", use: productsController.get)
    authorized.post("", use: productsController.new)
    authorized.patch(":id", use: productsController.edit)
    authorized.delete(":id", use: productsController.delete)
}
