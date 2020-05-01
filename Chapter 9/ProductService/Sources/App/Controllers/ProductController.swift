import Fluent
import FluentKit
import Vapor

final class ProductsController {
    
    func get(_ request: Request)throws -> EventLoopFuture<[ProductResponse]> {
        let querybuilder = Product.query(on: request.db)
        
        do {
            if let categoryId = try request.query.get(Int?.self, at: "categoryId") {
                querybuilder.filter(\.$categoryId == categoryId)
            }
        }
        catch {}
        
        do {
            if let query = try request.query.get(String?.self, at: "query") {
                querybuilder.filter(\.$name ~~ query)
                querybuilder.group(.or) {
                    $0.filter(\Product.$name ~~ query).filter(\Product.$description ~~ query)
                }
            }
        }
        catch {}
        
        do {
            if let idsString = try request.query.get(String?.self, at: "ids") {
                let ids:[Int] = idsString.split(separator: ",").map { Int(String($0)) ?? 0 }
                querybuilder.filter(\.$id ~~ ids)
            }
        }
        catch {}
        
        return querybuilder.all().map { products in
            return products.map { ProductResponse(id: $0.id!, name: $0.name, description: $0.description, price: $0.price) }
        }
    }
    
    func new(_ request: Request)throws -> EventLoopFuture<ProductResponse> {
        let input = try request.content.decode(ProductInput.self)
        let product = Product(name: input.name, description: input.description, price: input.price, categoryId: input.categoryId)
        return product.save(on: request.db).map { _ in
            return ProductResponse(id: product.id!, name: product.name, description: product.description, price: product.price)
        }
    }
    
    func edit(_ request: Request)throws -> EventLoopFuture<ProductResponse> {
        let input = try request.content.decode(ProductInput.self)
        if let id = request.parameters.get("id", as: Int.self)
        {
            return Product.query(on: request.db).filter(\.$id == id).all().flatMap { products in
                if products.count == 0 {
                    return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "No product. found!"))
                }
                let product = products.first!
                
                product.name = input.name
                product.description = input.description
                product.price = input.price
                product.categoryId = input.categoryId
                
                return product.save(on: request.db).map { _ in
                    return ProductResponse(id: product.id!, name: product.name, description: product.description, price: product.price)
                }
            }
        }
        else {
            throw Abort(.badRequest, reason: "No id given.")
        }
    }
    
    func delete(_ request: Request)throws -> EventLoopFuture<HTTPStatus> {
        if let id = request.parameters.get("id", as: Int.self)
        {
            return Product.query(on: request.db).filter(\.$id == id).delete().map { _ in
                return .ok
            }
        }
        else {
            throw Abort(.badRequest, reason: "No id given.")
        }
    }
    
}
