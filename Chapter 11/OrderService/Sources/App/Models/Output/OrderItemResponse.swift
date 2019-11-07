import Vapor

struct OrderItemResponse: Content {
    var productId: Int
    var unitPrice: Int
    var quantity: Int
    var totalAmount: Int
}
