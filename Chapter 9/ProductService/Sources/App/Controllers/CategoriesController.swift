import JWTMiddleware
import Fluent
import Vapor

final class CategoriesController {
    
    func get(_ request: Request)throws -> Future<[CategoryResponse]> {
        return try Category.query(on: request).all().map(to: [CategoryResponse].self) { cats in
            return cats.map { CategoryResponse(id: $0.id!, name: $0.name) }
        }
    }
    
    func new(_ request: Request, _ input: CategoryInput)throws -> Future<CategoryResponse> {
        let category = Category(name: input.name)
        return category.save(on: request).map(to: CategoryResponse.self) { category in
            return CategoryResponse(id: category.id!, name: category.name)
        }
    }
    
    func edit(_ request: Request, _ input: CategoryInput)throws -> Future<CategoryResponse> {
        let id = try request.parameters.next(Int.self)
        
        return Category.query(on: request).filter(\.id == id).all().flatMap(to: CategoryResponse.self) { categories in
            if categories.count == 0 {
                throw Abort(.badRequest, reason: "No product. found!")
            }
            let category = categories.first!
            
            category.name = input.name
            
            return category.save(on: request).map(to: CategoryResponse.self) { category in
                return CategoryResponse(id: category.id!, name: category.name)
            }
        }
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        let id = try request.parameters.next(Int.self)
        
        return Category.query(on: request).filter(\.id == id).delete().map(to: HTTPStatus.self) { _ in
            return .ok
        }
    }
}
