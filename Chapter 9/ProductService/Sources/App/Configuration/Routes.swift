import Routing
import Vapor
import JWTMiddleware

public func routes(_ router: Router, _ container: Container) throws {
    let root = router.grouped(any, "users")
    
    root.get("health") { _ in
        return "all good"
    }
    let productsController = ProductsController()
    let categoriesController = CategoriesController()
    
    let authorized = root.grouped(JWTStorageMiddleware<Payload>())
    
    root.get("categories", use: categoriesController.get)
    authorized.post(CategoryInput.self, at: "categories", use: categoriesController.new)
    authorized.patch(CategoryInput.self, at: ["categories", Int.parameter], use: categoriesController.edit)
    authorized.delete(["categories", Int.parameter], use: categoriesController.delete)
    root.get("", use: productsController.get)
    authorized.post(ProductInput.self, at: "", use: productsController.new)
    authorized.patch(ProductInput.self, at: "", [Int.parameter], use: productsController.edit)
    authorized.delete([Int.parameter], use: productsController.delete)
}
