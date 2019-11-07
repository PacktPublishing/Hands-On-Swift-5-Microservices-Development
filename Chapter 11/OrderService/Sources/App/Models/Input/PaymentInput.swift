import Vapor

struct PaymentInput: Content {
    var orderId: Int
    var method: String
    var totalAmount: Int
}
