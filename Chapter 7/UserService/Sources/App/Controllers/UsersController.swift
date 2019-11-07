import JWTMiddleware
import Fluent
import Vapor

final class UsersController: RouteCollection {
    
    func boot(router: Router) {
        router.get("", use: profile)
        router.patch(EditUserBody.self, at: "", use: save)
        router.delete("", use: delete)
    }
    
    func profile(_ request: Request)throws -> Future<UserSuccessResponse> {
        return try request.user().response(on: request)
    }
    
    func save(_ request: Request, _ content: EditUserBody)throws -> Future<UserSuccessResponse> {
        let user = try request.user()
        
        user.firstname = content.firstname ?? ""
        user.lastname = content.lastname ?? ""
        
        return user.update(on: request).response(on: request)
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        let user = try request.user()
        
        return try user.addresses(on: request).delete().transform(to: user).flatMap(to: HTTPStatus.self) { user in
            return user.delete(on: request).transform(to: .noContent)
        }
    }
}




