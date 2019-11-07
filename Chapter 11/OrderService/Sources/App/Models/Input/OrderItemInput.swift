import Vapor

struct OrderItemInput: Content {
    var productId: Int
    var unitPrice: Int
    var quantity: Int
}
