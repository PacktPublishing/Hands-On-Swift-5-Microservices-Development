import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    let currentVersion = app.grouped(.anything, "orders")
    
    currentVersion.get("health") { req in
        return "All good."
    }
    
    let jwtMiddleware = app.make(JWTMiddleware.self)
    
    let protected = currentVersion.grouped(jwtMiddleware)

    let orderController = OrderController()
    protected.post("", use: orderController.post)
    protected.get("", use: orderController.listMine)
    protected.get("all", use: orderController.list)
    protected.post("payment", ":id", use: orderController.postPayment)
}
