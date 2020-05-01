import Fluent
import Vapor

final class CategoriesController {
    
    func get(_ request: Request)throws -> EventLoopFuture<[CategoryResponse]> {
        return Category.query(on: request.db).all().map { cats in
            return cats.map { CategoryResponse(id: $0.id!, name: $0.name) }
        }
    }
    
    func new(_ request: Request)throws -> EventLoopFuture<CategoryResponse> {
        let input = try request.content.decode(CategoryInput.self)
        let category = Category(name: input.name)
        return category.save(on: request.db).map { _ in
            return CategoryResponse(id: category.id!, name: category.name)
        }
    }
    
    func edit(_ request: Request)throws -> EventLoopFuture<CategoryResponse> {
        if let id = Int(request.parameters.get("id") ?? "0")
        {
            let input = try request.content.decode(CategoryInput.self)
            
            return Category.query(on: request.db).filter(\.$id == id).all().flatMap { categories in
                if categories.count == 0 {
                    return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "No product. found!"))
                }
                let category = categories.first!
                
                category.name = input.name
                
                return category.save(on: request.db).map { _ in
                    return CategoryResponse(id: category.id!, name: category.name)
                }
            }
        }
        else {
            throw Abort(.badRequest, reason: "No input given.")
        }
    }
    
    func delete(_ request: Request)throws -> EventLoopFuture<HTTPStatus> {
        if let id = Int(request.parameters.get("id") ?? "0") {
            return Category.query(on: request.db).filter(\.$id == id).delete().map { _ in
                return .ok
            }
        }
        else {
            throw Abort(.badRequest, reason: "No id given.")
        }
    }
}
