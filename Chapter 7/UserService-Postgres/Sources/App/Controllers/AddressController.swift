import Fluent
import Vapor

final class AddressController: RouteCollection {
    
    func boot(routes: RoutesBuilder) {
        routes.get("", use: addresses)
        routes.post("", use: self.create)
        routes.patch(":id", use: self.update)
        routes.delete(":id", use: delete)
    }
    
    func addresses(_ request: Request)throws -> EventLoopFuture<[AddressResponse]> {
        return Address.query(on: request.db).filter(\.$userId == request.payload.id).all().map { addresses in
            return addresses.map { AddressResponse($0) }
        }
    }
    
    func create(_ request: Request)throws -> EventLoopFuture<AddressResponse> {
        let content = try request.content.decode(AddressInput.self)
        
        let address = Address(street: content.street, city: content.city, zip: content.zip, userId: request.payload.id)
        
        return address.save(on: request.db).map { _ in
            return AddressResponse(address)
        }
    }
    
    func update(_ request: Request)throws -> EventLoopFuture<AddressResponse> {
        
        let content = try request.content.decode(AddressInput.self)
        let id = Int(request.parameters.get("id") ?? "0") ?? 0
        
        return Address.query(on: request.db).filter(\.$id == id).filter(\.$userId == request.payload.id).all().flatMap { addresses in
            if addresses.count == 0 {
                return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "No address found!"))
            }
            let address = addresses.first!
            address.street = content.street
            address.city = content.city
            address.zip = content.zip
            
            return address.save(on: request.db).map { _ in
                return AddressResponse(address)
            }
        }
    }
    
    func delete(_ request: Request)throws -> EventLoopFuture<HTTPStatus> {
        let id = Int(request.parameters.get("id") ?? "0") ?? 0
        
        return Address.query(on: request.db).filter(\.$id == id).filter(\.$userId == request.payload.id).all().flatMap { addresses in
            if addresses.count == 0 {
                return request.eventLoop.makeFailedFuture(Abort(.badRequest, reason: "No address found!"))
            }
            return addresses.first!.delete(on: request.db).transform(to: .ok)
        }
    }
}




