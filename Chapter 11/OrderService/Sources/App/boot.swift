import Vapor
import NIO

private var verifyOrdersTask: RepeatedTask? = nil

public func boot(_ app: Application) throws {
    
    let url = Environment.get("PRODUCT_SERVICE_URL") ?? "http://localhost:8080/v1/products"

    let processingController = ProcessingController(url)
    
    verifyOrdersTask = app.make(EventLoop.self).scheduleRepeatedAsyncTask(
        initialDelay: .seconds(0),
        delay: .seconds(60)
    ) { [weak app] task -> EventLoopFuture<Void> in
        let app = app!
        
        var returnFuture:EventLoopFuture<Void>? = nil
        
        do {
            returnFuture = try processingController.getOrders(status: 0, on: app).flatMap { orders -> EventLoopFuture<Void> in
                var processingFutures:[EventLoopFuture<Void>] = []
                
                for order in orders {
                    processingFutures.append(processingController.processOrderInformation(order, on: app).transform(to: ()))
                }
                return processingFutures.flatten(on: app.make(EventLoop.self))
            }
        }
        catch let error {
            returnFuture = app.make(EventLoop.self).makeFailedFuture(error)
        }
        
        return returnFuture!
    }
}
