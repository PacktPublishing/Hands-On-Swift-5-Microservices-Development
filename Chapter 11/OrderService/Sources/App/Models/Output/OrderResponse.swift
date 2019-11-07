import Vapor

struct OrderResponse: Content {
    var id: Int
    var totalAmount: Int
    var paidAmount: Int
    var userId: Int
    var status: Int
    var createdAt: Date?
    var items:[OrderItemResponse]
    
    init(order: Order, items: [OrderItem]) {
        self.id = order.id!
        self.totalAmount = order.totalAmount
        self.paidAmount = order.paidAmount
        self.userId = order.userId
        self.status = order.status
        self.createdAt = order.createdAt
        
        self.items = []

        for item in items {
            let orderItemResponse = OrderItemResponse(productId: item.productId, unitPrice: item.unitPrice, quantity: item.quantity, totalAmount: item.totalAmount)
            self.items.append(orderItemResponse)
        }
    }
}
