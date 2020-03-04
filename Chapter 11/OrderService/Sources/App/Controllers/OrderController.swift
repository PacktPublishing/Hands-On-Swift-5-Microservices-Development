import Fluent
import Vapor

final class OrderController {
    func list(req: Request) throws -> EventLoopFuture<[OrderResponse]> {
        return Order.query(on: req.db).all().map { orders in
            return orders.map { return OrderResponse(order: $0, items: $0.items) }
        }
        
    }
    
    func listMine(req: Request) throws -> EventLoopFuture<[OrderResponse]> {
        return Order.query(on: req.db).all().map { orders in
            return orders.map { return OrderResponse(order: $0, items: $0.items) }
        }
    }
    
    func postPayment(req: Request) throws -> EventLoopFuture<AddedPaymentResponse> {
        let paymentInput = try req.content.decode(PaymentInput.self)
        
        return Order.query(on: req.db).filter(\Order.$id == paymentInput.orderId).all().flatMap { orders in
            if orders.count == 0 {
                return req.eventLoop.makeFailedFuture(OrderError.orderNotFound)
            }
            
            let payment = OrderPayment(id: nil, totalAmount: paymentInput.totalAmount, method: paymentInput.method, order: orders.first!)
            
            return payment.save(on: req.db).transform(to: AddedPaymentResponse())
        }
    }

    func post(req: Request) throws -> EventLoopFuture<OrderResponse> {
        let orderInput = try req.content.decode(OrderInput.self)
        
        let order = Order(totalAmount: orderInput.totalAmount, firstname: orderInput.firstname, lastname: orderInput.lastname, street: orderInput.street, zip: orderInput.zip, city: orderInput.city)
        
        return order.save(on: req.db).flatMap {
            var saving:[EventLoopFuture<Void>] = []
            var items:[OrderItem] = []
            
            for inputItem in orderInput.items {
                let item = OrderItem(totalAmount: inputItem.unitPrice*inputItem.quantity, unitPrice: inputItem.unitPrice, quantity: inputItem.quantity, order: order)
                saving.append(item.save(on: req.db).map {
                    items.append(item)
                })
            }
            
            return saving.flatten(on: req.eventLoop).map {
                return OrderResponse(order: order, items: items)
            }
        }
    }
}
