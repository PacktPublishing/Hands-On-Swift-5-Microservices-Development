import JWTMiddleware
import Fluent
import Vapor

final class AddressesController: RouteCollection {
    

    func boot(router: Router) {
        
        router.get("", use: addresses)
        
        router.post(AddressBody.self, at: "", use: create)
        router.patch(AddressBody.self, at: [Int.parameter], use: update)
        router.delete([Int.parameter], use: delete)
    }
    
    func addresses(_ request: Request)throws -> Future<[Address]> {
        return try request.user().addresses(on: request).all()
    }
    
    func create(_ request: Request, _ content: AddressBody)throws -> Future<UserSuccessResponse> {
        let user = try request.user()
        
        let address = Address(street: content.street, city: content.city, zip: content.zip, userId: user.id!)
        
        return address.save(on: request).transform(to: user).response(on: request)
    }
    
    func update(_ request: Request, _ content: AddressBody)throws -> Future<UserSuccessResponse> {
        let user = try request.user()
        
        let id = try request.parameters.next(Int.self)
        
        return Address.query(on: request).filter(\.id == id).all().flatMap(to: UserSuccessResponse.self) { addresses in
            if addresses.count == 0 {
                throw Abort(.badRequest, reason: "No address found!")
            }
            let address = addresses.first!
            address.street = content.street
            address.city = content.city
            address.zip = content.zip
            
            return address.save(on: request).transform(to: user).response(on: request)
        }
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        let user = try request.user()
        
        let id = try request.parameters.next(Int.self)
        
        return Address.query(on: request).filter(\.id == id).all().flatMap(to: HTTPStatus.self) { addresses in
            if addresses.count == 0 {
                throw Abort(.badRequest, reason: "No address found!")
            }
            return addresses.first!.delete(on: request).transform(to: .ok)
        }
    }
}




