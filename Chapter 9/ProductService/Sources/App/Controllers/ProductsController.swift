import Fluent
import Vapor

final class ProductsController {
    
    func get(_ request: Request)throws -> Future<[ProductResponse]> {
        let querybuilder = Product.query(on: request)
        
        if let categoryId = try request.content.syncGet(Int?.self, at: "categoryId") {
            querybuilder.filter(\.categoryId == categoryId)
        }
        if let query = try request.content.syncGet(String?.self, at: "query") {
            querybuilder.filter(\.name, .like, "%\(query)%" )
        }
        if let ids = try request.content.syncGet(String?.self, at: "ids") {
            querybuilder.filter(\.id ~~ ids.split(separator: ","))
        }
        
        return querybuilder.all().map(to: [ProductResponse].self) { products in
            return products.map { ProductResponse(id: $0.id!, name: $0.name, description: $0.description, price: $0.price) }
        }
    }
    
    func new(_ request: Request, _ input: ProductInput)throws -> Future<ProductResponse> {
        let product = Product(name: input.name, description: input.description, price: input.price, categoryId: input.categoryId)
        return product.save(on: request).map(to: ProductResponse.self) { product in
            return ProductResponse(id: product.id!, name: product.name, description: product.description, price: product.price)
        }
    }
    
    func edit(_ request: Request, _ input: ProductInput)throws -> Future<ProductResponse> {
        let id = try request.parameters.next(Int.self)
        
        return Product.query(on: request).filter(\.id == id).all().flatMap(to: ProductResponse.self) { products in
            if products.count == 0 {
                throw Abort(.badRequest, reason: "No product. found!")
            }
            let product = products.first!
            
            product.name = input.name
            product.description = input.description
            product.price = input.price
            product.categoryId = input.categoryId
            
            return product.save(on: request).map(to: ProductResponse.self) { product in
                return ProductResponse(id: product.id!, name: product.name, description: product.description, price: product.price)
            }
        }
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        let id = try request.parameters.next(Int.self)
        
        return Product.query(on: request).filter(\.id == id).delete().map(to: HTTPStatus.self) { _ in
            return .ok
        }
    }
    
}
