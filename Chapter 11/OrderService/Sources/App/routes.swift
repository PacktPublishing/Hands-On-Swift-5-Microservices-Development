import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    let currentVersion = app.grouped(.anything, "orders")
    
    currentVersion.get("health") { req in
        return "All good."
    }
    
    let protected = currentVersion.grouped(JWTMiddleware())

    let orderController = OrderController()
    protected.post("", use: orderController.post)
    protected.get("", use: orderController.listMine)
    protected.get("all", use: orderController.list)
    protected.post("payment", ":id", use: orderController.postPayment)
}
